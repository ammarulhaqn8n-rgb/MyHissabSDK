# MyHissab SDK

iOS Swift Package that embeds the MyHissab webapp in a `WKWebView`. Pass a `customerId`; the SDK opens:

`https://simosa.myhisaab.pk/login?customerId=<url-encoded value>`

The customer id is percent-encoded by the SDK, so spaces and special characters (`&`, `=`, `+`, `#`, `/`, `?`, emoji, non-Latin text) cannot break the URL. Leading and trailing whitespace is trimmed; if the value is empty, the SDK opens `/login` without the parameter.

Requires iOS 15+.

## Install

In Xcode: **File → Add Package Dependencies…** and paste:

```
https://github.com/roamiebuddy-creator/MyHissabSDK
```

Select the `MyHissabSDK` product and add it to your app target.

## Usage

### SwiftUI

```swift
import MyHissabSDK

MyHissabView(customerId: "your-customer-id")
```

Staging:

```swift
MyHissabView(customerId: "your-customer-id", environment: .staging)
```

### UIKit

```swift
import MyHissabSDK

let viewController = MyHissabViewController(customerId: "your-customer-id")
present(viewController, animated: true)
```

The older `clientId:` initializers still compile but are deprecated; use `customerId:`.

## Info.plist

If the webapp uses camera, microphone, or the photo library, add these keys to **your host app’s** Info.plist (the SDK cannot add them for you):

- `NSCameraUsageDescription`
- `NSMicrophoneUsageDescription`
- `NSPhotoLibraryUsageDescription`

## Copy into Info.plist as source

You can paste the keys directly instead of adding them one by one in Xcode’s property list editor.

1. In the Project Navigator, right-click your app’s `Info.plist`.
2. Choose **Open As → Source Code**.
3. Copy the keys below and paste them **inside** the root `<dict>…</dict>` (next to your other keys). Do not wrap them in another `<plist>` or `<dict>`.

```xml
<key>NSCameraUsageDescription</key>
<string>MyHissab needs camera access to capture receipts and documents.</string>
<key>NSMicrophoneUsageDescription</key>
<string>MyHissab needs microphone access to record audio.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>MyHissab needs photo library access to attach images.</string>
```

If your `Info.plist` is already in JSON (some Xcode projects use this instead of XML), paste these keys into the root object:

```json
{
  "NSCameraUsageDescription": "MyHissab needs camera access to capture receipts and documents.",
  "NSMicrophoneUsageDescription": "MyHissab needs microphone access to record audio.",
  "NSPhotoLibraryUsageDescription": "MyHissab needs photo library access to attach images."
}
```

You can change the string values to match your app, but the keys must stay exactly as written.
