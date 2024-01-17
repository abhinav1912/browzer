//

import Foundation

class BrowserViewModel: ObservableObject {
    @Published var tabs = [BrowserTab]()
    @Published var displayNewTabInputOverlay = false

    var inputUrl = ""

    func openTabWithInputUrl() {
        var newUrl = inputUrl
        if !newUrl.hasPrefix("https://") {
            newUrl = "https://" + newUrl
        }
        let newTab = BrowserTab(urlString: newUrl)
        inputUrl = ""
        tabs.append(newTab)
    }
}
