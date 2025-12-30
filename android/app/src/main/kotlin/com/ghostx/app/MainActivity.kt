// android/app/src/main/kotlin/com/ghostx/app/MainActivity.kt
package com.ghostx.app

import android.app.WallpaperManager
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "ghostx/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getWallpaper" -> {
                    try {
                        val wallpaperBytes = getWallpaperBytes()
                        if (wallpaperBytes != null) {
                            result.success(wallpaperBytes)
                        } else {
                            result.error("UNAVAILABLE", "Wallpaper not available", null)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to get wallpaper: ${e.message}", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getWallpaperBytes(): ByteArray? {
        return try {
            val wallpaperManager = WallpaperManager.getInstance(applicationContext)
            val drawable = wallpaperManager.drawable ?: return null
            
            val bitmap = (drawable as? BitmapDrawable)?.bitmap 
                ?: Bitmap.createBitmap(
                    drawable.intrinsicWidth,
                    drawable.intrinsicHeight,
                    Bitmap.Config.ARGB_8888
                ).apply {
                    val canvas = android.graphics.Canvas(this)
                    drawable.setBounds(0, 0, canvas.width, canvas.height)
                    drawable.draw(canvas)
                }
            
            // Compress to reduce size
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.JPEG, 85, stream)
            stream.toByteArray()
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}