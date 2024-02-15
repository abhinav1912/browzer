//

import Foundation

struct FavIconHelper {
    enum IconSize: Int {
        case small = 16
        case medium = 32
        case large = 64
    }

    static func getUrlForDomain(_ domain: String, iconSize: IconSize = .medium) -> String {
        "https://www.google.com/s2/favicons?sz=\(iconSize.rawValue)&domain=\(domain)"
    }
}
