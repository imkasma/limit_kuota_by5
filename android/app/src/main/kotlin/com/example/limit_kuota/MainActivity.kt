package com.example.limit_kuota

import android.app.AppOpsManager
import android.app.usage.NetworkStats
import android.app.usage.NetworkStatsManager
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {

    private val CHANNEL = "limit_kuota/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "getTodayUsage" -> {
                    if (!hasUsageStatsPermission()) {
                        requestUsageStatsPermission()
                        result.error(
                            "PERMISSION_DENIED",
                            "Izin akses penggunaan diperlukan",
                            null
                        )
                    } else {
                        val wifi = getUsage(ConnectivityManager.TYPE_WIFI)
                        val mobile = getUsage(ConnectivityManager.TYPE_MOBILE)

                        Log.d("USAGE_STATS", "WiFi: $wifi | Mobile: $mobile")

                        val data = mapOf(
                            "wifi" to wifi,
                            "mobile" to mobile,
                            "timestamp" to System.currentTimeMillis()
                        )

                        result.success(data)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    // =========================
    // CHECK PERMISSION
    // =========================
    private fun hasUsageStatsPermission(): Boolean {
        val appOps =
            getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager

        val mode =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(),
                    packageName
                )
            } else {
                appOps.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(),
                    packageName
                )
            }

        return mode == AppOpsManager.MODE_ALLOWED
    }

    // =========================
    // REQUEST PERMISSION
    // =========================
    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    // =========================
    // GET NETWORK USAGE TODAY
    // =========================
    private fun getUsage(networkType: Int): Long {
        val networkStatsManager =
            getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager

        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()

        var totalBytes = 0L

        try {
            val stats = networkStatsManager.querySummary(
                networkType,
                null,
                startTime,
                endTime
            )

            val bucket = NetworkStats.Bucket()

            while (stats.hasNextBucket()) {
                stats.getNextBucket(bucket)
                totalBytes += bucket.rxBytes + bucket.txBytes
            }

            stats.close()

        } catch (e: Exception) {
            Log.e("USAGE_STATS", "Error reading usage stats", e)
        }

        return totalBytes
    }
}