//

import SwiftUI

#if os(macOS)
typealias WebViewRepresentable = NSViewRepresentable
#elseif os(iOS)
typealias WebViewRepresentable = UIViewRepresentable
#endif
