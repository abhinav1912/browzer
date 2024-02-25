//

import Foundation
import WebKit

struct BrowserTab {
    var title: String
    let id: String
    var url: String
    var urlHost: String
    let webView: WKWebView?

    init(urlString: String, title: String, webView: WKWebView?) {
        self.id = UUID().uuidString
        self.url = urlString
        self.title = title
        self.urlHost = title
        self.webView = webView
    }

    init(urlString: String, webView: WKWebView?) {
        let title = URL(string: urlString)?.host() ?? urlString
        self.init(urlString: urlString, title: title, webView: webView)
    }

    func loadURL() {
        if let url = URL(string: url) {
            webView?.load(URLRequest(url: url))
        }
    }
}

extension BrowserTab: Identifiable {
    static func == (lhs: BrowserTab, rhs: BrowserTab) -> Bool {
        lhs.id == rhs.id
    }
}

extension BrowserTab: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
