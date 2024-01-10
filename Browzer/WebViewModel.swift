//

import SwiftUI
import WebKit

class WebViewModel: ObservableObject {
    let webView = WKWebView(frame: .zero)
    var url: URL? = URL(string: "https://google.com")

    func loadURL() {
        if let url {
            webView.load(URLRequest(url: url))
        }
    }
}
