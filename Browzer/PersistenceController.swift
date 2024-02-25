//

import Foundation
import SwiftData

struct PersistenceController {
    static var shared = PersistenceController()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BrowsedURL.self,
            URLVisit.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
