import 'dart:convert';
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
    if (!_isInitialized) {
      debugPrint('LiveActivityManager is not initialized');
    }

    return _isInitialized;
  }

  static int? _getIntFromSeconds(Duration? duration) =>
      (duration?.inSeconds ?? 0) >= 1 ? duration?.inSeconds : null;

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
      {required Map<String, dynamic> data, Duration? staleIn}) async {
    if (!_isAuthorizedCall) {
      return null;
    }

    await LiveActivityFile.prepareFiles(data);

    try {
      dynamic result = await _platform.invokeMethod(
        LiveActivityActionEnum.startLiveActivity.name,
        {
          "dataJsonString": jsonEncode(data),
          "staleIn": _getIntFromSeconds(staleIn)
        },
      );

      return StartLiveActivityResponse.fromDynamicMap(result);
    } catch (e) {
      debugPrint('Failed to start LiveActivity: $e');
      return null;
    }
  }

  static Future<void> updateLiveActivity(
      {required String activityId,
      required Map<String, dynamic> data,
      Duration? staleIn}) async {
    if (!_isAuthorizedCall) {
      return;
    }

    await LiveActivityFile.prepareFiles(data);

    try {
      await _platform.invokeMethod(
        LiveActivityActionEnum.updateLiveActivity.name,
        {
          "dataJsonString": jsonEncode(data),
          "staleIn": _getIntFromSeconds(staleIn),
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
      Duration? staleIn,
      Duration? endIn}) async {
    if (!_isAuthorizedCall) {
      return;
    }

    if (data != null) await LiveActivityFile.prepareFiles(data);

    try {
      await _platform.invokeMethod(
        LiveActivityActionEnum.endLiveActivity.name,
        {
          "dataJsonString": data != null ? jsonEncode(data) : null,
          "staleIn": _getIntFromSeconds(staleIn),
          "endIn": _getIntFromSeconds(endIn),
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
