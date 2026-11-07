package io.github.sayuri128.wakaranai

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class NetworkStateChannel(private val context: Context) : EventChannel.StreamHandler {
    private val mainThread = Handler(Looper.getMainLooper())
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var sink: EventChannel.EventSink? = null
    private var callback: ConnectivityManager.NetworkCallback? = null
    @Volatile
    private var defaultNetwork: Network? = null

    private val connectivity: ConnectivityManager?
        get() = context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager

    fun attach(messenger: BinaryMessenger) {
        val methods = MethodChannel(messenger, METHOD_CHANNEL_NAME)
        methods.setMethodCallHandler { call, result ->
            when (call.method) {
                "current" -> result.success(currentConnection())
                else -> result.notImplemented()
            }
        }
        methodChannel = methods
        val events = EventChannel(messenger, EVENT_CHANNEL_NAME)
        events.setStreamHandler(this)
        eventChannel = events
    }

    fun detach() {
        unregisterCallback()
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        eventChannel?.setStreamHandler(null)
        eventChannel = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        sink = events
        events.success(currentConnection())
        registerCallback()
    }

    override fun onCancel(arguments: Any?) {
        unregisterCallback()
        sink = null
    }

    private fun registerCallback() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N || callback != null) {
            return
        }
        val manager = connectivity ?: return
        val created = object : ConnectivityManager.NetworkCallback() {
            override fun onCapabilitiesChanged(
                network: Network,
                networkCapabilities: NetworkCapabilities,
            ) {
                defaultNetwork = network
                publish(classify(networkCapabilities))
            }

            override fun onLost(network: Network) {
                if (network == defaultNetwork) {
                    defaultNetwork = null
                    publish(OFFLINE)
                }
            }
        }
        try {
            manager.registerDefaultNetworkCallback(created)
            callback = created
        } catch (e: RuntimeException) {
            Log.w(TAG, "Could not watch the network state", e)
        }
    }

    private fun unregisterCallback() {
        val registered = callback ?: return
        callback = null
        defaultNetwork = null
        try {
            connectivity?.unregisterNetworkCallback(registered)
        } catch (e: IllegalArgumentException) {
            Log.w(TAG, "Network callback was not registered", e)
        }
    }

    private fun publish(connection: String) {
        mainThread.post { sink?.success(connection) }
    }

    @Suppress("DEPRECATION")
    private fun currentConnection(): String {
        val manager = connectivity ?: return OTHER
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            val info = manager.activeNetworkInfo ?: return OFFLINE
            if (!info.isConnected) {
                return OFFLINE
            }
            return when (info.type) {
                ConnectivityManager.TYPE_WIFI, ConnectivityManager.TYPE_ETHERNET -> WIFI
                ConnectivityManager.TYPE_MOBILE -> CELLULAR
                else -> OTHER
            }
        }
        val network = manager.activeNetwork ?: return OFFLINE
        val capabilities = manager.getNetworkCapabilities(network) ?: return OFFLINE
        return classify(capabilities)
    }

    private fun classify(capabilities: NetworkCapabilities): String {
        if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ||
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)
        ) {
            return WIFI
        }
        if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
            return CELLULAR
        }
        return OTHER
    }

    companion object {
        private const val METHOD_CHANNEL_NAME = "wakaranai/network"
        private const val EVENT_CHANNEL_NAME = "wakaranai/network/changes"
        private const val TAG = "WakaranaiNetwork"
        private const val WIFI = "wifi"
        private const val CELLULAR = "cellular"
        private const val OFFLINE = "offline"
        private const val OTHER = "other"
    }
}
