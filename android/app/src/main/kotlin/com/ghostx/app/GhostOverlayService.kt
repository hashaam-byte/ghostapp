// android/app/src/main/kotlin/com/ghostx/app/GhostOverlayService.kt
package com.ghostx.app

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.*
import android.widget.ImageView
import androidx.core.app.NotificationCompat

class GhostOverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var ghostView: View? = null
    
    companion object {
        const val NOTIFICATION_CHANNEL_ID = "ghost_overlay"
        const val NOTIFICATION_ID = 1001
        
        fun start(context: Context) {
            val intent = Intent(context, GhostOverlayService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
        
        fun stop(context: Context) {
            context.stopService(Intent(context, GhostOverlayService::class.java))
        }
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
        
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        createGhostOverlay()
    }

    private fun createGhostOverlay() {
        // Inflate ghost overlay layout
        ghostView = LayoutInflater.from(this).inflate(R.layout.ghost_overlay, null)
        
        val layoutParams = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                PixelFormat.TRANSLUCENT
            )
        } else {
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_PHONE,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                PixelFormat.TRANSLUCENT
            )
        }
        
        layoutParams.gravity = Gravity.TOP or Gravity.START
        layoutParams.x = 0
        layoutParams.y = 100
        
        // Make draggable
        var initialX = 0
        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f
        
        ghostView?.setOnTouchListener { view, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = layoutParams.x
                    initialY = layoutParams.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    layoutParams.x = initialX + (event.rawX - initialTouchX).toInt()
                    layoutParams.y = initialY + (event.rawY - initialTouchY).toInt()
                    windowManager?.updateViewLayout(ghostView, layoutParams)
                    true
                }
                MotionEvent.ACTION_UP -> {
                    // Snap to edge if needed
                    snapToEdge(layoutParams)
                    true
                }
                else -> false
            }
        }
        
        // Tap to open full app
        ghostView?.setOnClickListener {
            openFullApp()
        }
        
        windowManager?.addView(ghostView, layoutParams)
    }
    
    private fun snapToEdge(params: WindowManager.LayoutParams) {
        val display = windowManager?.defaultDisplay
        val width = display?.width ?: 0
        
        if (params.x + (ghostView?.width ?: 0) / 2 < width / 2) {
            params.x = 0 // Snap to left
        } else {
            params.x = width - (ghostView?.width ?: 0) // Snap to right
        }
        
        windowManager?.updateViewLayout(ghostView, params)
    }
    
    private fun openFullApp() {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Ghost Overlay",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Ghost is floating on your screen"
            }
            
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }
    
    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle("👻 Ghost is Active")
            .setContentText("Tap to open GhostX")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    override fun onDestroy() {
        super.onDestroy()
        ghostView?.let { windowManager?.removeView(it) }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}