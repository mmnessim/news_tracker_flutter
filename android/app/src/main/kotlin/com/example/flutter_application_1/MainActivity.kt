package com.example.flutter_application_1

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.app.Notification
import android.content.Intent
import android.app.PendingIntent
import android.app.AlarmManager
import androidx.core.app.NotificationCompat
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "scheduleNotification" -> {
                    val title = call.argument<String>("title") ?: "Title"
                    val body = call.argument<String>("body") ?: "Body"
                    val time = call.argument<Long>("time") ?: System.currentTimeMillis()
                    scheduleNotification(title, body, time)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun scheduleNotification(title: String, body: String, timeMillis: Long) {
        val intent = Intent(this, NotificationReceiver::class.java).apply {
            putExtra("title", title)
            putExtra("body", body)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, timeMillis, pendingIntent)
    }
}
