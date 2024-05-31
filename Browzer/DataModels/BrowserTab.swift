//

import Foundation
import WebKit

struct BrowserTab {
    let id: String
    var contentType: ContentType

    var title: String
    var faviconPath: String

    // MARK: - Initializers

    init(title: String, contentType: ContentType, faviconPath: String? = nil) {
        self.id = UUID().uuidString
        self.title = title
        self.urlHost = title
        self.contentType = contentType
        self.faviconPath = faviconPath ?? FavIconHelper.getUrlForDomain(urlHost)
    }

    init(contentType: ContentType, faviconPath: String? = nil) {
        let title = contentType.getTitle()
        self.init(title: title, contentType: contentType)
    }

    init(favouritesTab: FavouritesTab, contentType: ContentType) {
        self.init(contentType: contentType, faviconPath: favouritesTab.faviconPath)
    }

    var url: String? {
        switch contentType {
        case .webView(let url):
            return url
        case .history:
            return "browzer://history"
        default:
            return nil
        }
    }

    var urlHost: String {
        didSet {
            if urlHost != oldValue {
                faviconPath = FavIconHelper.getUrlForDomain(urlHost)
            }
        }
    }

    // MARK: - Types

    enum ContentType {
        case history
        case startPage
        case webView(url: String)

        func getTitle() -> String {
            switch self {
            case .history:
                return "History"
            case .startPage:
                return "Start Page"
            case .webView(let url):
                return URL(string: url)?.host() ?? url
            }
        }
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
