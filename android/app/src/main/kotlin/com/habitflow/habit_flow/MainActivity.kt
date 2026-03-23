package com.habitflow.habit_flow

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.app.Activity
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri

class MainActivity : FlutterActivity() {

    private val CHANNEL = "habitflow/system_ringtone_picker"

    private var pendingResult: MethodChannel.Result? = null
    private val RINGTONE_PICKER_REQUEST_CODE = 2001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickAlarmSound" -> {
                        pendingResult = result

                        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                            putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALARM)
                            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                            // Help the picker show the default option (best-effort).
                            putExtra(
                                RingtoneManager.EXTRA_RINGTONE_DEFAULT_URI,
                                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                            )
                        }
                        @Suppress("DEPRECATION")
                        startActivityForResult(intent, RINGTONE_PICKER_REQUEST_CODE)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != RINGTONE_PICKER_REQUEST_CODE) return

        val result = pendingResult
        pendingResult = null
        if (result == null) return

        if (resultCode != Activity.RESULT_OK || data == null) {
            result.success(null)
            return
        }

        val pickedUri = data.getParcelableExtra<Uri>(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
        if (pickedUri == null) {
            result.success(mapOf("uri" to "", "title" to "System default"))
            return
        }

        val ringtone = RingtoneManager.getRingtone(this, pickedUri)
        val title = ringtone?.getTitle(this) ?: pickedUri.toString()

        result.success(
            mapOf(
                "uri" to pickedUri.toString(),
                "title" to title
            )
        )
    }
}
