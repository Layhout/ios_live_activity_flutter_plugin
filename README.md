# IOS Live Activity Flutter Plugin

This is **NOT** a plug-and-play plugin. It requires a **NATIVE** level of integration for **iOS**.

## Table of Contents

- [Requirement](#requirement)
- [Initialization](#initialization)
  - [Flutter](#flutter)  
  - [Native](#native)
    - [iOS](#ios)
    - [Android](#android)
- [Usage](#usage)
  - [Initialize](#initialize)
  - [Start an activity](#start-an-activity)
- [Documentation](#documentation)
- [Modificaion Note](#modification-note)
  - [iOS](#ios-1)
  - [Android](#android-1)
- [Live Activity Limitation](#live-activity-limitation)

## Requirement

- iOS >= 16.1
- Android >= 8.0

## Initialization

### Flutter

Add the plugin to your `pubspec.yaml` file and run `flutter pub get`.

```yaml
flutter_live_activities:
    path: ../flutter_live_activities
```

### Native

#### iOS

- Open `ios/Runner.xcworkspace` in Xcode
- Select `File` -> `New` -> `Target...`
- Search for `Widget Extension` and click **Next**.
- Set the **Product Name** to exactly LiveActivitiesApp.
- Make sure only `Include Live Activity` is checked for Bundle Identifier.
- Click on Finish.
- When Clicking Finish, an alert will appear, you will need to click on cancel.
- Add the `Push Notifications`, `App Group` and `Background Modes` capabilities for the main Runner app
- Make sure only `Remote Notifications` is checked for `Background Modes`
- Go to `Runner/info` and add `Support Live Activity` key with value `YES`
- Copy code inside `live_activity_plugin/example/ios/LiveActivitiesApp/LiveActivitiesAppLiveActivity.swift` and paste inside `your_app/ios/LiveActivitiesApp/LiveActivitiesAppLiveActivity.swift` **(DO NOT COPY FILE)**. The code contains predefine ui and data that is writen with [**SwiftUI**](https://developer.apple.com/xcode/swiftui/). To change UI and passed/consumable data, please prefer to [Modificaion Note](#modification-note)
- Open `Inspectors` -> `File Inspector`, at `Target Membership` click **Plus** icon and check `Runner`. Click **Save**
- Drag and drop the required assets into `your_app/ios/LiveActivitiesApp/Assets`

#### Android

- Add premission `android.permission.POST_NOTIFICATIONS` into `AndroidManifest.xml`

```xml
<manifest ...>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <application ...>
        ...
    </application>
</manifest>
```

- Refer to the [Flutter guide](https://docs.flutter.dev/platform-integration/platform-channels) for setting up the native-level initializer
- Create a state processor/transformer class to read data from the Flutter layer and generate Live Activity layouts. Ensure that you implement the `ILiveActivityStateProcessor` interface from the plugin.
- Call `LiveActivitiesController.registerStateProcessor` and return your state processoring class inside the `configureFlutterEngine` function. For a better understanding, check the `live_activity_plugin/example/android` directory
- Create a `layout` folder and add two layouts for your Live Activity UI—one for the minimized state and another for the expanded state.
- Drag and drop the required assets into the `drawable` folder.
- To change UI and passed/consumable data, please prefer to Modificaion Note

## Usage

### Initialize

Initialize `LiveActivityManager` is required.

```dart
await LiveActivityManager.init();
```

### Start an activity

Start an activity by calling `LiveActivityManager.startLiveActivity()`. The method returns a StartLiveActivityResponse, which contains the following:

- Activity ID (`id`): Used to control the started activity.
- Push Notification Token (`pushToken`): Used to update the Live Activity remotely.

```dart
StartLiveActivityResponse liveActivityResponse = 
    await LiveActivityManager.startLiveActivity(data: {
        "title": "Order Placed",
        "description": "Your order has been placed",
        "step": 0,
        "distance": 3,
    });
```

Notice that the passed data is as follows:

```json
{
    "title": "Order Placed",
    "description": "Your order has been placed",
    "step": 0,
    "distance": 3
}
```

This data is predefined and processed inside `your_app/ios/LiveActivitiesApp/LiveActivitiesAppLiveActivity.swift`. Any additional data passed will also be processed accordingly. To customize how the data is processed, please refer to the [Modificaion Note](#modification-note) for guidance.

### Update an activity

```dart
await LiveActivityManager.updateLiveActivity(
    activityId: liveActivityResponse.id,
    data: {
        "title": "Order Complete",
        "description": "Thank you for ordering with us! Enjoy!",
        "step": 3,
        "distance": 3,
    }
);
```

### End an activity

After ending the activity, the Live Activity can remain visible on the screen for up to 4 hours before it disappears, but we can change how long Live Activity lasts after ended with `endIn`

```dart
await LiveActivityManager.endLiveActivity(
    activityId: liveActivityResponse.id,
    endIn: const Duration(seconds: 5),
);
```

## Documentation

### LiveActivityManager

| Name                     | Description                                                                                                               | Returned value                                                  |
|--------------------------|---------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------|
| `.init()`                | Initialize the plugin to establish a Method Channel, enabling seamless communication between Flutter and the native code. | `Future<void>`                                                  |
| `.isActivitiesAllowed()` | Check if the user has granted permission to display Live Activities for the current app.                                  | `Future<bool>`. `true` if permission granted, otherwise `false` |
| `.getAllActivityIds()`   | Retrieve all IDs of the activities created.                                                                               | `Future<List<String>>`. A list of `String` ids.                 |
| `.startLiveActivity()`   | Create and start a Live Activity.                                                                                         | `Future<StartLiveActivityResponse?>`                           |
| `.updateLiveActivity()`  | Update a Live Activity by providing `activityId`.                                                                         | `Future<void>`                                                  |
| `.endLiveActivity()`     | End a Live Activity by providing `activityId`.                                                                            | `Future<void>`                                                  |
| `.endAllLiveActivity()`  | End all Live Activities.                                                                                                  | `Future<void>`                                                  |

### StartLiveActivityResponse

| Name                | Description                                                                                        |
|---------------------|----------------------------------------------------------------------------------------------------|
| `String? id`        | A `String` UUID generated in Swift to uniquely identify a Live Activity.                           |
| `String? pushToken` | The token used to send ActivityKit push notifications to a Live Activity, enabling remote updates. |

### LiveActivityFile

There are several ways to share files from Flutter to Swift. One approach is to convert the files into a Base64 string and pass them as arguments through a Method Channel.

| Name                          | Description                                                                                        | Returned Value   |
|-------------------------------|----------------------------------------------------------------------------------------------------|------------------|
| `.fromAsset()`                | Retrieve the file from the provided path and convert it to a Base64 string.                        | `Future<void>`   |
| `.fromUrl()`                  | Download the file from the remote source using the provided URL and convert it to a Base64 string. | `Future<void>`   |
| `Future<String> base64String` | A getter method to retrieve the Base64 string.                                                     | `Future<String>` |
| `.prepareFiles()`             | A static method to prepare files before passing them to the Method Channel.                        | `Future<void>`   |

### LiveActivityImageFileOptions

Used to tell `LiveActivityFile` to resize and compress the image.

## Modification Note

### iOS

To modify the UI of your Live Activity, you need to write it using [SwiftUI](https://developer.apple.com/xcode/swiftui/). The location where you can update the UI is inside `your_app/ios/LiveActivitiesApp/LiveActivitiesAppLiveActivity.swift` at `struct LiveActivitiesAppLiveActivity: Widget`. Be sure to follow the design [guidelines](https://developer.apple.com/design/human-interface-guidelines/live-activities) when creating your Live Activity. For data, there is a data model in the same file called `LiveActivityData` at `struct LiveActivityData: Decodable`. Ensure that the data sent from Flutter matches the structure of `LiveActivityData`; otherwise, an error will occur. A utility struct `DataProcess` is provided to simplify reading your data.

### Android

To customize the UI of your Live Activity, define it using [XML](https://developer.android.com/develop/ui/views/layout/declaring-layout). Each time your Flutter app calls the Live Activity plugin API, the state processor class is triggered, allowing you to modify or transform the data as needed. Be sure to follow the design [guidelines](https://developer.android.com/develop/ui/views/notifications/custom-notification) when creating your Live Activity.

## Live Activity Limitation

Read [iOS Constraints](https://www.schibsted.pl/blog/creating-real-time-news-experience-with-ios-live-activities/#:~:text=of%20their%20day.-,Constraints,-Given%20that%20we%E2%80%99re)
Read [Android Caution](https://developer.android.com/develop/ui/views/notifications/custom-notification#:~:text=for%20the%20notification.-,Caution,-%3A%20When%20using)

## Other

- [iOS setup full video](https://wingmoneycom-my.sharepoint.com/:v:/g/personal/layhout_chea_wingbank_com_kh/EXpPPq_gH09JvaazPGWVeBABMQhR9PqkuEL_zsdgl-eDKw?nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJPbmVEcml2ZUZvckJ1c2luZXNzIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXciLCJyZWZlcnJhbFZpZXciOiJNeUZpbGVzTGlua0NvcHkifX0&e=BxsIXG)
