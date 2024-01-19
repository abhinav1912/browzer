//

import Foundation

class BrowserViewModel: ObservableObject {
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
        let newTab = BrowserTab(urlString: newUrl)
        inputUrl = ""
        tabs.append(newTab)
        selectedTab = newTab
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
