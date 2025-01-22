//
//  LiveActivitiesControllerProtocol.swift
//  Pods
//
//  Created by Layhout Chea on 21/1/25.
//

import Flutter

public protocol LiveActivitiesControllerProtocol {
    static func handleMethodCall(
        call: FlutterMethodCall, result: @escaping FlutterResult)
    static func startLiveActivity(
        result: @escaping FlutterResult, data: [String: Any])
    static func updateLiveActivity(
        result: @escaping FlutterResult, data: [String: Any])
    static func endLiveActivity(
        result: @escaping FlutterResult, data: [String: Any])
    static func isActivitiesAllowed(result: @escaping FlutterResult)
    static func getAllActivityIds(result: @escaping FlutterResult)
}
