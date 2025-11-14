import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

class HapticUtils {
  // Strong haptic feedback with increased intensity
  static Future<void> heavyImpact() async {
    try {
      // Trigger multiple heavy impacts for stronger feedback
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 20));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 15));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      developer.log('Heavy haptic error: $e', name: 'HapticUtils');
      // Fallback to vibration if haptic fails
      await vibrate(milliseconds: 50);
    }
  }

  // Medium haptic feedback
  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 20));
    } catch (e) {
      developer.log('Medium haptic error: $e', name: 'HapticUtils');
      // Fallback to light impact
      await lightImpact();
    }
  }

  // Light haptic feedback
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      developer.log('Light haptic error: $e', name: 'HapticUtils');
      // Fallback to selection click
      await selectionClick();
    }
  }

  // Selection click haptic
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      developer.log('Selection click error: $e', name: 'HapticUtils');
    }
  }

  // Vibrate with duration (for Android) - enhanced for stronger feedback
  static Future<void> vibrate({int milliseconds = 100}) async {
    try {
      // Try platform channel first for better control
      const platform = MethodChannel('com.suvyai.kath/haptics');
      // Add a small duration to ensure it's felt
      await platform.invokeMethod('vibrate', {'duration': milliseconds + 20});
      
      // Add a small delay to ensure the vibration is registered
      await Future.delayed(const Duration(milliseconds: 10));
    } catch (e) {
      developer.log('Vibration error: $e', name: 'HapticUtils');
      // Fallback to standard vibration with multiple pulses
      try {
        if (milliseconds > 0) {
          await HapticFeedback.vibrate();
          // Add a second vibration for better feel
          if (milliseconds > 50) {
            await Future.delayed(const Duration(milliseconds: 30));
            await HapticFeedback.vibrate();
          }
        }
      } catch (e2) {
        developer.log('Fallback vibration error: $e2', name: 'HapticUtils');
      }
    }
  }

  // Success pattern - stronger and more pronounced
  static Future<void> success() async {
    try {
      await mediumImpact();
      await Future.delayed(const Duration(milliseconds: 20));
      await heavyImpact();
      await Future.delayed(const Duration(milliseconds: 40));
      await selectionClick();
      await Future.delayed(const Duration(milliseconds: 20));
      await selectionClick();
    } catch (e) {
      developer.log('Success haptic error: $e', name: 'HapticUtils');
      // Fallback to vibration if haptic fails
      await vibrate(milliseconds: 100);
    }
  }

  // Error pattern - stronger and more distinct
  static Future<void> error() async {
    try {
      // Strong initial impact
      await heavyImpact();
      await Future.delayed(const Duration(milliseconds: 30));
      
      // Strong vibration
      await vibrate(milliseconds: 50);
      await Future.delayed(const Duration(milliseconds: 20));
      
      // Final strong impact
      await heavyImpact();
      await Future.delayed(const Duration(milliseconds: 10));
      
      // Additional feedback
      await vibrate(milliseconds: 30);
    } catch (e) {
      developer.log('Error haptic error: $e', name: 'HapticUtils');
      // Fallback to long vibration if haptic fails
      await vibrate(milliseconds: 200);
    }
  }

  // Warning pattern - more noticeable
  static Future<void> warning() async {
    try {
      await mediumImpact();
      await Future.delayed(const Duration(milliseconds: 30));
      await lightImpact();
      await Future.delayed(const Duration(milliseconds: 30));
      await mediumImpact();
    } catch (e) {
      developer.log('Warning haptic error: $e', name: 'HapticUtils');
    }
  }
}
