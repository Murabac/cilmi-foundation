package com.reershyoonis.reer_sh_yoonis

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "reer_sh_yoonis/phone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "callUssd" -> {
                        val ussdCode = call.arguments as? String
                        if (ussdCode.isNullOrBlank()) {
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        result.success(callUssd(ussdCode))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun callUssd(ussdCode: String): Boolean {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE)
            != PackageManager.PERMISSION_GRANTED
        ) {
            return false
        }

        val intent = Intent(Intent.ACTION_CALL).apply {
            data = Uri.fromParts("tel", ussdCode, null)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }

        return if (intent.resolveActivity(packageManager) != null) {
            startActivity(intent)
            true
        } else {
            false
        }
    }
}
