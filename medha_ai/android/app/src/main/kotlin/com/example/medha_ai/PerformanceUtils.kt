package com.example.medha_ai

import android.os.Build
import android.os.Process
import android.os.StrictMode
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.RandomAccessFile

class PerformanceUtils(private val context: android.content.Context) : MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null

    fun registerWith(flutterEngine: FlutterEngine) {
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.suvyai.kath/performance")
        channel?.setMethodCallHandler(this)
        
        // Enable strict mode for development to catch performance issues
        try {
            // Use application info to check if debuggable
            val isDebuggable = (context.applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0
            if (isDebuggable) {
                enableStrictMode()
            }
        } catch (e: Exception) {
            Log.e("PerformanceUtils", "Error enabling strict mode", e)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getNumberOfCores" -> {
                result.success(getNumberOfCores().toString())
            }
            else -> result.notImplemented()
        }
    }

    private fun getNumberOfCores(): Int {
        return try {
            // Try to get number of cores from /proc/cpuinfo
            File("/sys/devices/system/cpu/").listFiles { file ->
                // Count CPU cores (cpu0, cpu1, etc.)
                file.name.matches(Regex("cpu\\d+"))
            }?.size ?: 1
        } catch (e: Exception) {
            // Fallback to available processors
            Runtime.getRuntime().availableProcessors().coerceAtLeast(1)
        }
    }

    private fun enableStrictMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.GINGERBREAD) {
            StrictMode.setThreadPolicy(
                StrictMode.ThreadPolicy.Builder()
                    .detectAll()
                    .penaltyLog()
                    .build()
            )
            
            StrictMode.setVmPolicy(
                StrictMode.VmPolicy.Builder()
                    .detectAll()
                    .penaltyLog()
                    .build()
            )
        }
    }

    companion object {
        fun registerWith(flutterEngine: FlutterEngine, context: android.content.Context) {
            PerformanceUtils(context).registerWith(flutterEngine)
        }
    }
}
