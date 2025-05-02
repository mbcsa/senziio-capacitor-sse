import Foundation
import Capacitor

@objc(SenziioSSE)
public class SenziioSSE: CAPPlugin {
    private var eventSource: EventSource?
    private var lastEventId: String?
    private var retryAttempts = 0
    private let maxRetryAttempts = 10
    
    @objc func connect(_ call: CAPPluginCall) {
        guard let urlString = call.getString("url") else {
            call.reject("URL is required")
            return
        }
        
        guard let url = URL(string: urlString) else {
            call.reject("Invalid URL format")
            return
        }
        
        // Resetear intentos de reconexión
        retryAttempts = 0
        
        // Configuración personalizada para SSE
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Double.greatestFiniteMagnitude
        configuration.timeoutIntervalForResource = Double.greatestFiniteMagnitude
        configuration.httpAdditionalHeaders = [
            "Accept": "text/event-stream",
            "Cache-Control": "no-cache",
            "Last-Event-ID": lastEventId ?? ""
        ]
        
        // Crear nueva instancia de EventSource
        eventSource = EventSource(url: url, configuration: configuration)
        
        // Configurar manejadores de eventos
        setupEventHandlers(call: call)
        
        // Iniciar conexión
        eventSource?.connect()
    }
    
    private func setupEventHandlers(call: CAPPluginCall) {
        eventSource?.onOpen = { [weak self] in
            DispatchQueue.main.async {
                self?.retryAttempts = 0
                var ret = JSObject()
                ret["status"] = "connected"
                self?.notifyListeners("connected", data: ret)
                call.resolve()
            }
        }
        
        eventSource?.onMessage = { [weak self] (id, event, data) in
            self?.lastEventId = id
            self?.handleSSEMessage(id: id, event: event, data: data)
        }
        
        eventSource?.onComplete = { [weak self] statusCode, shouldReconnect, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Notificar error
                var errorObj = JSObject()
                errorObj["message"] = "Connection error"
                errorObj["statusCode"] = statusCode
                errorObj["error"] = error?.localizedDescription
                errorObj["willReconnect"] = shouldReconnect
                self.notifyListeners("error", data: errorObj)
                
                // Manejar reconexión automática
                if shouldReconnect {
                    self.attemptReconnection()
                } else {
                    var disconObj = JSObject()
                    disconObj["status"] = "disconnected"
                    disconObj["reason"] = "error"
                    self.notifyListeners("disconnected", data: disconObj)
                    call.reject(error?.localizedDescription ?? "Connection closed")
                }
            }
        }
    }
    
    private func attemptReconnection() {
        retryAttempts += 1
        
        guard retryAttempts <= maxRetryAttempts else {
            print("⛔ Máximo de intentos de reconexión alcanzado")
            return
        }
        
        let delay = min(pow(2.0, Double(retryAttempts)) * 1000, 30000) // Backoff exponencial con máximo 30s
        
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(Int(delay))) { [weak self] in
            print("♻️ Intentando reconexión #\(self?.retryAttempts ?? 0)...")
            self?.eventSource?.connect()
        }
    }
    
    private func handleSSEMessage(id: String?, event: String?, data: String?) {
        guard let eventName = event else { return }
        
        DispatchQueue.main.async {
            var ret = JSObject()
            ret["id"] = id
            ret["type"] = eventName
            
            // Mantener data como string crudo
            if let data = data, !data.isEmpty {
                ret["data"] = data
            } else {
                ret["data"] = NSNull()
            }
            
            // Notificar evento específico
            self.notifyListeners(eventName, data: ret)
            
            // Notificar evento genérico
            var messageData = JSObject()
            messageData["event"] = eventName
            messageData["data"] = ret["data"]
            self.notifyListeners("sse_message", data: messageData)
        }
    }
    
    @objc func disconnect(_ call: CAPPluginCall) {
        eventSource?.disconnect()
        
        var disconObj = JSObject()
        disconObj["status"] = "disconnected"
        disconObj["reason"] = "manual"
        notifyListeners("disconnected", data: disconObj)
        
        call.resolve()
    }
    
    deinit {
        eventSource?.disconnect()
    }
}