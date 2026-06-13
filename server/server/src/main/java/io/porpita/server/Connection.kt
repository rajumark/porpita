package io.porpita.server

import android.annotation.TargetApi
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.res.AssetManager
import android.content.res.Configuration
import android.content.res.Resources
import android.net.LocalSocket
import android.os.Build
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.io.DataInputStream
import java.io.DataOutputStream
import java.io.File

class Connection(private val client: LocalSocket) : Thread() {
    private companion object {
        private const val TAG = "Porpita.Connection"
        private const val ICON_CACHE_DIR = "/data/local/tmp/porpita/icons"

        init {
            val iconCacheDir = File(ICON_CACHE_DIR)
            if (!iconCacheDir.exists()) {
                iconCacheDir.mkdirs()
            }
        }
    }

    private var iconCache = JSONObject()

    override fun run() {
        val input = DataInputStream(client.inputStream)
        val output = DataOutputStream(client.outputStream)

        try {
            while (!isInterrupted && client.isConnected) {
                val length = input.readInt()
                if (length <= 0 || length > 10 * 1024 * 1024) break

                val bytes = ByteArray(length)
                input.readFully(bytes)
                val requestStr = String(bytes, Charsets.UTF_8)
                val request = JSONObject(requestStr)

                val id = request.getString("id")
                val method = request.getString("method")
                val params = request.optJSONObject("params") ?: JSONObject()

                val result = handleRequest(method, params)
                val response = JSONObject()
                response.put("id", id)
                response.put("result", result)

                val responseBytes = response.toString().toByteArray(Charsets.UTF_8)
                output.writeInt(responseBytes.size)
                output.write(responseBytes)
                output.flush()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Connection error", e)
        } finally {
            try {
                client.close()
            } catch (_: Exception) {}
            Log.i(TAG, "Client disconnected")
        }
    }

    private fun handleRequest(method: String, params: JSONObject): JSONObject {
        Log.i(TAG, "Request method: $method")

        return when (method) {
            "getAppIcons" -> getAppIcons(params)
            "startFileServer" -> {
                val port = HttpFileServerManager.start()
                JSONObject().put("port", port)
            }
            "isFileServerRunning" -> {
                val running = HttpFileServerManager.isRunning()
                JSONObject().put("running", running)
            }
            else -> JSONObject().put("error", "Unknown method: $method")
        }
    }

    private fun getAppIcons(params: JSONObject): JSONObject {
        val packageNames = Util.jsonArrayToStringArray(params.getJSONArray("packageNames"))
        val result = JSONObject()

        for (packageName in packageNames) {
            try {
                result.put(packageName, getIconPath(packageName))
            } catch (e: Exception) {
                Log.e(TAG, "Failed to get icon for $packageName", e)
            }
        }

        return result
    }

    @TargetApi(Build.VERSION_CODES.P)
    private fun getIconPath(packageName: String): String {
        val packageInfo = ServiceManager.packageManager.getPackageInfo(packageName, 0)
        val applicationInfo = packageInfo.applicationInfo ?: return ""
        val apkPath = applicationInfo.sourceDir
        val apkSize = File(apkPath).length()
        val cacheKey = "$packageName.$apkSize"

        if (iconCache.has(cacheKey)) {
            return iconCache.getString(cacheKey)
        }

        if (applicationInfo.icon != 0) {
            try {
                val resources = getResources(apkPath)
                val iconPath = "$ICON_CACHE_DIR/$cacheKey.png"
                val file = File(iconPath)
                if (!file.exists()) {
                    val resIcon = resources.getDrawable(applicationInfo.icon, null)
                    val bitmapIcon = Util.drawableToBitmap(resIcon)
                    val pngIcon = Util.bitMapToPng(bitmapIcon, 20)
                    file.writeBytes(pngIcon)
                }
                iconCache.put(cacheKey, iconPath)
                return iconPath
            } catch (e: Exception) {
                Log.e(TAG, "Failed to get icon for $packageName", e)
            }
        }

        iconCache.put(cacheKey, "")
        return ""
    }

    private fun getResources(apkPath: String): Resources {
        val assetManager = AssetManager::class.java.newInstance() as AssetManager
        val addAssetManagerMethod =
            assetManager.javaClass.getMethod("addAssetPath", String::class.java)
        addAssetManagerMethod.invoke(assetManager, apkPath)

        val displayMetrics = android.util.DisplayMetrics()
        displayMetrics.setToDefaults()
        val configuration = Configuration()
        configuration.setToDefaults()

        return Resources(assetManager, displayMetrics, configuration)
    }
}