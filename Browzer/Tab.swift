//

import Foundation

struct Tab {
    var title: String
    var url: String

    init(urlString: String) {
        self.url = urlString
        self.title = URL(string: urlString)?.host() ?? urlString
    }
}
