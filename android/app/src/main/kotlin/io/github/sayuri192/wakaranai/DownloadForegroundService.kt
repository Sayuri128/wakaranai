package io.github.sayuri128.wakaranai

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat

class DownloadForegroundService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startPending = false
        val title = intent?.getStringExtra(EXTRA_TITLE).orEmpty()
        val channelName = intent?.getStringExtra(EXTRA_CHANNEL_NAME).orEmpty()
        if (!enterForeground(title, channelName)) {
            stopSelf()
            return START_NOT_STICKY
        }
        if (!wanted) {
            leaveForeground()
        }
        return START_NOT_STICKY
    }

    override fun onTimeout(startId: Int, fgsType: Int) {
        Log.w(TAG, "Download foreground service reached its time limit")
        wanted = false
        listener?.invoke(DownloadRuntimeEvent.TIMED_OUT)
        leaveForeground()
    }

    override fun onDestroy() {
        inForeground = false
        startPending = false
        super.onDestroy()
    }

    private fun enterForeground(title: String, channelName: String): Boolean {
        return try {
            ensureChannel(this, channelName)
            ServiceCompat.startForeground(
                this,
                NOTIFICATION_ID,
                postedNotification() ?: buildNotification(title),
                foregroundServiceType(),
            )
            inForeground = true
            true
        } catch (e: IllegalStateException) {
            reportStartRejected(e)
            false
        } catch (e: SecurityException) {
            reportStartRejected(e)
            false
        }
    }

    private fun reportStartRejected(error: Exception) {
        Log.w(TAG, "Could not enter the foreground for downloads", error)
        wanted = false
        listener?.invoke(DownloadRuntimeEvent.START_NOT_ALLOWED)
    }

    private fun leaveForeground() {
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
        inForeground = false
        stopSelf()
    }

    private fun foregroundServiceType(): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            return ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
        }
        return 0
    }

    private fun postedNotification(): Notification? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return null
        }
        val manager = getSystemService(NotificationManager::class.java) ?: return null
        return try {
            manager.activeNotifications
                .firstOrNull { it.id == NOTIFICATION_ID }
                ?.notification
        } catch (e: RuntimeException) {
            null
        }
    }

    private fun buildNotification(title: String): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_download)
            .setContentTitle(title)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setProgress(0, 0, true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .setContentIntent(launchIntent())
            .build()
    }

    private fun launchIntent(): PendingIntent? {
        val launch = packageManager.getLaunchIntentForPackage(packageName) ?: return null
        launch.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        return PendingIntent.getActivity(
            this,
            LAUNCH_REQUEST_CODE,
            launch,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    companion object {
        const val CHANNEL_ID = "downloads"
        const val NOTIFICATION_ID = 8801
        private const val TAG = "WakaranaiDownloads"
        private const val EXTRA_TITLE = "title"
        private const val EXTRA_CHANNEL_NAME = "channelName"
        private const val LAUNCH_REQUEST_CODE = 7201

        var listener: ((DownloadRuntimeEvent) -> Unit)? = null

        private var wanted = false
        private var startPending = false
        private var inForeground = false

        fun start(context: Context, title: String, channelName: String): DownloadRuntimeStart {
            wanted = true
            if (inForeground || startPending) {
                return DownloadRuntimeStart.ALREADY_RUNNING
            }
            val intent = Intent(context, DownloadForegroundService::class.java)
                .putExtra(EXTRA_TITLE, title)
                .putExtra(EXTRA_CHANNEL_NAME, channelName)
            return try {
                ensureChannel(context, channelName)
                ContextCompat.startForegroundService(context, intent)
                startPending = true
                DownloadRuntimeStart.STARTED
            } catch (e: IllegalStateException) {
                Log.w(TAG, "Download foreground service start was not allowed", e)
                wanted = false
                DownloadRuntimeStart.NOT_ALLOWED
            } catch (e: SecurityException) {
                Log.w(TAG, "Download foreground service start was refused", e)
                wanted = false
                DownloadRuntimeStart.NOT_ALLOWED
            }
        }

        fun stop(context: Context) {
            wanted = false
            if (startPending) {
                return
            }
            if (inForeground) {
                context.stopService(Intent(context, DownloadForegroundService::class.java))
                inForeground = false
            }
        }

        private fun ensureChannel(context: Context, channelName: String) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                return
            }
            val manager = context.getSystemService(NotificationManager::class.java) ?: return
            if (manager.getNotificationChannel(CHANNEL_ID) != null) {
                return
            }
            val name = channelName.ifEmpty { CHANNEL_ID }
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL_ID, name, NotificationManager.IMPORTANCE_LOW),
            )
        }
    }
}

enum class DownloadRuntimeStart(val wireName: String) {
    STARTED("started"),
    ALREADY_RUNNING("alreadyRunning"),
    NOT_ALLOWED("notAllowed"),
}

enum class DownloadRuntimeEvent(val methodName: String) {
    START_NOT_ALLOWED("onStartNotAllowed"),
    TIMED_OUT("onTimeout"),
}
