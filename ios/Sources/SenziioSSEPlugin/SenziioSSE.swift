import Foundation
import Capacitor
import os.log

@objc(SenziioSSE)
public class SenziioSSE: CAPPlugin {
    private var eventSources: [String: EventSource] = [:]
    private let logger = OSLog(subsystem: "com.senziio.capacitorsse", category: "SSEPlugin")

    @objc func connect(_ call: CAPPluginCall) {
        guard let urlString = call.getString("url") else {
            call.reject("URL is required")
            return
        }

        guard let url = URL(string: urlString) else {
            call.reject("Invalid URL format")
            return
        }

        call.keepAlive = true

        let eventSource = EventSource(url: url, callbackId: call.callbackId)
        eventSources[call.callbackId] = eventSource

        eventSource.onOpen = {
            let result = [
                "type": "status",
                "status": "connected"
            ]
            call.resolve(result)
        }

        eventSource.onMessage = { id, type, data in
            let result = [
                "type": "message",
                "payload": [
                    "type": type ?? "message",
                    "data": data
                ]
            ] as [String : Any]
            call.resolve(result)
        }

        eventSource.onError = { error in
            if let error = error {
                call.reject(error.localizedDescription, nil, error)
            } else {
                call.reject("Unknown error occurred")
            }
            self.cleanUp(callbackId: call.callbackId)
        }

        eventSource.connect()
    }

    @objc func disconnect(_ call: CAPPluginCall) {
        guard let callbackId = call.getString("connectionId") else {
            call.reject("connectionId is required")
            return
        }

        if let eventSource = eventSources.removeValue(forKey: callbackId) {
            eventSource.disconnect()
            let result = [
                "type": "status",
                "status": "disconnected"
            ]
            call.resolve(result)
        } else {
            call.reject("Connection not found")
        }
    }

    private func cleanUp(callbackId: String) {
        if let eventSource = eventSources.removeValue(forKey: callbackId) {
            eventSource.disconnect()
        }
    }

    deinit {
        eventSources.values.forEach { $0.disconnect() }
        eventSources.removeAll()
    }
}