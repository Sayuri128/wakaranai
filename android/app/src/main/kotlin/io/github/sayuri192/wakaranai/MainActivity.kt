package io.github.sayuri128.wakaranai

import android.app.ActivityManager
import android.content.ContentValues
import android.content.Context
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import java.io.File
import java.io.IOException
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
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "wakaranai/backups")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "save" -> runInBackground(result) {
                        saveBackup(
                            call.argument<String>("name")!!,
                            call.argument<ByteArray>("bytes")!!,
                        )
                    }
                    "prune" -> runInBackground(result) {
                        pruneBackups(
                            call.argument<String>("prefix")!!,
                            call.argument<Int>("keep")!!,
                        )
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun runInBackground(result: MethodChannel.Result, task: () -> Any) {
        val mainThread = Handler(Looper.getMainLooper())
        Thread {
            try {
                val value = task()
                mainThread.post { result.success(value) }
            } catch (e: Exception) {
                mainThread.post { result.error("backup_failed", e.message, null) }
            }
        }.start()
    }

    private fun saveBackup(name: String, bytes: ByteArray): String {
        val relativePath = "${Environment.DIRECTORY_DOWNLOADS}/$BACKUP_FOLDER"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, name)
                put(MediaStore.MediaColumns.MIME_TYPE, "application/json")
                put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val uri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: throw IOException("Could not create $name")
            contentResolver.openOutputStream(uri)?.use { it.write(bytes) }
                ?: throw IOException("Could not write $name")
            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            contentResolver.update(uri, values, null, null)
        } else {
            val folder = File(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
                BACKUP_FOLDER,
            )
            folder.mkdirs()
            File(folder, name).writeBytes(bytes)
        }
        return "$relativePath/$name"
    }

    private fun pruneBackups(prefix: String, keep: Int): Int {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            val folder = File(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
                BACKUP_FOLDER,
            )
            val backups = folder.listFiles { file -> file.name.startsWith(prefix) }
                ?.sortedByDescending { it.lastModified() }
                ?: return 0
            return backups.drop(keep).count { it.delete() }
        }

        val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
        val projection = arrayOf(MediaStore.MediaColumns._ID)
        val selection =
            "${MediaStore.MediaColumns.RELATIVE_PATH} = ? AND ${MediaStore.MediaColumns.DISPLAY_NAME} LIKE ?"
        val arguments = arrayOf("${Environment.DIRECTORY_DOWNLOADS}/$BACKUP_FOLDER/", "$prefix%")
        val order = "${MediaStore.MediaColumns.DATE_ADDED} DESC"
        val stale = mutableListOf<Long>()
        contentResolver.query(collection, projection, selection, arguments, order)?.use { cursor ->
            val idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
            var position = 0
            while (cursor.moveToNext()) {
                if (position >= keep) {
                    stale.add(cursor.getLong(idColumn))
                }
                position++
            }
        }
        return stale.sumOf { id ->
            contentResolver.delete(
                MediaStore.Downloads.EXTERNAL_CONTENT_URI.buildUpon().appendPath(id.toString()).build(),
                null,
                null,
            )
        }
    }

    companion object {
        private const val BACKUP_FOLDER = "Wakaranai"
    }
}
