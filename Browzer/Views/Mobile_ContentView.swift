//

import SwiftUI

struct Mobile_ContentView: View {
    @EnvironmentObject private var viewModel: BrowserViewModel

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                bottomBar
                .frame(maxWidth: .infinity)
                .background(.gray)
            }
    }

    var content: some View {
        Text("Hello!")
    }

    var bottomBar: some View {
        VStack {
            addressBar
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            HStack {
                ForEach(bottomBarItems) { item in
                    bottomBarButton(for: item)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
            }
        }
    }

    var addressBar: some View {
        HStack {
            Spacer()
            Text(viewModel.selectedTab?.url ?? "")
                .foregroundStyle(.white)
            Spacer()
            Button(
                action: {},
                label: {
                    Image(systemName: "arrow.clockwise")
                        .renderingMode(.template)
                        .foregroundStyle(.white)
                        .imageScale(.medium)
                }
            )
            .buttonStyle(.plain)
        }
        .padding(.vertical, .medium)
        .padding(.horizontal, .large)
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    var bottomBarItems: [BottomBarItem] {
        [
            BottomBarItem(imageName: "chevron.left", action: {}),
            BottomBarItem(imageName: "chevron.right", action: {}),
            BottomBarItem(imageName: "square.and.arrow.up", action: {}),
            BottomBarItem(imageName: "book", action: {}),
            BottomBarItem(imageName: "square.on.square", action: {})
        ]
    }

    func bottomBarButton(for item: BottomBarItem) -> some View {
        Button(
            action: item.action,
            label: {
                Image(systemName: item.imageName)
                    .renderingMode(.template)
                    .foregroundStyle(.white)
                    .imageScale(.large)
            }
        )
        .buttonStyle(.plain)
    }

    // MARK: - Types

    struct BottomBarItem: Identifiable {
        var imageName: String
        var action: () -> Void

        var id: String {
            imageName
        }
    }
}

#Preview {
    Mobile_ContentView()
}
