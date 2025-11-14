package com.example.medha_ai

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class HapticUtils(private val context: Context) : MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private var vibrator: Vibrator? = null

    init {
        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
    }

    fun registerWith(flutterEngine: FlutterEngine) {
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.suvyai.kath/haptics")
        channel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "vibrate" -> {
                val duration = call.argument<Int>("duration") ?: 100
                vibrate(duration.toLong())
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    @SuppressLint("MissingPermission")
    private fun vibrate(milliseconds: Long) {
        try {
            val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                vibratorManager.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }

            if (vibrator.hasVibrator()) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val effect = VibrationEffect.createOneShot(
                        milliseconds,
                        VibrationEffect.DEFAULT_AMPLITUDE
                    )
                    vibrator.vibrate(effect)
                } else {
                    @Suppress("DEPRECATION")
                    vibrator.vibrate(milliseconds)
                }
            }
            
            // Add a small delay to ensure the vibration is felt
            Thread.sleep(milliseconds + 20)
        } catch (e: Exception) {
            Log.e("HapticUtils", "Vibration error", e)
        }
    }

    companion object {
        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            HapticUtils(context).registerWith(flutterEngine)
        }
    }
}
