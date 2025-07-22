import Foundation

public protocol CustomEventSourceListener: AnyObject {
    func onOpen()
    func onEvent(type: String, data: String?)
    func onFailure(_ error: Error)
    func onClosed()
}

public final class CustomEventSource: NSObject, URLSessionDataDelegate {
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
    private var retryDelay: Int = 3000 // 3 segundos iniciales
    private let maxRetryDelay: Int = 30000 // 30 segundos máximo
    
    private var heartbeatTimer: Timer?

    private var listener: CustomEventSourceListener

    private var eventListeners = [String: MessageHandler]()
    
    public init(_ url: URL, _ listener: CustomEventSourceListener, _ configuration: URLSessionConfiguration = .default) {
        self.url = url
        self.configuration = configuration
        
        // Configuración para conexión persistente
        self.configuration.timeoutIntervalForRequest = Double.greatestFiniteMagnitude
        self.configuration.timeoutIntervalForResource = Double.greatestFiniteMagnitude
        self.configuration.waitsForConnectivity = true
        self.configuration.allowsCellularAccess = true

        self.listener = listener
        
        super.init()
    }
    
    public func connect() {
        guard !isConnected else {
            return
        }

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

        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        self.session = session
        self.task = session.dataTask(with: request)
        self.task?.resume()
    }

    private func processLine(_ line: String, into message: inout SSEMessage) {
        guard !line.hasPrefix(":") else {
            return
        } // Ignorar comentarios
        
        let (field, value) = parseLine(line)

        guard let field = field, let value = value else {
            return
        }
        
        switch field {
            case "event":
                message.event = value
            case "data":
                message.data = value
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

        listener.onEvent(type: message.event ?? "message", data: message.data)

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
        let nsError = error as? NSError

        if (error == nil || nsError?.code == NSURLErrorCancelled) {
            // Es cierre manual
            listener.onClosed()
        } else {
            listener.onFailure(error!)
        }

        retryDelay = 3000 // Resetear delay para próxima conexión
        isConnected = false
        session.invalidateAndCancel()
        receivedData = Data()
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

    public func urlSession(_ session: URLSession, 
                        dataTask: URLSessionDataTask, 
                        didReceive response: URLResponse, 
                        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            completionHandler(.allow)
            listener.onOpen()
            return
        }

        completionHandler(.cancel)
    }

    public func disconnect() {
        task?.cancel()
    }
}
