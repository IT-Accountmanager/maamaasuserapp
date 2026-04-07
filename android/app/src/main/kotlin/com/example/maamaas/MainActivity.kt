package com.maamaas.app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.maamaas.app/maps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getApiKey") {
                    val apiKey = applicationContext
                        .packageManager
                        .getApplicationInfo(packageName, android.content.pm.PackageManager.GET_META_DATA)
                        .metaData
                        .getString("com.google.android.geo.API_KEY")

                    result.success(apiKey)
                } else {
                    result.notImplemented()
                }
            }
    }
}