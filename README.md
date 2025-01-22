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

## Requirement

- iOS >= 16.1

## Initialization

### Flutter

Add plugin into `pubspec.yaml` and run `flutter pub get`

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
        "title": "Order Placed",
        "description": "Your order has been placed",
        "step": 0,
        "distance": 3,
    }
);
```

### End an activity

After ending the activity, the Live Activity can remain visible on the screen for up to 4 hours before it disappears.

```dart
await LiveActivityManager.endLiveActivity(
    activityId: liveActivityResponse.id,
    endIn: const Duration(seconds: 5),
);
```

## Documentation

## Modification Note
