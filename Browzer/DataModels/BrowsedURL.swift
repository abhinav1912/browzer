//

import Foundation
import SwiftData

@Model
final class BrowsedURL {
    var url: String
    var title: String
    var visits: [URLVisit]

    init(url: String, title: String, visits: [URLVisit] = []) {
        self.url = url
        self.title = title
        self.visits = visits
    }

    var visitCount: Int {
        visits.count
    }
}
