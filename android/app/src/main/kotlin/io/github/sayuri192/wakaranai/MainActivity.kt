package io.github.sayuri128.wakaranai

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "wakaranai/device")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "deviceInfo" -> {
                        val manager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                        val memory = ActivityManager.MemoryInfo()
                        manager.getMemoryInfo(memory)
                        result.success(
                            mapOf(
                                "sdkInt" to Build.VERSION.SDK_INT,
                                "totalRam" to memory.totalMem,
                                "abis" to Build.SUPPORTED_ABIS.toList(),
                                "model" to "${Build.MANUFACTURER} ${Build.MODEL}",
                            )
                        )
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
