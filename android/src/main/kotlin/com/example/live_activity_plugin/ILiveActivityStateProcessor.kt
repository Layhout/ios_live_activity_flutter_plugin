package com.example.live_activity_plugin

import android.content.Context
import android.widget.RemoteViews
import org.json.JSONObject

interface ILiveActivityStateProcessor {
    var jsonObj: JSONObject?
    fun getLayout(context: Context): RemoteViews
    fun getLayoutExpanded(context: Context): RemoteViews
}