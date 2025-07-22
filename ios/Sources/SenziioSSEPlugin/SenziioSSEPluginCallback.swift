import Foundation
import Capacitor

class SenziioSSEPluginCallback : CustomEventSourceListener {
    private let call: CAPPluginCall
    private weak var bridge: CAPBridgeProtocol?

    init (_ call: CAPPluginCall, _ bridge: CAPBridgeProtocol?) {
        self.call = call
        self.bridge = bridge
    }

    func getId() -> String {
        return call.callbackId
    }

    func onOpen() {
        call.resolve(status("connected"))
    }

    func onEvent(type: String, data: String?) {
        call.resolve(message(type, data))
    }

    func onFailure(_ error: Error) {
        call.reject(error.localizedDescription, nil, error)
        release()
    }

    func onClosed() {
        call.resolve(status("disconnected"))
        release()
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
