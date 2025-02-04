package com.example.live_activity_plugin

import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

@RequiresApi(Build.VERSION_CODES.R)
class LiveActivitiesController {
    companion object : ILiveActivitiesController {
        override var stateProcessor: ((dataJsonString: String?) -> ILiveActivityStateProcessor)? =
            null

        override fun registerStateProcessor(sp: ((dataJsonString: String?) -> ILiveActivityStateProcessor)) {
            stateProcessor = sp
        }

        override fun handleMethodCall(call: MethodCall, result: Result) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                when (call.method) {
                    LiveActivitiesAction.IS_ACTIVITIES_ALLOWED.value -> isActivitiesAllowed(
                        result
                    )

                    LiveActivitiesAction.START_LIVE_ACTIVITY.value -> startLiveActivity(
                        call,
                        result
                    )

                    LiveActivitiesAction.UPDATE_LIVE_ACTIVITY.value -> updateLiveActivity(
                        call,
                        result
                    )

                    LiveActivitiesAction.END_LIVE_ACTIVITY.value -> endLiveActivity(
                        call,
                        result
                    )

                    LiveActivitiesAction.END_ALL_LIVE_ACTIVITY.value -> endAllLiveActivity(
                        result
                    )

                    LiveActivitiesAction.GET_ALL_ACTIVITY_IDS.value -> getAllActivityIds(
                        result
                    )

                    else -> {
                        result.notImplemented()
                    }
                }
            } else {
                result.error(
                    "FEATURE_NOT_SUPPORTED",
                    "this version of Android is not supported",
                    null
                )
            }
        }

        override fun startLiveActivity(call: MethodCall, result: Result) {
            val dataJsonString: String = call.argument<String>("dataJsonString") ?: ""
            val state = stateProcessor?.invoke(dataJsonString)
            val staleIn: Int? = call.argument<Int>("staleIn")

            if (state == null) {
                result.error("STATE_PROCESSOR_ERROR", "State processor is not registered", null)
                return
            }

            LiveActivitiesManager.startLiveActivity(result, state, staleIn)
        }

        override fun updateLiveActivity(call: MethodCall, result: Result) {
            val activityId: String = call.argument<String>("activityId") ?: ""
            val dataJsonString: String = call.argument<String>("dataJsonString") ?: ""
            val state = stateProcessor?.invoke(dataJsonString)
            val staleIn: Int? = call.argument<Int>("staleIn")

            if (state == null) {
                result.error("STATE_PROCESSOR_ERROR", "State processor is not registered", null)
                return
            }

            LiveActivitiesManager.updateLiveActivity(result, activityId, state, staleIn)
        }

        override fun endLiveActivity(call: MethodCall, result: Result) {
            val activityId: String = call.argument<String>("activityId") ?: ""
            val dataJsonString: String = call.argument<String>("dataJsonString") ?: ""
            var state: ILiveActivityStateProcessor? = null
            if (dataJsonString.isNotBlank()) {
                state = stateProcessor?.invoke(dataJsonString)
            }
            val staleIn: Int? = call.argument<Int>("staleIn")
            val endIn: Int? = call.argument<Int>("endIn")

            LiveActivitiesManager.endLiveActivity(result, activityId, state, staleIn, endIn)
        }

        override fun endAllLiveActivity(result: Result) {
            LiveActivitiesManager.endAllLiveActivity(result)
        }

        override fun isActivitiesAllowed(result: Result) {
            LiveActivitiesManager.areLiveActivitiesEnabled(result)
        }

        override fun getAllActivityIds(result: Result) {
            LiveActivitiesManager.getAllActivityIds(result)
        }
    }
}