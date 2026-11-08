package io.github.sayuri128.wakaranai

import android.view.KeyEvent
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class VolumeKeyChannel {
    private var channel: MethodChannel? = null
    private var intercepting = false

    fun attach(messenger: BinaryMessenger) {
        val created = MethodChannel(messenger, CHANNEL_NAME)
        created.setMethodCallHandler { call, result ->
            when (call.method) {
                "setIntercepting" -> {
                    intercepting = call.arguments as? Boolean ?: false
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        channel = created
    }

    fun detach() {
        channel?.setMethodCallHandler(null)
        channel = null
        intercepting = false
    }

    fun handle(event: KeyEvent): Boolean {
        if (!intercepting) {
            return false
        }
        val direction = when (event.keyCode) {
            KeyEvent.KEYCODE_VOLUME_UP -> "up"
            KeyEvent.KEYCODE_VOLUME_DOWN -> "down"
            else -> return false
        }
        if (event.action == KeyEvent.ACTION_DOWN) {
            channel?.invokeMethod("volumeKey", direction)
        }
        return true
    }

    companion object {
        private const val CHANNEL_NAME = "wakaranai/volume_keys"
    }
}
