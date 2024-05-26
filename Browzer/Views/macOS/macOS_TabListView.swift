//

import SwiftUI

struct macOS_TabListView: View {
    let tab: BrowserTab
    let isHovering: Bool

    var body: some View {
        HStack {
            CachedAsyncImage(
                url: URL(string: tab.faviconPath),
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
                .lineLimit(1)
            Spacer()
            if isHovering {
                Button(
                    action: {
                        // TODO: dismiss the tab
                    },
                    label: {
                        Image(systemName: "xmark")
                    }
                )
                .buttonStyle(.plain)
            }
        }
    }
}
