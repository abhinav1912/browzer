//

import Foundation
import SwiftData

@MainActor
final class HistoryManager {

    static let shared = HistoryManager()

    var modelContext: ModelContext = PersistenceController.shared.sharedModelContainer.mainContext

    func addUrlToHistory(_ urlString: String, title: String) {
        do {
            let existingRecords = try modelContext.fetch(FetchDescriptor<BrowsedURL>(predicate: #Predicate<BrowsedURL> {
                $0.url == urlString
            }))
            let browsedUrl: BrowsedURL
            if existingRecords.isEmpty {
                browsedUrl = BrowsedURL(url: urlString, title: title)
                modelContext.insert(browsedUrl)
            } else {
                browsedUrl = existingRecords[0]
            }
            let visit = URLVisit(visitedTime: Date.now, browsedUrl: browsedUrl)
            modelContext.insert(visit)
        } catch {
            print("Unable to fetch history from modelContext.")
        }
    }
}
