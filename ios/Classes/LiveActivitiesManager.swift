//
//  LiveActivitiesManager.swift
//  Pods
//
//  Created by Layhout Chea on 21/1/25.
//

import ActivityKit
import Flutter
import Foundation

public class LiveActivitiesManager {
    private static func isAuthorizedCall(
        result: @escaping FlutterResult
    ) -> Bool {
        if #available(iOS 16.1, *) {
            return true
        }

        result(
            FlutterError(
                code: "FEATURE_NOT_SUPPORTED",
                message: "Live activity supported on 16.1 and higher",
                details: nil))

        return false
    }

    private static func getActivityContent(
        state: LiveActivitiesAppAttributes.ContentState?, staleIn: Int?
    ) -> ActivityContent<LiveActivitiesAppAttributes.ContentState>? {
        if state == nil {
            return nil
        }

        let staleDate =
            staleIn != nil
            ? Calendar.current.date(
                byAdding: .minute, value: staleIn!, to: Date.now) : nil

        return .init(state: state!, staleDate: staleDate)
    }

    public static func areLiveActivitiesEnabled(result: @escaping FlutterResult) {
        guard #available(iOS 16.1, *), !ProcessInfo.processInfo.isiOSAppOnMac
        else {
            result(false)
            return
        }

        result(ActivityAuthorizationInfo().areActivitiesEnabled)
        return
    }

    public static func startLiveActivity(
        result: @escaping FlutterResult,
        state: LiveActivitiesAppAttributes.ContentState, staleIn: Int?
    ) {
        if !isAuthorizedCall(result: result) {
            return
        }

        var activity: Activity<LiveActivitiesAppAttributes>
        let attributes = LiveActivitiesAppAttributes()
        let activityContent = getActivityContent(state: state, staleIn: staleIn)

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: activityContent!,
                pushType: .token)

            Task {
                for await pushToken in activity.pushTokenUpdates {
                    let token = pushToken.map { String(format: "%02x", $0) }
                        .joined()
                    result(["id": activity.id, "pushToken": token])
                }
            }
        } catch let error {
            result(
                FlutterError(
                    code: "LIVE_ACTIVITY_ERROR",
                    message: "Unable to initiate live activity",
                    details: error.localizedDescription))
        }

    }

    public static func updateLiveActivity(
        result: @escaping FlutterResult, activityId: String,
        state: LiveActivitiesAppAttributes.ContentState, staleIn: Int? = nil
    ) {
        if !isAuthorizedCall(result: result) {
            return
        }

        let activityContent = getActivityContent(state: state, staleIn: staleIn)

        Task {
            let activities = await MainActor.run {
                Activity<LiveActivitiesAppAttributes>.activities
            }
            guard
                let activity = activities.first(where: {
                    $0.id == activityId
                })
            else {
                result(
                    FlutterError(
                        code: "ACTIVITY_ERROR", message: "Activity not found",
                        details: nil))
                return
            }

            await activity.update(activityContent!)
            result(nil)
        }
    }

    public static func endLiveActivity(
        result: @escaping FlutterResult, activityId: String,
        state: LiveActivitiesAppAttributes.ContentState? = nil,
        staleIn: Int? = nil,
        dismissalPolicy: ActivityUIDismissalPolicy
    ) {
        if !isAuthorizedCall(result: result) {
            return
        }

        let activityContent = getActivityContent(state: state, staleIn: staleIn)

        Task {
            for activity in Activity<LiveActivitiesAppAttributes>.activities {
                if activityId == activity.id {
                    await activity.end(
                        activityContent, dismissalPolicy: dismissalPolicy)
                }
            } 

            result(nil)
        }
    }

    public static func endAllLiveActivity(result: @escaping FlutterResult) {
        if !isAuthorizedCall(result: result) {
            return
        }
        
        Task {
            for activity in Activity<LiveActivitiesAppAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            result(nil)
        }
    }
    
    public static func getAllActivityIds(result: @escaping FlutterResult) {
        if !isAuthorizedCall(result: result) {
            return
        }
        
        Task {
            var activityIds: [String] = []
            for activity in Activity<LiveActivitiesAppAttributes>.activities {
                activityIds.append(activity.id)
            }
            result(activityIds)
        }
    }
}
