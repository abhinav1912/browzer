//

import Foundation

class BrowserViewModel: ObservableObject {
    @Published var tabs = [BrowserTab]()
}
