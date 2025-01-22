import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live_activity_plugin/live_activity_plugin.dart';

class StartLiveActivityResponse {
  final String? id;
  final String? pushToken;

  StartLiveActivityResponse({required this.id, required this.pushToken});

  factory StartLiveActivityResponse.fromDynamicMap(Map<dynamic, dynamic> map) {
    return StartLiveActivityResponse(
      id: map['id'],
      pushToken: map['pushToken'],
    );
  }
}

class LiveActivityManager {
  LiveActivityManager._();

  static bool _isInitialized = false;
  static late MethodChannel _platform;
  static bool get _isAuthorizedCall {
    if (!Platform.isIOS) {
      // TODO: Explore alternative options for Android.
      debugPrint('Live Activity is currently supported only on iOS.');
      return false;
    }

    if (!_isInitialized) {
      debugPrint('LiveActivityManager is not initialized');
    }

    return _isInitialized;
  }

  static int? _getTimeInMinutes(Duration? staleInMinutes) =>
      (staleInMinutes?.inMinutes ?? 0) >= 1 ? staleInMinutes?.inMinutes : null;
  static int? _getTimeInSeconds(Duration? staleInMinutes) =>
      (staleInMinutes?.inSeconds ?? 0) >= 1 ? staleInMinutes?.inMinutes : null;

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      _platform = const MethodChannel("live_activity_plugin");
    } catch (e) {
      debugPrint('Failed to initialize LiveActivityManager: $e');
    } finally {
      _isInitialized = true;
    }
  }

  static Future<bool> isActivitiesAllowed() async {
    if (!_isAuthorizedCall) {
      return false;
    }

    try {
      return await _platform.invokeMethod<bool?>(
            LiveActivityActionEnum.isActivitiesAllowed.name,
          ) ??
          false;
    } catch (e) {
      debugPrint('Failed to check if LiveActivity is allowed: $e');
      return false;
    }
  }

  static Future<List<String>> getAllActivityIds() async {
    if (!_isAuthorizedCall) {
      return [];
    }

    try {
      return await _platform.invokeMethod<List<String>?>(
            LiveActivityActionEnum.isActivitiesAllowed.name,
          ) ??
          [];
    } catch (e) {
      debugPrint('Failed to get all activity ids: $e');
      return [];
    }
  }

  static Future<StartLiveActivityResponse?> startLiveActivity(
      {Map<String, dynamic>? data, Duration? staleInMinutes}) async {
    if (!_isAuthorizedCall) {
      return null;
    }

    try {
      dynamic result = await _platform.invokeMethod(
        LiveActivityActionEnum.startLiveActivity.name,
        {...(data ?? {}), "staleInMinutes": _getTimeInMinutes(staleInMinutes)},
      );

      return StartLiveActivityResponse.fromDynamicMap(result);
    } catch (e) {
      debugPrint('Failed to start LiveActivity: $e');
      return null;
    }
  }

  static Future<void> updateLiveActivity(
      {required String activityId,
      Map<String, dynamic>? data,
      Duration? staleInMinutes}) async {
    if (!_isAuthorizedCall) {
      return;
    }

    try {
      await _platform.invokeMethod(
        LiveActivityActionEnum.updateLiveActivity.name,
        {
          ...(data ?? {}),
          "staleInMinutes": _getTimeInMinutes(staleInMinutes),
          "activityId": activityId
        },
      );
    } catch (e) {
      debugPrint('Failed to update LiveActivity: $e');
    }
  }

  static Future<void> endLiveActivity(
      {required String activityId,
      Map<String, dynamic>? data,
      Duration? staleInMinutes,
      Duration? endInSecond}) async {
    if (!_isAuthorizedCall) {
      return;
    }

    try {
      await _platform.invokeMethod(
        LiveActivityActionEnum.endLiveActivity.name,
        {
          ...(data ?? {}),
          "staleInMinutes": _getTimeInMinutes(staleInMinutes),
          "endInSecond": _getTimeInSeconds(endInSecond),
          "activityId": activityId,
        },
      );
    } catch (e) {
      debugPrint('Failed to end LiveActivity: $e');
    }
  }

  static Future<void> endAllLiveActivity() async {
    if (!_isAuthorizedCall) {
      return;
    }

    try {
      await _platform
          .invokeMethod(LiveActivityActionEnum.endAllLiveActivity.name);
    } catch (e) {
      debugPrint('Failed to end all LiveActivity: $e');
    }
  }
}
