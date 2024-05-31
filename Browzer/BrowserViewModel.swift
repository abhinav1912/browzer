//

import Foundation
import WebKit

@Observable class BrowserViewModel: NSObject {
    var tabs = [BrowserTab]()
    var favouriteTabs = [BrowserTab]()
    var displayNewTabInputOverlay = false
    var canGoBack = false
    var canGoForward = false

    var selectedTab: BrowserTab? {
        didSet {
            updateNavigationState()
        }
    }

    @ObservationIgnored var inputUrl = ""
    /// since URL load could be for an existing tab, or for opening a new tab
    @ObservationIgnored var isOpeningNewTab = true

    let historyManager = HistoryManager.shared
    let webviewManager = WebviewManager()

    var currentWebview: WKWebView? {
        guard let selectedTabId = selectedTab?.id else {
            return nil
        }
        return webviewManager.getWebview(forId: selectedTabId)
    }

    func openTabWithInputUrl() {
        var newUrl = inputUrl
        let isHistoryTab = newUrl == "browzer://history"
        if
            !isHistoryTab,
            !newUrl.hasPrefix("https://")
        {
            newUrl = "https://" + newUrl
        }

        if isOpeningNewTab {
            let newTab: BrowserTab
            if isHistoryTab {
                newTab = BrowserTab(contentType: .history)
            } else {
                newTab = BrowserTab(contentType: .webView(url: newUrl))
            }
            let webview = getNewWebView(for: newTab.id)
            tabs.append(newTab)
            load(url: newUrl, forView: webview)
            Task { @MainActor [weak self] in
                self?.selectedTab = newTab
            }
        } else {
            selectedTab?.contentType = .webView(url: newUrl)
            load(url: newUrl, for: selectedTab?.id ?? "")
        }
        inputUrl = ""
        isOpeningNewTab = true
    }

    func goBack() {
        currentWebview?.goBack()
    }

    func goForward() {
        currentWebview?.goForward()
    }

    func refreshWebView() {
        currentWebview?.reload()
    }

    func initialiseFavouriteTabs(_ favouriteTabs: [FavouritesTab]) {
        self.favouriteTabs = favouriteTabs.map {
            BrowserTab(favouritesTab: $0, contentType: .webView(url: $0.url))
        }
    }

    func addFavouriteTab(_ tabId: String) {
        if let tabIndex = tabs.firstIndex(where: { $0.id == tabId }) {
            let tab = tabs[tabIndex]
            tabs.remove(at: tabIndex)
            favouriteTabs.append(tab)
        }
    }

    func removeFavouriteTab(at index: Int) {
        let tab = favouriteTabs.remove(at: index)
        tabs.append(tab)
    }

    func getIndexForFavouriteTab(withIdentifier id: String) -> Int? {
        favouriteTabs.firstIndex(where: { $0.id == id })
    }

    // MARK: Private

    private func updateNavigationState() {
        if let webView = currentWebview {
            canGoBack = webView.canGoBack
            canGoForward = webView.canGoForward
        } else {
            canGoBack = false
            canGoForward = false
        }
    }

    private func getNewWebView(for tabId: String) -> WKWebView {
        let webView = webviewManager.createWebview(forTab: tabId)
        webView.navigationDelegate = self
        return webView
    }

    private func updateTab(at index: Int, webView: WKWebView, tabs: inout [BrowserTab]) {
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
            tabs[index].contentType = .webView(url: url.absoluteString)
            tabs[index].urlHost = url.host() ?? tabs[index].urlHost
            Task {
                await historyManager.addUrlToHistory(url.absoluteString, title: urlTitle)
            }
        }

        if selectedTab?.id == tabs[index].id {
            selectedTab = tabs[index]
        }
    }

    private func load(url: String, for tabId: String) {
        if let url = URL(string: url) {
            webviewManager
                .getWebview(forId: tabId)?
                .load(URLRequest(url: url))
        }
    }

    private func load(url: String, forView webview: WKWebView) {
        if let url = URL(string: url) {
            webview.load(URLRequest(url: url))
        }
    }
}

// MARK: - WKNavigationDelegate extension

extension BrowserViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.update(webView)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.update(webView)
    }

    private func update(_ webView: WKWebView) {
        guard let id = webviewManager.getTabIdForWebview(webView) else { return }

        if let index = tabs.firstIndex(where: { $0.id == id }) {
            updateTab(at: index, webView: webView, tabs: &tabs)
        } else if let index = favouriteTabs.firstIndex(where: { $0.id == id }) {
            updateTab(at: index, webView: webView, tabs: &favouriteTabs)
        }
    }
}
