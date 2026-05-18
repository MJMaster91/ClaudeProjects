package com.elderaid.elder_aid

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "com.elderaid/settings"
    private var pendingCallNumber: String? = null
    private var pendingPermissionResult: MethodChannel.Result? = null
    private val callRequestCode = 1001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openNotificationListenerSettings" -> {
                        startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                        result.success(null)
                    }
                    "checkCallPermission" -> {
                        result.success(
                            ContextCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE)
                                == PackageManager.PERMISSION_GRANTED
                        )
                    }
                    "requestCallPermission" -> {
                        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE)
                            == PackageManager.PERMISSION_GRANTED) {
                            result.success(true)
                        } else {
                            pendingPermissionResult = result
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.CALL_PHONE),
                                callRequestCode
                            )
                        }
                    }
                    "makeDirectCall" -> {
                        val number = call.arguments as String
                        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE)
                            == PackageManager.PERMISSION_GRANTED) {
                            makeCall(number)
                        } else {
                            pendingCallNumber = number
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.CALL_PHONE),
                                callRequestCode
                            )
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun makeCall(number: String) {
        startActivity(Intent(Intent.ACTION_CALL, Uri.parse("tel:$number")))
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == callRequestCode) {
            val granted = grantResults.isNotEmpty()
                && grantResults[0] == PackageManager.PERMISSION_GRANTED
            if (granted) pendingCallNumber?.let { makeCall(it) }
            pendingPermissionResult?.success(granted)
            pendingCallNumber = null
            pendingPermissionResult = null
        }
    }
}
