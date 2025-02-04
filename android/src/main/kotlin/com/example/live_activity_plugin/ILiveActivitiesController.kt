package com.example.live_activity_plugin

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

interface ILiveActivitiesController {
    var stateProcessor: ((dataJsonString: String?) -> ILiveActivityStateProcessor)?
    fun registerStateProcessor(sp: ((dataJsonString: String?) -> ILiveActivityStateProcessor))
    fun handleMethodCall(call: MethodCall, result: Result)
    fun startLiveActivity(call: MethodCall, result: Result)
    fun updateLiveActivity(call: MethodCall, result: Result)
    fun endLiveActivity(call: MethodCall, result: Result)
    fun endAllLiveActivity(result: Result)
    fun isActivitiesAllowed(result: Result)
    fun getAllActivityIds(result: Result)
}