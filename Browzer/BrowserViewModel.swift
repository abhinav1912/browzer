//

import Foundation
import WebKit

class BrowserViewModel: NSObject, ObservableObject {
    @Published var tabs = [BrowserTab]()
    @Published var displayNewTabInputOverlay = false
    @Published var canGoBack = false
    @Published var canGoForward = false

    @Published var selectedTab: BrowserTab? {
        didSet {
            updateNavigationState()
        }
    }

    var inputUrl = ""

    func openTabWithInputUrl() {
        var newUrl = inputUrl
        if !newUrl.hasPrefix("https://") {
            newUrl = "https://" + newUrl
        }
        let newTab = BrowserTab(urlString: newUrl, navigationDelegate: self)
        inputUrl = ""
        tabs.append(newTab)
        newTab.loadURL()
        Task { @MainActor [weak self] in
            self?.selectedTab = newTab
        }
    }

    func goBack() {
        selectedTab?.webView.goBack()
    }

    func goForward() {
        selectedTab?.webView.goForward()
    }

    func refreshWebView() {
        selectedTab?.webView.reload()
    }

    // MARK: Private

    private func updateNavigationState() {
        if let selectedTab {
            canGoBack = selectedTab.webView.canGoBack
            canGoForward = selectedTab.webView.canGoForward
        } else {
            canGoBack = false
            canGoForward = false
        }
    }
}

extension BrowserViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if
            let title = webView.title,
            !title.isEmpty,
            let index = tabs.firstIndex(where: { $0.webView == webView })
        {
            tabs[index].title = title
            if selectedTab?.id == tabs[index].id {
                selectedTab = tabs[index]
            }
        }
    }
}
