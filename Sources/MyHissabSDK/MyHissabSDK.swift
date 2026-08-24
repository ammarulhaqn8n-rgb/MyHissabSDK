import Foundation

/// Hosted webapp environment used to build the login URL.
public enum MyHissabEnvironment: Sendable {
    case production
    case staging

    var baseURL: String {
        switch self {
        case .production:
            return "https://app.myhisaab.pk"
        case .staging:
            return "https://staging.app.myhisaab.pk"
        }
    }
}

enum MyHissabURL {
    static func login(clientId: String, environment: MyHissabEnvironment) -> URL {
        var components = URLComponents(string: "\(environment.baseURL)/login")!
        components.queryItems = [
            URLQueryItem(name: "clientId", value: clientId)
        ]
        return components.url!
    }
}
