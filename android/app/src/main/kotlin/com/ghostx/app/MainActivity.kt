package com.ghostx.app

import android.Manifest
import android.app.WallpaperManager
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "ghostx/wallpaper"
    private val PERMISSION_REQUEST_CODE = 1001
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getWallpaper" -> {
                        getWallpaperWithPermission(result)
                    }
                    "requestWallpaperPermission" -> {
                        requestWallpaperPermission(result)
                    }
                    "checkWallpaperPermission" -> {
                        result.success(hasWallpaperPermission())
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasWallpaperPermission(): Boolean {
        // Android 13+ (API 33+) doesn't need READ_EXTERNAL_STORAGE for wallpaper
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return true
        }
        
        // Android 6-12 (API 23-32) needs READ_EXTERNAL_STORAGE
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.READ_EXTERNAL_STORAGE
            ) == PackageManager.PERMISSION_GRANTED
        }
        
        // Android 5 and below - permission granted by default
        return true
    }

    private fun requestWallpaperPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Android 13+ doesn't need permission
            result.success(true)
            return
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (hasWallpaperPermission()) {
                result.success(true)
            } else {
                pendingResult = result
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE),
                    PERMISSION_REQUEST_CODE
                )
            }
        } else {
            result.success(true)
        }
    }

    private fun getWallpaperWithPermission(result: MethodChannel.Result) {
        if (hasWallpaperPermission()) {
            getWallpaperData(result)
        } else {
            // Request permission first
            pendingResult = result
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE),
                    PERMISSION_REQUEST_CODE
                )
            } else {
                getWallpaperData(result)
            }
        }
    }

    private fun getWallpaperData(result: MethodChannel.Result) {
        try {
            val wallpaperManager = WallpaperManager.getInstance(applicationContext)
            val wallpaperDrawable = wallpaperManager.drawable
            
            if (wallpaperDrawable is BitmapDrawable) {
                val bitmap = wallpaperDrawable.bitmap
                
                // Resize for performance (max 800px width)
                val scaledBitmap = if (bitmap.width > 800) {
                    val scale = 800f / bitmap.width
                    Bitmap.createScaledBitmap(
                        bitmap,
                        800,
                        (bitmap.height * scale).toInt(),
                        true
                    )
                } else {
                    bitmap
                }
                
                // Convert to byte array with compression
                val stream = ByteArrayOutputStream()
                scaledBitmap.compress(Bitmap.CompressFormat.JPEG, 85, stream)
                val byteArray = stream.toByteArray()
                
                result.success(byteArray)
            } else {
                result.error("UNAVAILABLE", "Wallpaper not available", null)
            }
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", "Permission denied: ${e.message}", null)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to get wallpaper: ${e.message}", null)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && 
                grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission granted - get wallpaper
                pendingResult?.let { result ->
                    getWallpaperData(result)
                    pendingResult = null
                }
            } else {
                // Permission denied
                pendingResult?.error(
                    "PERMISSION_DENIED",
                    "Wallpaper permission denied by user",
                    null
                )
                pendingResult = null
            }
        }
    }
}