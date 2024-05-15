//

import SwiftUI

struct Mobile_ContentView: View {
    @State var url = "google.com" // temporary, will be replaced with VM

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
            TextField(text: $url) {
                Text("Enter the url")
            }
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            HStack {
                ForEach(bottomBarItems) { item in
                    bottomBarButton(for: item)
                        .frame(minWidth: 0, maxWidth: .infinity)
//                        .frame(width: 40, height: 40)
                }
            }
        }
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
