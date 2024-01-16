//

import Foundation

class BrowserViewModel: ObservableObject {
    @Published var tabs = [BrowserTab]()
    @Published var displayNewTabInputOverlay = false

    var inputUrl = ""
}
