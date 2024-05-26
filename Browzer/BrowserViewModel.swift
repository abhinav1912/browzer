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
    @ObservationIgnored var isNewTab = true

    let historyManager = HistoryManager.shared

    func openTabWithInputUrl() {
        var newUrl = inputUrl
        let isHistoryTab = newUrl == "browzer://history"
        if
            !isHistoryTab,
            !newUrl.hasPrefix("https://")
        {
            newUrl = "https://" + newUrl
        }

        if isNewTab {
            let newTab: BrowserTab
            if isHistoryTab {
                newTab = BrowserTab(urlString: newUrl, title: "History", webView: nil)
            } else {
                newTab = BrowserTab(urlString: newUrl, webView: getNewWebView())
            }
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
        selectedTab?.webView?.goBack()
    }

    func goForward() {
        selectedTab?.webView?.goForward()
    }

    func refreshWebView() {
        selectedTab?.webView?.reload()
    }

    func initialiseFavouriteTabs(_ favouriteTabs: [FavouritesTab]) {
        self.favouriteTabs = favouriteTabs.map {
            BrowserTab(favouritesTab: $0, webView: getNewWebView())
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
        if let webView = selectedTab?.webView {
            canGoBack = webView.canGoBack
            canGoForward = webView.canGoForward
        } else {
            canGoBack = false
            canGoForward = false
        }
    }

    private func getNewWebView() -> WKWebView {
        let webView = WKWebView(frame: .zero)
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

extension BrowserViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let index = tabs.firstIndex(where: { $0.webView == webView }) {
            updateTab(at: index, webView: webView, tabs: &tabs)
        } else if let index = favouriteTabs.firstIndex(where: { $0.webView == webView }) {
            updateTab(at: index, webView: webView, tabs: &favouriteTabs)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let index = tabs.firstIndex(where: { $0.webView == webView }) {
            updateTab(at: index, webView: webView, tabs: &tabs)
        } else if let index = favouriteTabs.firstIndex(where: { $0.webView == webView }) {
            updateTab(at: index, webView: webView, tabs: &favouriteTabs)
        }
    }
}
