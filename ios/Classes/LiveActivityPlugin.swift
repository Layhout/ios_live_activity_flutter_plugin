import ActivityKit
import Flutter
import UIKit

public class LiveActivityPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "live_activity_plugin", binaryMessenger: registrar.messenger()
        )
        let instance = LiveActivityPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(
        _ call: FlutterMethodCall, result: @escaping FlutterResult
    ) {
        LiveActivitiesController.handleMethodCall(call: call, result: result)
    }
}

public struct LiveActivitiesAppAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var dataJsonString: String
    }

    // Fixed non-changing properties about your activity go here!
    var id: String = UUID().uuidString
}
