import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';

class PerformanceUtils {
  // Number of CPU cores (will be set during initialization)
  static int _numberOfCores = 1;
  
  // Initialize performance utils
  static Future<void> initialize() async {
    try {
      // Get number of available CPU cores
      _numberOfCores = await _getNumberOfCores();
      debugPrint('PerformanceUtils: Device has $_numberOfCores CPU cores');
    } catch (e) {
      debugPrint('Error initializing PerformanceUtils: $e');
    }
  }

  // Run a task in a separate isolate
  static Future<R> runInBackground<R, P>(
    FutureOr<R> Function(P) function, {
    P? params,
    String? debugLabel,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await compute(
        _isolateWrapper,
        _IsolateData(function, params, debugLabel),
        debugLabel: debugLabel ?? 'background_task',
      );
      
      debugPrint('Task completed in ${stopwatch.elapsedMilliseconds}ms');
      return result as R;
    } catch (e, stackTrace) {
      debugPrint('Error in background task: $e\n$stackTrace');
      rethrow;
    }
  }

  // Run multiple tasks in parallel using isolates
  static Future<List<R>> runInParallel<R, P>({
    required List<FutureOr<R> Function()> tasks,
    int? maxConcurrent,
  }) async {
    final effectiveMaxConcurrent = maxConcurrent ?? _numberOfCores;
    final results = <R>[];
    final taskQueue = List<FutureOr<R> Function()>.from(tasks);
    
    while (taskQueue.isNotEmpty) {
      // Take up to maxConcurrent tasks
      final batch = taskQueue.take(effectiveMaxConcurrent).toList();
      taskQueue.removeRange(0, batch.length < effectiveMaxConcurrent ? batch.length : effectiveMaxConcurrent);
      
      // Run batch in parallel
      final batchResults = await Future.wait(
        batch.map((task) => runInBackground((_) => task(), debugLabel: 'parallel_task')),
        eagerError: true,
      );
      
      results.addAll(batchResults);
    }
    
    return results;
  }

  // Get number of available CPU cores
  static Future<int> _getNumberOfCores() async {
    try {
      final String? result = await _channel.invokeMethod('getNumberOfCores');
      return int.tryParse(result ?? '1') ?? 1;
    } catch (e) {
      debugPrint('Error getting number of cores: $e');
      return 1;
    }
  }

  // Platform channel for native methods
  static const _channel = MethodChannel('com.suvyai.kath/performance');
}

// Helper class for isolate communication
class _IsolateData<F, P> {
  final F function;
  final P? params;
  final String? debugLabel;

  _IsolateData(this.function, this.params, this.debugLabel);
}

// Wrapper function for isolates
Future<R> _isolateWrapper<F, P, R>(_IsolateData<F, P> data) async {
  final function = data.function as FutureOr<R> Function(P?);
  return await function(data.params);
}
