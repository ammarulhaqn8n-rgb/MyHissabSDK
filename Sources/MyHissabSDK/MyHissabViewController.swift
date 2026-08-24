import SwiftUI
import UIKit

/// UIKit wrapper that presents the MyHissab webapp with a `clientId` query parameter.
public final class MyHissabViewController: UIViewController {
    private let clientId: String
    private let environment: MyHissabEnvironment

    public init(clientId: String, environment: MyHissabEnvironment = .production) {
        self.clientId = clientId
        self.environment = environment
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let hosted = UIHostingController(
            rootView: MyHissabView(clientId: clientId, environment: environment)
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
