package org.nfc_plinkd.bhznjns

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val VIDEO_UTIL_CHANNEL = "org.nfc_plinkd.bhznjns/video_util"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val videoMetadataHelper = VideoMetadataHelper()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VIDEO_UTIL_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getVideoRotation" -> {
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
