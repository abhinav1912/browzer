//

import Foundation
import SwiftData

@Model
final class URLVisit {
    var visitedTime: Date

    init(visitedTime: Date) {
        self.visitedTime = visitedTime
    }
}
