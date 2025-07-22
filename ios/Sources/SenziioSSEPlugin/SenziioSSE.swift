import Foundation
import Capacitor
import LDSwiftEventSource

class SenziioEventHandler : EventHandler {
    let wrapped: SenziioSSEPluginCallback

    init(_ wrapped: SenziioSSEPluginCallback) {
        self.wrapped = wrapped
    }

    func onOpened() {
        wrapped.onOpen()
    }

    func onError(error: any Error) {
        wrapped.onFailure(error)
    }

    func onMessage(eventType: String, messageEvent: MessageEvent) {
        wrapped.onEvent(type: eventType, data: messageEvent.data)
    }

    func onClosed() {
        wrapped.onClosed()
    }

    func onComment(comment: String) {
        //
    }
}

public class SenziioSSE: NSObject {
    private var eventSources: [String: EventSource] = [:]

    func connect(_ url: URL, _ callback: SenziioSSEPluginCallback) {
        let connectionId = callback.getId()
        
        if let existing = eventSources[connectionId] {
            existing.stop()
            eventSources[connectionId] = nil
        }

        let handler = SenziioEventHandler(callback)
        let eventSource = EventSource(config: .init(handler: handler, url: url))
        
        eventSources[connectionId] = eventSource
        eventSource.start()
    }
    
    func disconnect(_ connectionId: String) {
        if let eventSource = eventSources[connectionId] {
            eventSource.stop()
            eventSources[connectionId] = nil
        }
    }
    
    deinit {
        for (_, eventSource) in eventSources {
            eventSource.stop()
        }
        eventSources.removeAll()
    }

}

// MARK: - SenziioSSEConnection

class SenziioSSEConnection {
    private var eventSource: CustomEventSource?
    private var lastEventId: String?
    
    private let url: URL
    private let listener: CustomEventSourceListener;

    init(_ url: URL, _ listener: CustomEventSourceListener) {
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

        eventSource = CustomEventSource(url, listener, configuration)
        eventSource?.connect()
    }

    func disconnect() {
        eventSource?.disconnect()
    }
}
