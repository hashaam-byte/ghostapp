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
                        val wallpaperManager = WallpaperManager.getInstance(applicationContext)
                        val wallpaperDrawable = wallpaperManager.drawable
                        
                        if (wallpaperDrawable is BitmapDrawable) {
                            val bitmap = wallpaperDrawable.bitmap
                            
                            // Resize for performance (max 1000px width)
                            val scaledBitmap = if (bitmap.width > 1000) {
                                val scale = 1000f / bitmap.width
                                Bitmap.createScaledBitmap(
                                    bitmap,
                                    1000,
                                    (bitmap.height * scale).toInt(),
                                    true
                                )
                            } else {
                                bitmap
                            }
                            
                            // Convert to byte array
                            val stream = ByteArrayOutputStream()
                            scaledBitmap.compress(Bitmap.CompressFormat.PNG, 90, stream)
                            val byteArray = stream.toByteArray()
                            
                            result.success(byteArray)
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
}