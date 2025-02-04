package com.example.live_activity_plugin

import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** LiveActivityPlugin */
class LiveActivityPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  @RequiresApi(Build.VERSION_CODES.R)
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "live_activity_plugin")
    channel.setMethodCallHandler(this)

    LiveActivitiesManager.init(flutterPluginBinding.applicationContext)
  }

  @RequiresApi(Build.VERSION_CODES.R)
  override fun onMethodCall(call: MethodCall, result: Result) {
    LiveActivitiesController.handleMethodCall(call, result)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
