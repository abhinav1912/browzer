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
            newTabButton
            List(viewModel.tabs, selection: $viewModel.selectedTab) { tab in
                NavigationLink(value: tab) {
                    Text(tab.title)
                }
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 240, ideal: 240)
#endif
            .toolbar {
                toolbarItems
            }
        } detail: {
            getWebViewForSelectedTab()
                .id(viewModel.selectedTab?.id)
        }
    }

    // MARK: Private

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem {
            Spacer()
        }
        ToolbarItem {
            backButton
                .frame(width: .large, height: .large)
                .padding(.small)
        }
        ToolbarItem {
            forwardButton
                .frame(width: .large, height: .large)
                .padding(.small)
        }
        ToolbarItem {
            refreshButton
                .frame(width: .large, height: .large)
                .padding(.small)
        }
    }

    private var urlInputView: some View {
        TextField("Enter the URL", text: $viewModel.inputUrl)
            .textContentType(.URL)
            .frame(maxHeight: .infinity)
            .background(.clear)
            .onSubmit {
                viewModel.openTabWithInputUrl()
                viewModel.displayNewTabInputOverlay = false
            }
    }

    private var newTabButton: some View {
        Button(
            action: displayNewTabInputOverlay,
            label: {
                HStack {
                    Label("New Tab", systemImage: "plus")
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .contentShape(.rect)
            }
        )
        .buttonStyle(.plain)
        .padding(8)
    }

    private var backButton: some View {
        Button(
            action: {}
        ){
            Image(systemName: "arrow.backward")
        }
        .disabled(!viewModel.canGoBack)
    }

    private var forwardButton: some View {
        Button(
            action: {}
        ){
            Image(systemName: "arrow.forward")
        }
        .disabled(!viewModel.canGoForward)
    }

    private var refreshButton: some View {
        Button(
            action: {}
        ){
            Image(systemName: "arrow.clockwise")
        }
        .disabled(viewModel.selectedTab == nil)
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
