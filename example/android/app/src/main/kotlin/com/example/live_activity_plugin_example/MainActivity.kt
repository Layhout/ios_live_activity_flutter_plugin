package com.example.live_activity_plugin_example

import android.os.Build
import androidx.annotation.RequiresApi
import com.example.live_activity_plugin.LiveActivitiesController
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    @RequiresApi(Build.VERSION_CODES.R)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        LiveActivitiesController.registerStateProcessor { dataJsonString: String? -> LiveActivityStateProcessor(dataJsonString ?: "") }
    }
}
