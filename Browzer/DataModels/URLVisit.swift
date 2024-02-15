//

import Foundation
import SwiftData

@Model
final class URLVisit {
    var visitedTime: Date
    var browsedUrl: BrowsedURL?

    init(visitedTime: Date, browsedUrl: BrowsedURL?) {
        self.visitedTime = visitedTime
        self.browsedUrl = browsedUrl
    }
}
