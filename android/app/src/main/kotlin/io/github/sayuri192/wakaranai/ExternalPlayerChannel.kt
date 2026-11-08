package io.github.sayuri128.wakaranai

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ExternalPlayerChannel(private val activity: Activity) {
    private var channel: MethodChannel? = null
    private var pending: MethodChannel.Result? = null

    fun attach(messenger: BinaryMessenger) {
        val created = MethodChannel(messenger, CHANNEL_NAME)
        created.setMethodCallHandler { call, result -> handle(call, result) }
        channel = created
    }

    fun detach() {
        channel?.setMethodCallHandler(null)
        channel = null
        finishPending(mapOf("launched" to true))
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "open" -> open(call, result)
            else -> result.notImplemented()
        }
    }

    private fun open(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        if (url.isNullOrEmpty()) {
            result.error("invalid_url", "Missing stream url", null)
            return
        }
        val mimeType = call.argument<String>("mimeType") ?: "video/*"
        val title = call.argument<String>("title")
        val headers = call.argument<Map<String, String>>("headers") ?: emptyMap()
        val positionMs = call.argument<Number>("positionMs")?.toLong() ?: 0L
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(Uri.parse(url), mimeType)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            putExtra("return_result", true)
            if (!title.isNullOrEmpty()) {
                putExtra("title", title)
            }
            if (positionMs > 0) {
                putExtra("position", positionMs.toInt())
                putExtra("from_start", false)
            }
            if (headers.isNotEmpty()) {
                putExtra("headers", headers.flatMap { listOf(it.key, it.value) }.toTypedArray())
                headers.entries.firstOrNull { it.key.equals("User-Agent", ignoreCase = true) }?.let {
                    putExtra("http-user-agent", it.value)
                }
            }
        }
        val chooser = Intent.createChooser(intent, title ?: "")
        finishPending(mapOf("launched" to true))
        pending = result
        try {
            activity.startActivityForResult(chooser, REQUEST_CODE)
        } catch (error: ActivityNotFoundException) {
            pending = null
            result.success(mapOf("launched" to false))
        }
    }

    fun onActivityResult(requestCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE) {
            return false
        }
        val position = readLong(data, "position", "extra_position")
        val duration = readLong(data, "duration", "extra_duration")
        finishPending(
            mapOf(
                "launched" to true,
                "positionMs" to position,
                "durationMs" to duration,
            )
        )
        return true
    }

    private fun readLong(data: Intent?, vararg keys: String): Long? {
        val extras = data?.extras ?: return null
        for (key in keys) {
            val value = extras.get(key)
            if (value is Number) {
                return value.toLong()
            }
        }
        return null
    }

    private fun finishPending(value: Map<String, Any?>) {
        val result = pending ?: return
        pending = null
        result.success(value)
    }

    companion object {
        private const val CHANNEL_NAME = "wakaranai/external_player"
        private const val REQUEST_CODE = 8802
    }
}
