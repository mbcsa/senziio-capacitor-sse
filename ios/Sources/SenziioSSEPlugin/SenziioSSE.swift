import Foundation
import Capacitor

@objc(SenziioSSE)
public class SenziioSSE: CAPPlugin {
    private var eventSource: EventSource?
    
    @objc func connect(_ call: CAPPluginCall) {
        guard let url = call.getString("url") else {
            call.reject("URL is required")
            return
        }
        
        setupEventSource(url: url, call: call)
    }
    
    private func setupEventSource(url: String, call: CAPPluginCall) {
        guard let eventSourceUrl = URL(string: url) else {
            call.reject("Invalid URL")
            return
        }
        
        var configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0
        configuration.httpAdditionalHeaders = [
            "Accept": "text/event-stream",
            "Cache-Control": "no-cache"
        ]
        
        self.eventSource = EventSource(url: eventSourceUrl, configuration: configuration)
        
        self.eventSource?.onOpen = { [weak self] in
            DispatchQueue.main.async {
                var ret = JSObject()
                ret["status"] = "connected"
                self?.notifyListeners("connected", data: ret)
                call.resolve()
            }
        }
        
        self.eventSource?.onMessage = { [weak self] (id, event, data) in
            print("ID: \(id)")
            print("EVENT: \(event)")
            print("DATA: \(data)")
            self?.handleSSEMessage(id: id, event: event, data: data)
        }
        
        self.eventSource?.onComplete = { [weak self] statusCode, reconnect, error in
            DispatchQueue.main.async {
                // Connection error notification
                var errorObj = JSObject()
                errorObj["message"] = "Connection failed"
                if let error = error {
                    errorObj["error"] = error.localizedDescription
                }
                self?.notifyListeners("connection_error", data: errorObj)
                
                // Disconnection notification
                var disconObj = JSObject()
                disconObj["status"] = "disconnected"
                disconObj["reason"] = "error"
                self?.notifyListeners("disconnected", data: disconObj)
                
                if !reconnect {
                    call.reject(error?.localizedDescription ?? "Unknown error")
                }
            }
        }
        
        self.eventSource?.connect()
    }
    
    private func handleSSEMessage(id: String?, event: String?, data: String?) {
        // 1. Validación estricta del evento
        guard let eventName = event, !eventName.isEmpty else {
            print("❌ Evento sin nombre recibido. Datos descartados.")
            return
        }

        DispatchQueue.main.async {
            var ret = JSObject()
            ret["id"] = id
            ret["type"] = eventName
            
            // 2. Datos CRUDOS sin procesamiento
            if let data = data, !data.isEmpty {
                ret["data"] = data // String exacto como vino del servidor
            } else {
                ret["data"] = NSNull()
            }

            // 3. Notificación del evento específico
            self.notifyListeners(eventName, data: ret)
            
            // 4. (Opcional) Notificación genérica
            var messageData = JSObject()
            messageData["event"] = eventName
            messageData["data"] = ret["data"]
            self.notifyListeners("sse_message", data: messageData)
        }
    }
    
    @objc func disconnect(_ call: CAPPluginCall) {
        eventSource?.disconnect()
        
        // Manual disconnection notification
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