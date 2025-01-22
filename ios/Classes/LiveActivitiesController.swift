//
//  LiveActivitiesController.swift
//  Pods
//
//  Created by Layhout Chea on 21/1/25.
//

import ActivityKit
import Flutter

public class LiveActivitiesController: LiveActivitiesControllerProtocol {
    public static func handleMethodCall(
        call: FlutterMethodCall, result: @escaping FlutterResult
    ) {
        let data = call.arguments as? [String: Any] ?? [String: Any]()

        if #available(iOS 16.1, *) {
            switch call.method {
            case LiveActivitiesActionEnum.isActivitiesAllowed.rawValue:
                LiveActivitiesController.isActivitiesAllowed(result: result)
                break
            case LiveActivitiesActionEnum.startLiveActivity.rawValue:
                LiveActivitiesController.startLiveActivity(
                    result: result, data: data)
                break
            case LiveActivitiesActionEnum.updateLiveActivity.rawValue:
                LiveActivitiesController.updateLiveActivity(
                    result: result, data: data)
                break
            case LiveActivitiesActionEnum.endLiveActivity.rawValue:
                LiveActivitiesController.endLiveActivity(
                    result: result, data: data)
                break
            case LiveActivitiesActionEnum.endAllLiveActivity.rawValue:
                LiveActivitiesController.endAllLiveActivity(result: result)
                break
            case LiveActivitiesActionEnum.getAllActivityIds.rawValue:
                LiveActivitiesController.getAllActivityIds(result: result)
                break
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    public static func isActivitiesAllowed(result: @escaping FlutterResult){
        LiveActivitiesManager.areLiveActivitiesEnabled(result: result)
    }
    
    public static func getAllActivityIds(result: @escaping FlutterResult) {
        LiveActivitiesManager.getAllActivityIds(result: result)
    }

    public static func startLiveActivity(
        result: @escaping FlutterResult, data: [String: Any]
    ) {
        let dataJsonString: String = data["dataJsonString"] as? String ?? ""
        let staleInMinutes: Int? = data["staleInMinutes"] as? Int ?? nil

        let initialState = LiveActivitiesAppAttributes.ContentState(dataJsonString: dataJsonString)

        LiveActivitiesManager.startLiveActivity(
            result: result, state: initialState, staleIn: staleInMinutes)
    }

    public static func updateLiveActivity(
        result: @escaping FlutterResult, data: [String: Any]
    ) {
        let activityId: String = data["activityId"] as? String ?? ""

        let dataJsonString: String = data["dataJsonString"] as? String ?? ""
        let staleInMinutes: Int? = data["staleInMinutes"] as? Int ?? nil

        let updatedState = LiveActivitiesAppAttributes.ContentState(dataJsonString: dataJsonString)

        LiveActivitiesManager.updateLiveActivity(
            result: result, activityId: activityId, state: updatedState,
            staleIn: staleInMinutes)
    }

    public static func endLiveActivity(
        result: @escaping FlutterResult, data: [String: Any]
    ) {
        let activityId: String = data["activityId"] as? String ?? ""

        let dataJsonString: String = data["dataJsonString"] as? String ?? ""
        let staleInMinutes: Int? = data["staleInMinutes"] as? Int ?? nil
        let endInSeconds: Int? = data["endInSecond"] as? Int ?? nil
        let dismissalPolicy: ActivityUIDismissalPolicy =
            endInSeconds != nil
            ? .after(
                Calendar.current.date(
                    byAdding: .second, value: endInSeconds!, to: Date())!)
            : .immediate

        let endedState = LiveActivitiesAppAttributes.ContentState(dataJsonString: dataJsonString)

        LiveActivitiesManager.endLiveActivity(
            result: result,
            activityId: activityId,
            state: endedState,
            staleIn: staleInMinutes,
            dismissalPolicy: dismissalPolicy)
    }
    
    public static func endAllLiveActivity(result: @escaping FlutterResult) {
        LiveActivitiesManager.endAllLiveActivity(result: result)
    }
}
