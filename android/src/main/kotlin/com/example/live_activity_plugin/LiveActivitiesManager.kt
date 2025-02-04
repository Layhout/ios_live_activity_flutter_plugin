package com.example.live_activity_plugin

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Context.NOTIFICATION_SERVICE
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.plugin.common.MethodChannel.Result
import java.util.UUID
import kotlin.math.abs
import kotlin.math.max

@RequiresApi(Build.VERSION_CODES.R)
class LiveActivitiesManager {
    companion object {
        private const val CHANNEL_ID: String = "live_activity_notification"
        private const val CHANNEL_NAME: String = "Live Activity Notification"
        private var isInitialized: Boolean = false
        private lateinit var notificationManager: NotificationManager
        private var activityIds: MutableList<String> = mutableListOf()

        @SuppressLint("StaticFieldLeak")
        private lateinit var context: Context

        @RequiresApi(Build.VERSION_CODES.R)
        fun init(ctx: Context) {
            if (isInitialized) return

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_LOW
                )
                channel.description = "A notification channel for Live Activity"
                notificationManager =
                    ctx.getSystemService(NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.createNotificationChannel(channel)

                context = ctx
                isInitialized = true
            }
        }

        private fun isAuthorizedCall(result: Result): Boolean {
            if (!isInitialized) return false

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                return true
            }

            result.error("FEATURE_NOT_SUPPORTED", "this version of Android is not supported", null)
            return false
        }

        private fun createOrUpdateNotification(
            state: ILiveActivityStateProcessor,
            staleIn: Int? = null,
            endIn: Int? = null,
            liveActivityId: Int = abs(
                UUID.randomUUID().hashCode()
            )
        ): Int {
            val liveActivity = NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_menu_info_details)
                .setStyle(NotificationCompat.DecoratedCustomViewStyle())
                .setCustomContentView(state.getLayout(context))
                .setCustomBigContentView(state.getLayoutExpanded(context))
                .setPriority(NotificationCompat.PRIORITY_LOW)

            if (staleIn != null || endIn != null) {
                val theMost = max((staleIn ?: 0), (endIn ?: 0))

                liveActivity.setTimeoutAfter((theMost * 1000).toLong())
            }

            activityIds.add(liveActivityId.toString())

            NotificationManagerCompat.from(context).notify(liveActivityId, liveActivity.build())

            return liveActivityId
        }

        fun areLiveActivitiesEnabled(result: Result) {
            if (!isAuthorizedCall(result)) {
                result.success(false)
                return
            }

            if (NotificationManagerCompat.from(context).areNotificationsEnabled()) {
                val channel = notificationManager.getNotificationChannel(CHANNEL_ID)

                result.success(channel?.importance != NotificationManager.IMPORTANCE_NONE)
                return
            }

            result.success(false)
        }

        fun startLiveActivity(result: Result, state: ILiveActivityStateProcessor, staleIn: Int?) {
            if (!isAuthorizedCall(result)) {
                return
            }

            val liveActivityId: Int =
                createOrUpdateNotification(state = state, staleIn = staleIn)

            result.success(mapOf<String, Any>("id" to liveActivityId.toString(), "pushToken" to ""))
        }

        fun updateLiveActivity(
            result: Result,
            activityId: String,
            state: ILiveActivityStateProcessor,
            staleIn: Int?
        ) {
            if (!isAuthorizedCall(result)) {
                return
            }

            if (!activityIds.contains(activityId)) {
                result.error("ACTIVITY_ERROR", "Activity not found", null)
                return
            }

            createOrUpdateNotification(
                state = state,
                staleIn = staleIn,
                liveActivityId = activityId.toInt()
            )

            result.success(null)
        }

        fun endLiveActivity(
            result: Result,
            activityId: String,
            state: ILiveActivityStateProcessor?,
            staleIn: Int?,
            endIn: Int?
        ) {
            if (!isAuthorizedCall(result)) {
                return
            }

            if (!activityIds.contains(activityId)) {
                result.error("ACTIVITY_ERROR", "Activity not found", null)
                return
            }

            if (state != null) {
                createOrUpdateNotification(
                    state = state,
                    staleIn = staleIn,
                    endIn = endIn,
                    liveActivityId = activityId.toInt()
                )
            } else {
                notificationManager.cancel(activityId.toInt())
            }

            activityIds.remove(activityId)

            result.success(null)
        }

        fun endAllLiveActivity(result: Result) {
            if (!isAuthorizedCall(result)) {
                return
            }

            notificationManager.cancelAll()

            activityIds.clear()

            result.success(null)
        }

        fun getAllActivityIds(result: Result) {
            if (!isAuthorizedCall(result)) {
                return
            }

            result.success(activityIds)
        }
    }
}