import Foundation
import Capacitor
import LDSwiftEventSource


public class SenziioSSE: NSObject {
    private var eventSources: [String: EventSource] = [:]

    func connect(_ url: URL, _ callback: SenziioSSEPluginCallback) {
        let connectionId = callback.getId()
        
        if let existing = eventSources[connectionId] {
            existing.stop()
            eventSources[connectionId] = nil
        }

        var config = EventSource.Config(handler: callback, url: url)
        
        config.connectionErrorHandler = { error in
            callback.onError(error: error)
            return .shutdown
        }

        let eventSource = EventSource(config: config)
        
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

