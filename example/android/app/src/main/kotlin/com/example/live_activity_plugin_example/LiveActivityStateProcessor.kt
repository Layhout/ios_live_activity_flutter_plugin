package com.example.live_activity_plugin_example

import android.content.Context
import android.os.Build
import android.view.WindowManager
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import com.example.live_activity_plugin.ILiveActivityStateProcessor
import org.json.JSONException
import org.json.JSONObject
import kotlin.math.round

class LiveActivityStateProcessor(jsonString: String) : ILiveActivityStateProcessor {
    override var jsonObj: JSONObject? = try {
        JSONObject(jsonString)
    } catch (e: JSONException) {
        null
    }

    override fun getLayout(context: Context): RemoteViews {
        // Prepare your layout for Live Activity

        val liveActivityLayout = RemoteViews(context.packageName, R.layout.live_activity)

        // make change as you please
        liveActivityLayout.setTextViewText(R.id.live_activity_title, getStringFromJson("title"))
        liveActivityLayout.setTextViewText(
            R.id.live_activity_description,
            getStringFromJson("description")
        )

        return liveActivityLayout
    }

    @RequiresApi(Build.VERSION_CODES.R)
    override fun getLayoutExpanded(context: Context): RemoteViews {
        // Prepare your expended layout for Live Activity

        val liveActivityLayoutExpanded =
            RemoteViews(context.packageName, R.layout.live_activity_expanded)

        // make change as you please
        liveActivityLayoutExpanded.setTextViewText(
            R.id.live_activity_expanded_title,
            getStringFromJson("title")
        )
        liveActivityLayoutExpanded.setTextViewText(
            R.id.live_activity_expanded_description,
            getStringFromJson("description")
        )

        val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val screenWidth = wm.currentWindowMetrics.bounds.width()
        val step: Int = getIntFromJson("step")
        val distance: Int = getIntFromJson("distance")

        liveActivityLayoutExpanded.setViewPadding(
            R.id.motor_delivery_wrapper,
            round((screenWidth - 480) * (step.toDouble() / distance)).toInt(),
            0,
            0,
            0
        )
        liveActivityLayoutExpanded.setProgressBar(
            R.id.live_activity_progress,
            distance,
            step,
            false
        )

        return liveActivityLayoutExpanded
    }

    private fun getStringFromJson(key: String): String {
        return try {
            jsonObj?.getString(key) ?: ""
        } catch (e: JSONException) {
            ""
        }
    }

    private fun getBooleanFromJson(key: String): Boolean {
        return try {
            jsonObj?.getBoolean(key) ?: false
        } catch (e: JSONException) {
            false
        }
    }

    private fun getIntFromJson(key: String): Int {
        return try {
            jsonObj?.getInt(key) ?: 0
        } catch (e: JSONException) {
            0
        }
    }

    private fun getDoubleFromJson(key: String): Double {
        return try {
            jsonObj?.getDouble(key) ?: 0.0
        } catch (e: JSONException) {
            0.0
        }
    }
}