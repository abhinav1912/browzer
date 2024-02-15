//

import Foundation

extension URLCache {
    static let images = URLCache(
        memoryCapacity: 100 * 1000 * 1000,
        diskCapacity: 200 * 1000 * 1000
    )
}
