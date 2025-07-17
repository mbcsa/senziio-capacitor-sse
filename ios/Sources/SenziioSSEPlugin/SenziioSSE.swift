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

        let connection = SenziioSSEConnection(url, callback)
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
    
    private let url: URL
    private let listener: EventSourceListener;

    init(_ url: URL, _ listener: EventSourceListener) {
        self.url = url
        self.listener = listener
    }

    func connect() {
        let configuration = URLSessionConfiguration.ephemeral
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
}