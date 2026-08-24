# MyHissab SDK

iOS Swift Package that embeds the MyHissab webapp in a `WKWebView`. Pass a `clientId`; the SDK opens:

`https://app.myhisaab.pk/login?clientId=<value>`

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

MyHissabView(clientId: "your-client-id")
```

Staging:

```swift
MyHissabView(clientId: "your-client-id", environment: .staging)
```

### UIKit

```swift
import MyHissabSDK

let viewController = MyHissabViewController(clientId: "your-client-id")
present(viewController, animated: true)
```

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
