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
            if existingRecords.isEmpty {
                let newRecord = BrowsedURL(url: urlString, title: title)
                modelContext.insert(newRecord)
            } else {
                let browsedUrl = existingRecords[0]
                let _ = URLVisit(visitedTime: Date.now, browsedUrl: browsedUrl)
            }
        } catch {
            print("Unable to fetch history from modelContext.")
        }
    }
}
