//

import Foundation
import WebKit

struct BrowserTab {
    let id: String
    let contentType: ContentType

    var title: String
    var url: String
    var faviconPath: String

    // MARK: - Initializers

    init(urlString: String, title: String, contentType: ContentType, faviconPath: String? = nil) {
        self.id = UUID().uuidString
        self.url = urlString
        self.title = title
        self.urlHost = title
        self.contentType = contentType
        self.faviconPath = faviconPath ?? FavIconHelper.getUrlForDomain(urlHost)
    }

    init(urlString: String, contentType: ContentType, faviconPath: String? = nil) {
        let title = URL(string: urlString)?.host() ?? urlString
        self.init(urlString: urlString, title: title, contentType: contentType)
    }

    init(favouritesTab: FavouritesTab, contentType: ContentType) {
        self.init(urlString: favouritesTab.url, contentType: contentType, faviconPath: favouritesTab.faviconPath)
    }

    var urlHost: String {
        didSet {
            if urlHost != oldValue {
                faviconPath = FavIconHelper.getUrlForDomain(urlHost)
            }
        }
    }
    var webView: WKWebView? {
        switch contentType {
        case .webView(let webView):
            return webView
        default:
            return nil
        }
    }

    func loadURL() {
        if let url = URL(string: url) {
            webView?.load(URLRequest(url: url))
        }
    }

    // MARK: - Types

    enum ContentType {
        case history
        case startPage
        case webView(WKWebView)
    }
}

// MARK: - Extensions

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
