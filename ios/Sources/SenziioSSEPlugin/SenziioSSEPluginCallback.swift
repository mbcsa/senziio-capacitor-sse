import Foundation
import Capacitor
import LDSwiftEventSource

class SenziioSSEPluginCallback : EventHandler {
    private let call: CAPPluginCall
    private weak var bridge: CAPBridgeProtocol?

    init (_ call: CAPPluginCall, _ bridge: CAPBridgeProtocol?) {
        self.call = call
        self.bridge = bridge
    }

    func getId() -> String {
        return call.callbackId
    }

    func onOpened() {
        call.resolve(status("connected"))
    }

    func onMessage(eventType: String, messageEvent: MessageEvent) {
        call.resolve(message(eventType, messageEvent.data))
    }

    func onError(error: any Error) {
        call.reject(error.localizedDescription, nil, error)
        release()
    }

    func onClosed() {
        call.resolve(status("disconnected"))
        release()
    }

    func onComment(comment: String) {
        //
    }

    private func release() {
        bridge?.releaseCall(withID: call.callbackId)
    }

    private func status(_ s: String) -> [String: Any] {
        return [
            "type": "status",
            "status": s
        ]
    }

    private func message(_ type: String, _ data: String?) -> [String: Any] {
        return [
            "type": "message",
            "payload": [
                "type": type,
                "data": data
            ]
        ]
    }
}
