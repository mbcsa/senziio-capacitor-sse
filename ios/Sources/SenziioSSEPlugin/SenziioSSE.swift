import Foundation
import Capacitor

public class SenziioSSE: NSObject {
    private var connections: [String: SenziioSSEConnection] = [:]
    private let maxRetryAttempts = 10

    func connect(_ url: URL, _ callback: SenziioSSEPluginCallback) {
        let connectionId = callback.getId()

        // Si ya existe una conexión previa, la desconectamos primero
        if let existing = connections[connectionId] {
            existing.disconnect()
            connections[connectionId] = nil
        }

        let connection = SenziioSSEConnection(url, maxRetryAttempts, callback)
        connections[connectionId] = connection
        connection.connect()
    }
    
    func disconnect(_ connectionId: String) {
        if let connection = connections[connectionId] {
            connection.disconnect()
            connections[connectionId] = nil
        }
    }
    
    deinit {
        for (_, connection) in connections {
            connection.disconnect()
        }
        connections.removeAll()
    }

}

// MARK: - SenziioSSEConnection

class SenziioSSEConnection {
    private var eventSource: EventSource?
    private var lastEventId: String?
    private var retryAttempts = 0
    
    private let url: URL
    private let maxRetryAttempts: Int
    private let listener: EventSourceListener;

    init(_ url: URL, _ maxRetryAttempts: Int, _ listener: EventSourceListener) {
        self.url = url
        self.maxRetryAttempts = maxRetryAttempts
        self.listener = listener
    }

    func connect() {
        retryAttempts = 0
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Double.greatestFiniteMagnitude
        configuration.timeoutIntervalForResource = Double.greatestFiniteMagnitude
        configuration.httpAdditionalHeaders = [
            "Accept": "text/event-stream",
            "Cache-Control": "no-cache",
            "Last-Event-ID": lastEventId ?? ""
        ]

        eventSource = EventSource(url, listener, configuration)
        eventSource?.connect()
    }

    func disconnect() {
        eventSource?.disconnect()
    }

    private func attemptReconnection() {
        retryAttempts += 1
        guard retryAttempts <= maxRetryAttempts else {
            print("⛔ Máximo de intentos de reconexión alcanzado")
            return
        }
        let delay = min(pow(2.0, Double(retryAttempts)) * 1000, 30000)
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(Int(delay))) { [weak self] in
            guard let self = self else { return }
            print("♻️ Intentando reconexión #\(self.retryAttempts)...")
            self.eventSource?.connect()
        }
    }
}