import Foundation

class EventSource: NSObject, URLSessionDataDelegate {
    private var url: URL
    private var task: URLSessionDataTask?
    private var session: URLSession?
    private let callbackId: String
    private var retryTime = 3000
    private var lastEventId: String?

    var onOpen: (() -> Void)?
    var onMessage: ((_ id: String?, _ type: String?, _ data: String) -> Void)?
    var onError: ((_ error: Error?) -> Void)?

    init(url: URL, callbackId: String) {
        self.url = url
        self.callbackId = callbackId
        super.init()
    }

    func connect() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(INT_MAX)
        configuration.timeoutIntervalForResource = TimeInterval(INT_MAX)
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

        if let lastEventId = lastEventId {
            request.setValue(lastEventId, forHTTPHeaderField: "Last-Event-ID")
        }

        task = session?.dataTask(with: request)
        task?.resume()
    }

    func disconnect() {
        task?.cancel()
        session?.invalidateAndCancel()
    }

    // MARK: - URLSessionDataDelegate

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let stringData = String(data: data, encoding: .utf8) else { return }

        let lines = stringData.components(separatedBy: .newlines)
        var eventId: String?
        var eventType: String?
        var eventData = ""

        for line in lines {
            if line.hasPrefix("id:") {
                eventId = String(line.dropFirst(4))
            } else if line.hasPrefix("event:") {
                eventType = String(line.dropFirst(7))
            } else if line.hasPrefix("data:") {
                eventData.append(String(line.dropFirst(6))
                eventData.append("\n")
            } else if line.isEmpty {
                if !eventData.isEmpty {
                    onMessage?(eventId, eventType ?? "message", eventData.trimmingCharacters(in: .whitespacesAndNewlines))
                    eventData = ""
                }
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error as NSError?, error.code != NSURLErrorCancelled {
            onError?(error)
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                onOpen?()
                completionHandler(.allow)
                return
            }
        }
        completionHandler(.cancel)
    }
}