//

import SwiftUI
import SwiftData

@main
struct BrowzerApp: App {
    var browserViewModel = BrowserViewModel()

    var body: some Scene {
        WindowGroup {
            macOS_ContentView()
                .frame(minWidth: 480, minHeight: 360)
        }
        .environmentObject(browserViewModel)
        .modelContainer(PersistenceController.shared.sharedModelContainer)
        .commands {
            CommandGroup(after: .newItem) {
                Button("History") {
                    browserViewModel.inputUrl = "browzer://history"
                    browserViewModel.openTabWithInputUrl()
                }.keyboardShortcut("y")
            }
        }
    }
}
