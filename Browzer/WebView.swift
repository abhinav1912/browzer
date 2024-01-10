//

import SwiftUI
import WebKit

struct WebView: WebViewRepresentable {

    let webView: WKWebView

    init(webView: WKWebView) {
        self.webView = webView
    }

    func makeWebView() -> WKWebView {
        webView
    }

}

#if os(macOS)
extension WebView {
    typealias NSViewType = WKWebView
    func makeNSView(context: Context) -> WKWebView {
        makeWebView()
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
#endif

#if os(iOS)
extension WebView {
    typealias UIViewType = WKWebView

    func makeUIView(context: Context) -> WKWebView {
        makeWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
#endif
