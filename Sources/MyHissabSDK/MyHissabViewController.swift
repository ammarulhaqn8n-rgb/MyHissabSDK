import SwiftUI
import UIKit

/// UIKit wrapper that presents the MyHissab webapp with a `customerId` query parameter.
///
/// Loads `https://simosa.myhisaab.pk/login?customerId=<percent-encoded value>`.
public final class MyHissabViewController: UIViewController {
    private let customerId: String
    private let environment: MyHissabEnvironment

    public init(customerId: String, environment: MyHissabEnvironment = .production) {
        self.customerId = customerId
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, deprecated, renamed: "init(customerId:environment:)")
    public convenience init(clientId: String, environment: MyHissabEnvironment = .production) {
        self.init(customerId: clientId, environment: environment)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let hosted = UIHostingController(
            rootView: MyHissabView(customerId: customerId, environment: environment)
        )
        addChild(hosted)
        hosted.view.translatesAutoresizingMaskIntoConstraints = false
        hosted.view.backgroundColor = .white
        view.addSubview(hosted.view)
        NSLayoutConstraint.activate([
            hosted.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosted.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosted.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosted.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hosted.didMove(toParent: self)
    }
}
