# IOS Live Activity Flutter Plugin

This is **NOT** a plug-and-play plugin. It requires a **NATIVE** level of integration and currently supports only **iOS**.

## Table of Contents

- [Requirement](#requirement)
- [Initialization](#initialization)
  - [Flutter](#flutter)  
  - [Native](#native)  
- [Usage](#usage)
  - [Initialize](#initialize)
  - [Start an activity](#start-an-activity)
- [Documentation](#documentation)
- [Modificaion Note](#modification-note)
- [Live Activity Limitation](#live-activity-limitation)

## Requirement

- iOS >= 16.1

## Initialization

### Flutter

Add the plugin to your `pubspec.yaml` file and run `flutter pub get`.

```yaml
unified_live_activity:
    path: ../unified_live_activity
```

### Native

- Open `ios/Runner.xcworkspace` in Xcode
- Select `File` -> `New` -> `Target...`
[image or video here...]
- Search for `Widget Extension` and click **Next**.
[image or video here...]
- Set the **Product Name** to exactly LiveActivitiesApp.
- Make sure only `Include Live Activity` is checked for Bundle Identifier.
- Click on Finish.
- When Clicking Finish, an alert will appear, you will need to click on cancel.
[image or video here...]
- Add the `Push Notifications`, `App Group` and `Background Modes` capabilities for the main Runner app
- Make sure only `Remote Notifications` is checked for `Background Modes`
[image or video here...]
- Go to `Runner/info` and add `Support Live Activity` key with value `YES`
[image or video here...]
- Copy code inside `live_activity_plugin/example/ios/LiveActivitiesApp/LiveActivitiesAppLiveActivity.swift` and paste inside `your_app/ios/LiveActivitiesApp/LiveActivitiesAppLiveActivity.swift` **(DO NOT COPY FILE)**. The code contains predefine ui and data that is writen with [**SwiftUI**](https://developer.apple.com/xcode/swiftui/). To change UI and passed/consumable data, please prefer to [Modificaion Note](#modification-note)
[image or video here...]
- Open `Inspectors` -> `File Inspector`, at `Target Membership` click **Plus** icon and check `Runner`. Click **Save**
[image or video here...]
- Drag and drop the required assets into `your_app/ios/LiveActivitiesApp/Assets`
[image or video here...]

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

To modify the UI of your Live Activity, you need to write it using [SwiftUI](https://developer.apple.com/xcode/swiftui/). The location where you can update the UI is inside `your_app/ios/LiveActivitiesApp/LiveActivitiesAppLiveActivity.swift` at `struct LiveActivitiesAppLiveActivity: Widget`. Be sure to follow the design [guidelines](https://developer.apple.com/design/human-interface-guidelines/live-activities) when creating your Live Activity. For data, there is a data model in the same file called `LiveActivityData` at `struct LiveActivityData: Decodable`. Ensure that the data sent from Flutter matches the structure of `LiveActivityData`; otherwise, an error will occur. A utility struct `DataProcess` is provided to simplify reading your data.

## Live Activity Limitation

Read [Constraints](https://www.schibsted.pl/blog/creating-real-time-news-experience-with-ios-live-activities/#:~:text=of%20their%20day.-,Constraints,-Given%20that%20we%E2%80%99re)
