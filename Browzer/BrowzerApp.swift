//

import SwiftUI
import SwiftData

@main
struct BrowzerApp: App {
    var browserViewModel = BrowserViewModel()

    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            macOS_ContentView(viewModel: browserViewModel)
                .frame(minWidth: 480, minHeight: 360)
            #else
            iOS_ContentView(viewModel: browserViewModel)
            #endif
        }
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
