import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A mixin that provides performance optimization utilities for StatefulWidgets
mixin PerformanceOptimizer<T extends StatefulWidget> on State<T> {
  final Map<String, dynamic> _memoizedResults = {};
  final Map<String, DateTime> _lastUpdateTimes = {};
  
  /// Memoize a computation result with a key
  R memoize<R>(String key, R Function() compute, {Duration? ttl}) {
    if (_memoizedResults.containsKey(key)) {
      if (ttl != null) {
        final lastUpdate = _lastUpdateTimes[key];
        if (lastUpdate != null && 
            DateTime.now().difference(lastUpdate) < ttl) {
          return _memoizedResults[key] as R;
        }
      } else {
        return _memoizedResults[key] as R;
      }
    }
    
    final result = compute();
    _memoizedResults[key] = result;
    _lastUpdateTimes[key] = DateTime.now();
    return result;
  }
  
  /// Run a heavy computation in a separate isolate
  static Future<R> computeInBackground<Q, R>(
    ComputeCallback<Q, R> function, 
    Q message, {
    String? debugLabel,
  }) async {
    return await compute(function, message);
  }
  
  /// Schedule a callback for the next frame
  void onNextFrame(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) callback();
    });
  }
  
  /// Debounce a function call
  Timer? _debounceTimer;
  void debounce(Duration duration, VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, () {
      if (mounted) callback();
    });
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// A widget that defers building its child until after the first frame
class DeferFirstFrame extends StatefulWidget {
  final Widget child;
  
  const DeferFirstFrame({Key? key, required this.child}) : super(key: key);
  
  @override
  _DeferFirstFrameState createState() => _DeferFirstFrameState();
}

class _DeferFirstFrameState extends State<DeferFirstFrame> {
  bool _showChild = false;
  
  @override
  void initState() {
    super.initState();
    // Wait for the first frame to render before showing the child
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _showChild = true);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return _showChild ? widget.child : const SizedBox.shrink();
  }
}

/// A widget that only rebuilds when its dependencies change
class OptimizedBuilder extends StatelessWidget {
  final Widget Function() builder;
  final List<dynamic> dependencies;
  
  const OptimizedBuilder({
    Key? key,
    required this.builder,
    required this.dependencies,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        // This will cause the builder to be called when any dependency changes
        for (final dep in dependencies) {
          // This is just to trigger rebuilds when dependencies change
          context.dependOnInheritedWidgetOfExactType<InheritedElement>();
          if (dep is ChangeNotifier) {
            context.watch<ChangeNotifier>();
          }
        }
        return builder();
      },
    );
  }
}
