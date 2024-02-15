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
    var isNewTab = true

    let historyManager = HistoryManager.shared

    func openTabWithInputUrl() {
        var newUrl = inputUrl
        if !newUrl.hasPrefix("https://") {
            newUrl = "https://" + newUrl
        }
        if isNewTab {
            let newTab = BrowserTab(urlString: newUrl, navigationDelegate: self)
            tabs.append(newTab)
            newTab.loadURL()
            Task { @MainActor [weak self] in
                self?.selectedTab = newTab
            }
        } else {
            selectedTab?.url = newUrl
            selectedTab?.loadURL()
        }
        inputUrl = ""
        isNewTab = true
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
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let index = tabs.firstIndex(where: { $0.webView == webView }) else { return }
        if let url = webView.url {
            tabs[index].url = url.absoluteString
            tabs[index].urlHost = url.host() ?? tabs[index].urlHost
        }

        if selectedTab?.id == tabs[index].id {
            selectedTab = tabs[index]
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let index = tabs.firstIndex(where: { $0.webView == webView }) else { return }
        let urlTitle: String
        if
            let title = webView.title,
            !title.isEmpty
        {
            tabs[index].title = title
            urlTitle = title
        } else {
            urlTitle = tabs[index].urlHost
        }

        if let url = webView.url {
            tabs[index].url = url.absoluteString
            tabs[index].urlHost = url.host() ?? tabs[index].urlHost
            Task {
                await historyManager.addUrlToHistory(url.absoluteString, title: urlTitle)
            }
        }

        if selectedTab?.id == tabs[index].id {
            selectedTab = tabs[index]
        }
    }
}
