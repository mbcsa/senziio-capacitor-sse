import Foundation

public final class EventSource: NSObject, URLSessionDataDelegate {
    private var isConnected = false
    public typealias EventHandler = () -> Void
    public typealias MessageHandler = (String?, String?, String?) -> Void
    public typealias ErrorHandler = (Int?, Bool, Error?) -> Void
    
    private let url: URL
    private var configuration: URLSessionConfiguration
    private var session: URLSession?
    private var task: URLSessionDataTask?
    private var receivedData: Data?
    private var lastEventID: String?
    private var retryTime = 3000
    private var isManualDisconnect = false

    private var retryDelay: Int = 3000 // 3 segundos iniciales
    private let maxRetryDelay: Int = 30000 // 30 segundos máximo
    
    private var heartbeatTimer: Timer?

    public var onOpen: EventHandler?
    public var onComplete: ErrorHandler?
    public var onMessage: MessageHandler?
    private var eventListeners = [String: MessageHandler]()
    
    public init(url: URL, configuration: URLSessionConfiguration = .default) {
        self.url = url
        self.configuration = configuration
        
        // Configuración para conexión persistente
        self.configuration.timeoutIntervalForRequest = Double.greatestFiniteMagnitude
        self.configuration.timeoutIntervalForResource = Double.greatestFiniteMagnitude
        self.configuration.waitsForConnectivity = true
        self.configuration.allowsCellularAccess = true
        
        super.init()
    }

    private func startHeartbeatMonitor() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isConnected else { return }
            print("❤️ Enviando heartbeat para mantener conexión activa")
        }
    }
    
    public func addEventListener(_ event: String, handler: @escaping MessageHandler) {
        eventListeners[event] = handler
    }
    
    public func connect() {
        guard !isConnected else { return }
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        var request = URLRequest(url: url)
        request.timeoutInterval = configuration.timeoutIntervalForResource
        
        if let lastEventID = lastEventID {
            request.setValue(lastEventID, forHTTPHeaderField: "Last-Event-ID")
        }
        
        configuration.httpAdditionalHeaders?.forEach { key, value in
            if let keyStr = key as? String, let valueStr = value as? String {
                request.setValue(valueStr, forHTTPHeaderField: keyStr)
            }
        }
        isConnected = true
        self.session = session
        self.task = session.dataTask(with: request)
        self.task?.resume()
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData = (receivedData ?? Data()) + data
        
        // Convertir a texto considerando posibles encoding issues
        guard let stringData = String(data: receivedData!, encoding: .utf8) else {
            receivedData = nil
            return
        }
        
        // Separar por líneas (manejando \r\n y \n)
        let lines = stringData.components(separatedBy: .newlines)
        var messages = [SSEMessage]()
        var currentMessage = SSEMessage()
        var buffer = [String]()
        var previousLineEmpty = false
        
        for line in lines {
            // Detectar mensaje completo (doble línea vacía)
            if line.isEmpty {
                if (previousLineEmpty) {
                    currentMessage = SSEMessage()
                    // Procesar todas las líneas acumuladas
                    for bufferedLine in buffer {
                        processLine(bufferedLine, into: &currentMessage)
                    }
                    // Solo agregar si tiene datos válidos
                    if !currentMessage.isEmpty {
                        messages.append(currentMessage)
                    }
                    buffer.removeAll()
                }
                previousLineEmpty = true
                continue
            } else {
                // Acumular líneas no vacías
                previousLineEmpty = false
                buffer.append(line)
            }
        }
        
        // Manejar datos residuales (mensaje incompleto)
        receivedData = buffer.isEmpty ? nil : buffer.joined(separator: "\n").data(using: .utf8)
        
        // Enviar todos los mensajes completos
        for message in messages {
            dispatchValidMessage(message)
        }
    }

    private func processLine(_ line: String, into message: inout SSEMessage) {
        guard !line.hasPrefix(":") else { return } // Ignorar comentarios
        
        let (field, value) = parseLine(line)
        guard let field = field, let value = value else { return }
        
        switch field {
        case "event":
            message.event = value
        case "data":
            message.data = message.data != nil ? message.data! + "\n" + value : value
        case "id":
            message.id = value
            lastEventID = value
        case "retry":
            if let retry = Int(value) { retryTime = retry }
        default:
            break
        }
    }

    private func dispatchValidMessage(_ message: SSEMessage) {
        // Validación estricta del formato SSE
        guard message.event != nil || message.data != nil else {
            print("⚠️ Mensaje SSE inválido descartado (sin event ni data)")
            return
        }
        
        dispatchMessage(
            id: message.id,
            event: message.event ?? "message", // Valor por defecto según spec SSE
            data: message.data
        )
        
        // Log de depuración
        print("""
        ✅ SSE Message Dispatched:
        ID: \(message.id ?? "nil")
        Event: \(message.event ?? "nil")
        Data: \(message.data?.prefix(100) ?? "nil")...
        """)
    }

    private struct SSEMessage {
        var id: String?
        var event: String?
        var data: String?
        
        var isEmpty: Bool {
            return id == nil && event == nil && data == nil
        }
    }
    
    private func parseLine(_ line: String) -> (String?, String?) {
        guard let colonIndex = line.firstIndex(of: ":") else { return (nil, nil) }
        
        let field = String(line[..<colonIndex]).trimmingCharacters(in: .whitespaces)
        let value = String(line[line.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
        
        return (field.isEmpty ? nil : field, value.isEmpty ? nil : value)
    }
    
    private func dispatchMessage(id: String?, event: String, data: String?) {
        if let listener = eventListeners[event] {
            listener(id, event, data)
        } else {
            onMessage?(id, event, data)
        }
    }
    
    /*public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let statusCode = (task.response as? HTTPURLResponse)?.statusCode
        let shouldReconnect = error != nil && !(error! is URLError)
        
        onComplete?(statusCode, shouldReconnect, error)
        
        if shouldReconnect {
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(retryTime)) {
                self.connect()
            }
        }
    }*/

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard !isManualDisconnect else {
            isManualDisconnect = false
            return
        }
        
        let nsError = error as? NSError
        let statusCode = (task.response as? HTTPURLResponse)?.statusCode
        
        // Reconectar para cualquier error excepto cancelación manual
        if error != nil && nsError?.code != NSURLErrorCancelled {
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(retryDelay)) {
                self.retryDelay = min(self.retryDelay * 2, self.maxRetryDelay) // Backoff exponencial
                self.connect()
            }
        }
        
        onComplete?(statusCode, error != nil, error)
    }

    public func urlSession(_ session: URLSession, 
                        dataTask: URLSessionDataTask, 
                        didReceive response: URLResponse, 
                        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let httpResponse = response as? HTTPURLResponse, 
        httpResponse.statusCode == 200,
        httpResponse.mimeType == "text/event-stream" {
            onOpen?()
        }
        completionHandler(.allow)
    }

    public func disconnect() {
        isManualDisconnect = true
        task?.cancel()
        session?.invalidateAndCancel()
        retryDelay = 3000 // Resetear delay para próxima conexión
        isConnected = false
    }
}
