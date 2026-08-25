import SwiftUI

/// Embeds the MyHissab webapp in a WebView, passing `customerId` as a query parameter.
///
/// Loads `https://simosa.myhisaab.pk/login?customerId=<percent-encoded value>`.
public struct MyHissabView: View {
    private let url: URL
    @State private var isLoading = true

    public init(customerId: String, environment: MyHissabEnvironment = .production) {
        self.url = MyHissabURL.login(customerId: customerId, environment: environment)
    }

    @available(*, deprecated, renamed: "init(customerId:environment:)")
    public init(clientId: String, environment: MyHissabEnvironment = .production) {
        self.init(customerId: clientId, environment: environment)
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
