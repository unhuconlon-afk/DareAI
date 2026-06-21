package com.example.first

import android.app.Service
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import java.util.*

class AppBlockerService : Service() {

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var isMonitoring = false
    private var monitorThread: Thread? = null

    companion object {
        var isLocked = false
        var blockedPackages = mutableListOf<String>()
        
        // Dynamic callback to communicate back to MainActivity
        var onUnlockCallback: (() -> Unit)? = null
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        startMonitoring()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startMonitoring()
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        stopMonitoring()
        removeOverlay()
    }

    private fun startMonitoring() {
        if (isMonitoring) return
        isMonitoring = true
        monitorThread = Thread {
            while (isMonitoring) {
                try {
                    if (isLocked) {
                        val foregroundApp = getForegroundApp()
                        if (foregroundApp != null && blockedPackages.contains(foregroundApp)) {
                            android.os.Handler(mainLooper).post {
                                showOverlay()
                            }
                        } else {
                            android.os.Handler(mainLooper).post {
                                if (foregroundApp != null && !blockedPackages.contains(foregroundApp)) {
                                    removeOverlay()
                                }
                            }
                        }
                    } else {
                        android.os.Handler(mainLooper).post {
                            removeOverlay()
                        }
                    }
                    Thread.sleep(1000)
                } catch (e: InterruptedException) {
                    break
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
        monitorThread?.start()
    }

    private fun stopMonitoring() {
        isMonitoring = false
        monitorThread?.run {
            interrupt()
        }
        monitorThread = null
    }

    private fun getForegroundApp(): String? {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val time = System.currentTimeMillis()
        val stats = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, time - 1000 * 10, time)
        if (stats != null && stats.isNotEmpty()) {
            val sortedStats = stats.sortedBy { it.lastTimeUsed }
            return sortedStats.lastOrNull()?.packageName
        }
        return null
    }

    private fun showOverlay() {
        if (overlayView != null) return // Already showing
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            return // Cannot draw overlay without permission
        }

        val context = this
        val layout = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#EE0A0A1F")) // Dark semi-transparent cosmic background
            setPadding(80, 80, 80, 80)
        }

        val titleView = TextView(context).apply {
            text = "EFFORT TOLL REQUIRED"
            textSize = 24f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            setTypeface(Typeface.create("sans-serif-condensed", Typeface.BOLD))
        }
        layout.addView(titleView)

        val descView = TextView(context).apply {
            text = "Your biological system is stagnant.\nYou must release pent-up energy to unlock access."
            textSize = 16f
            setTextColor(Color.parseColor("#94A3B8"))
            gravity = Gravity.CENTER
            setPadding(0, 40, 0, 48)
            setTypeface(Typeface.create("sans-serif", Typeface.NORMAL))
        }
        layout.addView(descView)

        val instructionsCard = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#15ffffff"))
            setPadding(40, 40, 40, 40)
            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, 0, 0, 64)
            }
            layoutParams = params
        }
        val cardTitle = TextView(context).apply {
            text = "INSTRUCTION TO UNLOCK"
            textSize = 12f
            setTextColor(Color.parseColor("#67E8F9"))
            setTypeface(null, Typeface.BOLD)
        }
        instructionsCard.addView(cardTitle)

        val cardDesc = TextView(context).apply {
            text = "Complete 1-2 Taekwondo forms or 20 deep squats to unlock restricted apps and restore active performance."
            textSize = 14f
            setTextColor(Color.parseColor("#CBD5E1"))
            setPadding(0, 16, 0, 0)
        }
        instructionsCard.addView(cardDesc)
        layout.addView(instructionsCard)

        val button = Button(context).apply {
            text = "Simulate Exercise Completion"
            setBackgroundColor(Color.parseColor("#67E8F9"))
            setTextColor(Color.parseColor("#0A0A1F"))
            textSize = 16f
            setTypeface(null, Typeface.BOLD)
            setPadding(48, 24, 48, 24)
            background?.setTint(Color.parseColor("#67E8F9"))
            setOnClickListener {
                unlockSystem()
            }
        }
        layout.addView(button)

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_FULLSCREEN,
            PixelFormat.TRANSLUCENT
        )
        
        try {
            windowManager?.addView(layout, params)
            overlayView = layout
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun removeOverlay() {
        val view = overlayView ?: return
        try {
            windowManager?.removeView(view)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        overlayView = null
    }

    private fun unlockSystem() {
        isLocked = false
        removeOverlay()
        onUnlockCallback?.invoke()
    }
}
