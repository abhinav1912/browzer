//

import Foundation
import WebKit

struct BrowserTab {
    var title: String
    let id: String
    var url: String
    let webView = WKWebView(frame: .zero)

    init(urlString: String) {
        self.id = UUID().uuidString
        self.url = urlString
        self.title = URL(string: urlString)?.host() ?? urlString
    }

    func loadURL() {
        if let url = URL(string: url) {
            webView.load(URLRequest(url: url))
        }
    }
}
