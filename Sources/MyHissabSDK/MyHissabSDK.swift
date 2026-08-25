import Foundation

/// Hosted webapp environment used to build the login URL.
public enum MyHissabEnvironment: Sendable {
    case production
    case staging

    var baseURL: String {
        switch self {
        case .production:
            return "https://simosa.myhisaab.pk"
        case .staging:
            return "https://staging.simosa.myhisaab.pk"
        }
    }
}

enum MyHissabURL {
    /// Builds `https://<host>/login?customerId=<percent-encoded value>`.
    ///
    /// The customer id is percent-encoded with a strict allowed set (unreserved
    /// characters only), so spaces, `&`, `=`, `+`, `#`, `/`, `?`, emoji, and
    /// non-Latin text cannot break the URL. Length is not a concern: encoding
    /// is applied to the whole value regardless of size.
    static func login(customerId: String, environment: MyHissabEnvironment) -> URL {
        let loginURL = "\(environment.baseURL)/login"
        let trimmed = customerId.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return URL(string: loginURL)!
        }

        let encoded = percentEncoded(trimmed)

        return URL(string: "\(loginURL)?customerId=\(encoded)") ?? URL(string: loginURL)!
    }

    /// Percent-encodes every character outside the RFC 3986 unreserved set
    /// (`A-Z a-z 0-9 - . _ ~`).
    static func percentEncoded(_ value: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
    }
}
