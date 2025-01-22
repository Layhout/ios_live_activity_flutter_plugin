// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';

// import 'live_activity_plugin_platform_interface.dart';

// /// An implementation of [LiveActivityPluginPlatform] that uses method channels.
// class MethodChannelLiveActivityPlugin extends LiveActivityPluginPlatform {
//   /// The method channel used to interact with the native platform.
//   @visibleForTesting
//   final methodChannel = const MethodChannel('live_activity_plugin');

//   @override
//   Future<String?> getPlatformVersion() async {
//     final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
//     return version;
//   }
// }
