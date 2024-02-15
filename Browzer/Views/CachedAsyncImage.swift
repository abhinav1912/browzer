// reference: https://github.com/lorenzofiamingo/swiftui-cached-async-image

import SwiftUI

struct CachedAsyncImage<Content>: View where Content: View {

    @State private var phase: AsyncImagePhase

    private let urlRequest: URLRequest?
    private let urlSession: URLSession
    private let content: (AsyncImagePhase) -> Content

    var body: some View {
        content(phase)
            .task(id: urlRequest, load)
    }

    init<ImageView: View, PlaceholderView: View>(
        url: URL?,
        urlCache: URLCache = .images,
        @ViewBuilder content: @escaping (Image) -> ImageView,
        @ViewBuilder placeholder: @escaping () -> PlaceholderView)
    where Content == _ConditionalContent<ImageView, PlaceholderView>
    {
        self.init(url: url, urlCache: urlCache) { phase in
            if let image = phase.image {
                content(image)
            } else {
                placeholder()
            }
        }
    }

    init(url: URL?, urlCache: URLCache = .images, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        var urlRequest: URLRequest?
        if let url {
            urlRequest = URLRequest(url: url)
        }
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = urlCache
        self.urlRequest = urlRequest
        self.urlSession =  URLSession(configuration: configuration)
        self.content = content

        self._phase = State(wrappedValue: .empty)
        do {
            if let urlRequest = urlRequest, let image = try cachedImage(from: urlRequest, cache: urlCache) {
                self._phase = State(wrappedValue: .success(image))
            }
        } catch {
            self._phase = State(wrappedValue: .failure(error))
        }
    }

    // MARK: Private

    @Sendable
        private func load() async {
            do {
                if let urlRequest = urlRequest {
                    let image = try await remoteImage(from: urlRequest, session: urlSession)
                    withAnimation {
                        phase = .success(image)
                    }
                } else {
                    withAnimation {
                        phase = .empty
                    }
                }
            } catch {
                withAnimation {
                    phase = .failure(error)
                }
            }
        }

    // MARK: Types

    private enum Error: Swift.Error {
        case invalidImageData
    }
}

// MARK: - Helpers

private extension CachedAsyncImage {
    private func remoteImage(from request: URLRequest, session: URLSession) async throws -> Image {
        let (data, _) = try await session.data(for: request)
        return try image(from: data)
    }

    private func cachedImage(from request: URLRequest, cache: URLCache) throws -> Image? {
        guard let cachedResponse = cache.cachedResponse(for: request) else { return nil }
        return try image(from: cachedResponse.data)
    }

    private func image(from data: Data) throws -> Image {
#if os(macOS)
        if let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        } else {
            throw Error.invalidImageData
        }
#else
        if let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            throw Error.invalidImageData
        }
#endif
    }
}
