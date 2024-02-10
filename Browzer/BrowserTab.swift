//

import Foundation
import WebKit

struct BrowserTab {
    var title: String
    let id: String
    var url: String
    var urlHost: String
    let webView = WKWebView(frame: .zero)

    init(urlString: String, navigationDelegate: WKNavigationDelegate) {
        self.id = UUID().uuidString
        self.url = urlString
        self.title = URL(string: urlString)?.host() ?? urlString
        self.urlHost = title
        webView.navigationDelegate = navigationDelegate
    }

    func loadURL() {
        if let url = URL(string: url) {
            webView.load(URLRequest(url: url))
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
