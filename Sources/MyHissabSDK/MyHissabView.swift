import SwiftUI

/// Embeds the MyHissab webapp in a WebView, passing `clientId` as a query parameter.
public struct MyHissabView: View {
    private let url: URL
    @State private var isLoading = true

    public init(clientId: String, environment: MyHissabEnvironment = .production) {
        self.url = MyHissabURL.login(clientId: clientId, environment: environment)
    }

    public var body: some View {
        ZStack {
            SDKWebView(url: url, isLoading: $isLoading)
                .ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.8))
            }
        }
    }
}
