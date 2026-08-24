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

If the webapp uses camera or the photo library, add these keys to **your host app’s** Info.plist (the SDK cannot add them for you):

- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`
