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
                        val drawable = wallpaperManager.drawable
                        
                        if (drawable is BitmapDrawable) {
                            val bitmap = drawable.bitmap
                            val stream = ByteArrayOutputStream()
                            
                            // Compress to reduce size
                            bitmap.compress(Bitmap.CompressFormat.PNG, 80, stream)
                            val byteArray = stream.toByteArray()
                            
                            result.success(byteArray)
                        } else {
                            result.error("NO_WALLPAPER", "Could not get wallpaper", null)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}