//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @StateObject private var viewModel = BrowserViewModel()

    var body: some View {
        GeometryReader { proxy in
            navigationSplitView
                .sheet(isPresented: $viewModel.displayNewTabInputOverlay) {
                    urlInputView
                        .frame(width: proxy.size.width/2, height: 40)
                        .padding(8)
                }
        }
    }

    var navigationSplitView: some View {
        NavigationSplitView {
            List(viewModel.tabs, selection: $viewModel.selectedTab) { tab in 
                NavigationLink(value: tab) {
                    Text(tab.title)
                }
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
                ToolbarItem {
                    Button(action: displayNewTabInputOverlay) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            getWebViewForSelectedTab()
                .id(viewModel.selectedTab?.id)
        }
    }

    var urlInputView: some View {
        TextField("Enter the URL", text: $viewModel.inputUrl)
            .textContentType(.URL)
            .frame(maxHeight: .infinity)
            .background(.clear)
            .onSubmit {
                viewModel.openTabWithInputUrl()
                viewModel.displayNewTabInputOverlay = false
            }
    }

    @ViewBuilder
    private func getWebViewForSelectedTab() -> some View {
        if let tab = viewModel.selectedTab {
            WebView(webView: tab.webView)
                .onAppear {
                    tab.loadURL()
                }
        } else {
            EmptyView()
        }
    }

    private func displayNewTabInputOverlay() {
        viewModel.displayNewTabInputOverlay = true
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
