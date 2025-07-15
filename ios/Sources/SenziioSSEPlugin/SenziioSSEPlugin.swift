import Foundation
import Capacitor

@objc(SenziioSSEPlugin)
class SenziioSSEPlugin: CAPPlugin, CAPBridgedPlugin {

    public let identifier = "SenziioSSEPlugin"
    public let jsName = "SenziioSSE"

    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "connect", returnType: CAPPluginReturnCallback),
        CAPPluginMethod(name: "disconnect", returnType: CAPPluginReturnPromise)
    ]

    private let implementation = SenziioSSE()

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
        implementation.connect(url, SenziioSSEPluginCallback(call, bridge))
    }

    @objc func disconnect(_ call: CAPPluginCall) {
        guard let connectionId = call.getString("connectionId") else {
            call.reject("connectionId is required")
            return;
        }

        implementation.disconnect(connectionId)
        call.resolve()
    }
}
