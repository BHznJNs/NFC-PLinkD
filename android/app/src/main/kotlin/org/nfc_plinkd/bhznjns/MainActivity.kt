package org.nfc_plinkd.bhznjns

import android.content.Intent
import android.os.Bundle
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL_NAME = "org.nfc_plinkd.bhznjns/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
            when (call.method) {
                "getApiLevel" -> result.success(Build.VERSION.SDK_INT)
                "getVideoRotation" -> {
                    val videoMetadataHelper = VideoMetadataHelper()
                    val videoPath = call.argument<String>("videoPath")
                    if (videoPath != null) {
                        val rotation = videoMetadataHelper.getRotation(videoPath)
                        result.success(rotation)
                    } else {
                        result.error("INVALID_ARGUMENT", "Empty video path.", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
