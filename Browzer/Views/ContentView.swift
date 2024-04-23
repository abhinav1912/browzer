//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var viewModel: BrowserViewModel

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
            addressBar
            newTabButton
            tabList
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

    @ViewBuilder
    private var addressBar: some View {
        Button(action: {
            viewModel.inputUrl = viewModel.selectedTab?.url ?? ""
            viewModel.isNewTab = viewModel.selectedTab == nil
            viewModel.displayNewTabInputOverlay = true
        }) {
            HStack {
                if let title = viewModel.selectedTab?.urlHost {
                    Text(title)
                } else {
                    Image(systemName: "magnifyingglass")
                    Text("Enter URL")
                }
                Spacer()
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
    }

    private var urlInputView: some View {
        TextField(viewModel.selectedTab?.url ?? "Enter the URL", text: $viewModel.inputUrl)
            .textContentType(.URL)
            .frame(maxHeight: .infinity)
            .background(.clear)
            .onSubmit {
                viewModel.openTabWithInputUrl()
                viewModel.displayNewTabInputOverlay = false
            }
            .onDisappear {
                viewModel.inputUrl = ""
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
        .keyboardShortcut("t")
    }

    private var backButton: some View {
        Button(
            action: viewModel.goBack
        ){
            Image(systemName: "arrow.backward")
        }
        .disabled(!viewModel.canGoBack)
    }

    private var forwardButton: some View {
        Button(
            action: viewModel.goForward
        ){
            Image(systemName: "arrow.forward")
        }
        .disabled(!viewModel.canGoForward)
    }

    private var refreshButton: some View {
        Button(
            action: viewModel.refreshWebView
        ){
            Image(systemName: "arrow.clockwise")
        }
        .disabled(viewModel.selectedTab == nil)
    }

    private var tabList: some View {
        List(viewModel.tabs, selection: $viewModel.selectedTab) { tab in
            NavigationLink(value: tab) {
                HStack {
                    CachedAsyncImage(
                        url: URL(string: FavIconHelper.getUrlForDomain(tab.urlHost)),
                        content: { image in
                            image
                                .resizable()
                                .frame(width: 16, height: 16)
                        },
                        placeholder: {
                            Image(systemName: "globe")
                        }
                    )
                    Text(tab.title)
                }
            }
        }
    }

    @ViewBuilder
    private func getWebViewForSelectedTab() -> some View {
        if let selectedTab = viewModel.selectedTab {
            if let webView = selectedTab.webView {
                WebView(webView: webView)
            } else {
                HistoryView()
            }
        } else {
            EmptyView()
        }
    }

    private func displayNewTabInputOverlay() {
        viewModel.displayNewTabInputOverlay = true
    }
}

#Preview {
    ContentView()
        .modelContainer(for: BrowsedURL.self, inMemory: true)
}
