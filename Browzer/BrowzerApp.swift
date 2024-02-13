//

import SwiftUI
import SwiftData

@main
struct BrowzerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 480, minHeight: 360)
        }
        .modelContainer(PersistenceController.shared.sharedModelContainer)
    }
}
