package io.github.sayuri128.wakaranai

import android.app.Activity
import android.app.PendingIntent
import android.app.PictureInPictureParams
import android.app.RemoteAction
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.graphics.drawable.Icon
import android.os.Build
import android.util.Log
import android.util.Rational
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PictureInPictureChannel(private val activity: Activity) {
    private data class PipConfig(
        val actionsEnabled: Boolean = false,
        val autoEnter: Boolean = false,
        val aspectWidth: Int = 0,
        val aspectHeight: Int = 0,
        val playing: Boolean = false,
        val hasNext: Boolean = false,
        val toggleTitle: String = "",
        val nextTitle: String = "",
    )

    private var channel: MethodChannel? = null
    private var config = PipConfig()
    private var receiverRegistered = false

    private val toggleAction by lazy { "${activity.packageName}.PIP_TOGGLE" }
    private val nextAction by lazy { "${activity.packageName}.PIP_NEXT" }

    private val actionReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val name = when (intent.action) {
                toggleAction -> "toggle"
                nextAction -> "next"
                else -> return
            }
            channel?.invokeMethod("pipAction", name)
        }
    }

    fun attach(messenger: BinaryMessenger) {
        val created = MethodChannel(messenger, CHANNEL_NAME)
        created.setMethodCallHandler { call, result -> handle(call, result) }
        channel = created
    }

    fun registerReceiver() {
        if (receiverRegistered) {
            return
        }
        val filter = IntentFilter().apply {
            addAction(toggleAction)
            addAction(nextAction)
        }
        ContextCompat.registerReceiver(
            activity,
            actionReceiver,
            filter,
            ContextCompat.RECEIVER_NOT_EXPORTED,
        )
        receiverRegistered = true
    }

    fun unregisterReceiver() {
        if (!receiverRegistered) {
            return
        }
        try {
            activity.unregisterReceiver(actionReceiver)
        } catch (e: IllegalArgumentException) {
            Log.w(TAG, "PiP receiver was not registered", e)
        }
        receiverRegistered = false
    }

    fun onUserLeaveHint() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            return
        }
        if (config.autoEnter && isSupported()) {
            enter()
        }
    }

    fun onPictureInPictureModeChanged(inPictureInPicture: Boolean) {
        channel?.invokeMethod("pipModeChanged", inPictureInPicture)
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isSupported" -> result.success(isSupported())
            "configure" -> {
                config = PipConfig(
                    actionsEnabled = true,
                    autoEnter = call.argument<Boolean>("autoEnter") ?: false,
                    aspectWidth = call.argument<Int>("aspectWidth") ?: 0,
                    aspectHeight = call.argument<Int>("aspectHeight") ?: 0,
                    playing = call.argument<Boolean>("playing") ?: false,
                    hasNext = call.argument<Boolean>("hasNext") ?: false,
                    toggleTitle = call.argument<String>("toggleTitle") ?: "",
                    nextTitle = call.argument<String>("nextTitle") ?: "",
                )
                applyParams()
                result.success(null)
            }
            "enter" -> result.success(enter())
            "disable" -> {
                config = PipConfig()
                applyParams()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun isSupported(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return false
        }
        return activity.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)
    }

    private fun applyParams() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O || !isSupported()) {
            return
        }
        try {
            activity.setPictureInPictureParams(buildParams())
        } catch (e: IllegalArgumentException) {
            Log.w(TAG, "Rejected PiP params", e)
        } catch (e: IllegalStateException) {
            Log.w(TAG, "Could not update PiP params", e)
        }
    }

    private fun enter(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O || !isSupported()) {
            return false
        }
        return try {
            activity.enterPictureInPictureMode(buildParams())
        } catch (e: IllegalArgumentException) {
            Log.w(TAG, "Rejected PiP params", e)
            false
        } catch (e: IllegalStateException) {
            Log.w(TAG, "Could not enter PiP", e)
            false
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun buildParams(): PictureInPictureParams {
        val builder = PictureInPictureParams.Builder()
        val aspect = clampedAspect()
        if (aspect != null) {
            builder.setAspectRatio(aspect)
        }
        builder.setActions(buildActions())
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            builder.setAutoEnterEnabled(config.autoEnter)
            builder.setSeamlessResizeEnabled(true)
        }
        return builder.build()
    }

    private fun clampedAspect(): Rational? {
        val width = config.aspectWidth
        val height = config.aspectHeight
        if (width <= 0 || height <= 0) {
            return null
        }
        val ratio = width.toDouble() / height.toDouble()
        if (ratio > MAX_ASPECT) {
            return Rational(ASPECT_LIMIT_LONG, ASPECT_LIMIT_SHORT)
        }
        if (ratio < 1.0 / MAX_ASPECT) {
            return Rational(ASPECT_LIMIT_SHORT, ASPECT_LIMIT_LONG)
        }
        return Rational(width, height)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun buildActions(): List<RemoteAction> {
        if (!config.actionsEnabled) {
            return emptyList()
        }
        val toggleIcon = if (config.playing) {
            android.R.drawable.ic_media_pause
        } else {
            android.R.drawable.ic_media_play
        }
        val actions = mutableListOf(
            remoteAction(toggleIcon, config.toggleTitle, toggleAction, TOGGLE_REQUEST_CODE),
        )
        if (config.hasNext) {
            actions.add(
                remoteAction(
                    android.R.drawable.ic_media_next,
                    config.nextTitle,
                    nextAction,
                    NEXT_REQUEST_CODE,
                ),
            )
        }
        return actions
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun remoteAction(
        iconResource: Int,
        title: String,
        action: String,
        requestCode: Int,
    ): RemoteAction {
        val intent = Intent(action).setPackage(activity.packageName)
        val pendingIntent = PendingIntent.getBroadcast(
            activity,
            requestCode,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        return RemoteAction(
            Icon.createWithResource(activity, iconResource),
            title,
            title,
            pendingIntent,
        )
    }

    companion object {
        private const val CHANNEL_NAME = "wakaranai/pip"
        private const val TAG = "WakaranaiPip"
        private const val MAX_ASPECT = 2.39
        private const val ASPECT_LIMIT_LONG = 239
        private const val ASPECT_LIMIT_SHORT = 100
        private const val TOGGLE_REQUEST_CODE = 7101
        private const val NEXT_REQUEST_CODE = 7102
    }
}
