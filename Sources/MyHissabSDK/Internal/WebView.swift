import SwiftUI
import UIKit
import WebKit

struct SDKWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.userContentController.add(context.coordinator, name: "downloadHandler")
        webConfiguration.userContentController.add(context.coordinator, name: "cameraHandler")

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        context.coordinator.webView = webView

        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }

        webView.load(URLRequest(url: url, timeoutInterval: 30.0))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate, WKScriptMessageHandler, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: SDKWebView
        weak var webView: WKWebView?

        init(_ parent: SDKWebView) {
            self.parent = parent
        }

        // MARK: - WKScriptMessageHandler

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "downloadHandler",
               let body = message.body as? [String: String],
               let urlString = body["url"],
               let downloadURL = URL(string: urlString),
               let fileName = body["fileName"] {

                DispatchQueue.main.async { self.parent.isLoading = true }

                URLSession.shared.dataTask(with: downloadURL) { [weak self] data, _, error in
                    DispatchQueue.main.async { self?.parent.isLoading = false }
                    guard let data = data, error == nil else { return }

                    let fileManager = FileManager.default
                    let destinationURL = fileManager.temporaryDirectory.appendingPathComponent(fileName)

                    if fileManager.fileExists(atPath: destinationURL.path) {
                        try? fileManager.removeItem(at: destinationURL)
                    }

                    do {
                        try data.write(to: destinationURL)
                        self?.presentShareSheet(for: destinationURL)
                    } catch {}
                }.resume()
            }

            if message.name == "cameraHandler" {
                presentMediaSelectionMenu()
            }
        }

        // MARK: - Media Selection

        private func presentMediaSelectionMenu() {
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Select Photo",
                    message: "Choose where to pick your photo from.",
                    preferredStyle: .actionSheet
                )

                alert.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                    self?.presentCameraSheet()
                })
                alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
                    self?.presentGalleryPicker()
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

                self.present(alert)
            }
        }

        private func presentCameraSheet() {
            DispatchQueue.main.async {
                let cameraVC = CameraViewController()
                cameraVC.onImageCaptured = { [weak self] base64Image in
                    self?.sendImageToWeb(base64String: base64Image)
                }

                if #available(iOS 15.0, *) {
                    if let sheet = cameraVC.sheetPresentationController {
                        sheet.detents = [.medium(), .large()]
                        sheet.prefersGrabberVisible = true
                        sheet.preferredCornerRadius = 24
                    }
                }

                self.present(cameraVC)
            }
        }

        private func presentGalleryPicker() {
            DispatchQueue.main.async {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = false
                self.present(imagePicker)
            }
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true)
            guard let image = info[.originalImage] as? UIImage,
                  let jpegData = image.jpegData(compressionQuality: 0.6) else { return }
            sendImageToWeb(base64String: jpegData.base64EncodedString())
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }

        private func sendImageToWeb(base64String: String) {
            DispatchQueue.main.async {
                let js = "window.receiveCameraImage('data:image/jpeg;base64,\(base64String)');"
                self.webView?.evaluateJavaScript(js) { _, error in
                    if let error = error {
                        print("JS Injection Error: \(error.localizedDescription)")
                    }
                }
            }
        }

        // MARK: - WebKit Download & Lifecycle

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
            if navigationAction.shouldPerformDownload {
                decisionHandler(.download, preferences)
            } else {
                decisionHandler(.allow, preferences)
            }
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if navigationResponse.canShowMIMEType {
                decisionHandler(.allow)
            } else {
                decisionHandler(.download)
            }
        }

        func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
            download.delegate = self
        }

        func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
            download.delegate = self
        }

        func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
            let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(suggestedFilename)
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try? FileManager.default.removeItem(at: destinationURL)
            }
            completionHandler(destinationURL)
        }

        func downloadDidFinish(_ download: WKDownload) {
            parent.isLoading = false
            if let fileURL = download.progress.userInfo[.fileURLKey] as? URL {
                presentShareSheet(for: fileURL)
            }
        }

        func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
            decisionHandler(.grant)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }

        private func presentShareSheet(for fileURL: URL) {
            DispatchQueue.main.async {
                let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                self.present(activityVC)
            }
        }

        private func present(_ viewController: UIViewController) {
            guard let presenter = presentingViewController() else { return }

            if let popover = viewController.popoverPresentationController {
                popover.sourceView = presenter.view
                popover.sourceRect = CGRect(
                    x: presenter.view.bounds.midX,
                    y: presenter.view.bounds.midY,
                    width: 0,
                    height: 0
                )
                popover.permittedArrowDirections = []
            }

            presenter.present(viewController, animated: true)
        }

        private func presentingViewController() -> UIViewController? {
            var responder: UIResponder? = webView
            while let current = responder {
                if let viewController = current as? UIViewController {
                    return viewController.topMostPresented()
                }
                responder = current.next
            }

            let scenes = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter { $0.activationState == .foregroundActive }

            if let root = scenes.first?.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                return root.topMostPresented()
            }

            return nil
        }
    }
}

private extension UIViewController {
    func topMostPresented() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostPresented()
        }
        if let navigation = self as? UINavigationController, let visible = navigation.visibleViewController {
            return visible.topMostPresented()
        }
        if let tab = self as? UITabBarController, let selected = tab.selectedViewController {
            return selected.topMostPresented()
        }
        return self
    }
}
