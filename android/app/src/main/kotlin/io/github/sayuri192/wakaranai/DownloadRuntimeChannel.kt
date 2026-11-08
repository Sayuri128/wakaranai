package io.github.sayuri128.wakaranai

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class DownloadRuntimeChannel(private val context: Context) {
    private var channel: MethodChannel? = null

    fun attach(messenger: BinaryMessenger) {
        val created = MethodChannel(messenger, CHANNEL_NAME)
        created.setMethodCallHandler { call, result -> handle(call, result) }
        channel = created
        DownloadForegroundService.listener = { event ->
            channel?.invokeMethod(event.methodName, null)
        }
    }

    fun detach() {
        DownloadForegroundService.listener = null
        DownloadForegroundService.stop(context)
        channel?.setMethodCallHandler(null)
        channel = null
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                val outcome = DownloadForegroundService.start(
                    context,
                    call.argument<String>("title").orEmpty(),
                    call.argument<String>("channelName").orEmpty(),
                )
                result.success(outcome.wireName)
            }
            "stop" -> {
                DownloadForegroundService.stop(context)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        private const val CHANNEL_NAME = "wakaranai/download_runtime"
    }
}
