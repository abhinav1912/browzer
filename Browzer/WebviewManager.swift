//

import Foundation
import WebKit

class WebviewManager {
    var cache = [String: WKWebView]()

    func getWebview(forId id: String) -> WKWebView? {
        cache[id]
    }

    func getTabIdForWebview(_ webview: WKWebView) -> String? {
        cache.first(where: { $0.value == webview })?.key
    }

    func createWebview(forTab id: String) -> WKWebView {
        let webview = WKWebView(frame: .zero)
        cache[id] = webview
        return webview
    }
}
