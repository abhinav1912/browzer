//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) var modelContext
    @Query var urlVisits: [URLVisit]

    var body: some View {
        if urlVisits.isEmpty {
            Text("No history yet!")
        } else {
            List {
                ForEach(groupedHistory) { item in
                    Section(header: Text(item.date)) {
                        ForEach(item.visits) { urlVisit in
                            if let url = urlVisit.browsedUrl {
                                HStack {
                                    Text(urlVisit.visitedTime.ISO8601Format())
                                    Text(url.title)
                                    Text(url.url)
                                }
                            }
                        }
                    }
                    .headerProminence(.increased)
                }
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #endif
        }
    }

    // MARK: - Private

    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter
    }

    private var groupedHistory: [GroupedHistory] {
        let dict = Dictionary(grouping: urlVisits) { (visit) -> String in
            dateFormatter.string(from: visit.visitedTime)
        }
        var history = [GroupedHistory]()
        dict.keys.forEach { key in
            history.append(GroupedHistory(date: key, visits: dict[key] ?? []))
        }
        return history
    }

    // MARK: - Types

    struct GroupedHistory: Identifiable {
        let date: String
        let visits: [URLVisit]

        var id: String {
            return date
        }
    }
}
