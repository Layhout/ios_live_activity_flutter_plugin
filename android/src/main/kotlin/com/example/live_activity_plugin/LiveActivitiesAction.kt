package com.example.live_activity_plugin

enum class LiveActivitiesAction(var value: String) {
    IS_ACTIVITIES_ALLOWED("isActivitiesAllowed"),
    START_LIVE_ACTIVITY("startLiveActivity"),
    UPDATE_LIVE_ACTIVITY("updateLiveActivity"),
    END_LIVE_ACTIVITY("endLiveActivity"),
    END_ALL_LIVE_ACTIVITY("endAllLiveActivity"),
    GET_ALL_ACTIVITY_IDS("getAllActivityIds"),
}