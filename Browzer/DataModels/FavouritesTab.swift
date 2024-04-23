//

import SwiftData
import SwiftUI

@Model
struct FavouritesTab {
    var url: String
    var faviconPath: String

    init(url: String, faviconPath: String) {
        self.url = url
        self.faviconPath = faviconPath
    }
}
