import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/file_service.dart';
import 'pdf_viewer_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _shownDialog = false;
  final _fileService = FileService();
  bool _downloading = false;
  double _progress = 0;
  final Map<String, double> _progressBy = {
    'iesc101.pdf': 0.0,
    'iesc102.pdf': 0.0,
    'iesc103.pdf': 0.0,
  };
  final Map<String, bool> _downloadedBy = {
    'iesc101.pdf': false,
    'iesc102.pdf': false,
    'iesc103.pdf': false,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_shownDialog) {
      _shownDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Science – Class 10 available'),
            content: const Text('NCERT content is ready for offline download.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }

  }

  Future<void> _openQuiz() async {
    // Strong haptic for quiz start
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 30));
    await HapticFeedback.mediumImpact();
    
    if (!mounted) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const QuizScreen(),
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: Tween<double>(begin: 0.92, end: 1).animate(curved), child: child),
          );
        },
      ),
    );
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _progressBy.keys.toList()) {
      _progressBy[key] = prefs.getDouble('progress_$key') ?? 0.0;
    }
    if (mounted) setState(() {});
  }

  Future<void> _refreshDownloaded() async {
    for (final key in _downloadedBy.keys.toList()) {
      _downloadedBy[key] = await _fileService.isDownloaded(key);
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Prime progress values on entry
    Future.microtask(() async {
      await _loadProgress();
      await _refreshDownloaded();
    });
  }

  // Enhanced haptic feedback for download progress
  Timer? _hapticTimer;
  
  void _startHapticFeedback() async {
    if (_hapticTimer != null) return;
    
    // Initial strong haptic feedback
    await HapticFeedback.heavyImpact();
    
    // Continuous haptic feedback during download
    _hapticTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (!_downloading) {
        timer.cancel();
        _hapticTimer = null;
        return;
      }
      // Vary the haptic intensity based on progress
      if (_progress < 0.3) {
        await HapticFeedback.vibrate();
      } else if (_progress < 0.7) {
        await HapticFeedback.mediumImpact();
      } else {
        // Create a pattern for the final stretch
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.lightImpact();
      }
    });
  }
  
  void _stopHapticFeedback() {
    _hapticTimer?.cancel();
    _hapticTimer = null;
    // Final confirmation haptic
    HapticFeedback.mediumImpact();
  }
  
  @override
  void dispose() {
    _hapticTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleOpen(String url, String filename) async {
    // Strong initial haptic
    await HapticFeedback.heavyImpact();
    
    setState(() {
      _downloading = true;
      _progress = 0;
    });
    
    // Start haptic feedback
    _startHapticFeedback();
    try {
      final path = await _fileService.ensureDownloaded(
        url: url,
        filename: filename,
        onProgress: (r, t) {
          if (!mounted) return;
          setState(() => _progress = t > 0 ? r / t : 0);
        },
      );
      if (!mounted) return;
      setState(() => _downloading = false);
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PDFViewerScreen(filePath: path, title: filename)),
      );
      await _loadProgress();
      await _refreshDownloaded();
    } catch (e) {
      if (!mounted) return;
      // Error haptic pattern
      await HapticFeedback.vibrate();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.vibrate();
      _stopHapticFeedback();
      setState(() => _downloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed. Please check your connection and permissions.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SuvyAIkth (Prototype 1)')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Science – Class 10', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Container(height: 1, color: Colors.black12),
                const SizedBox(height: 12),
                // Quick action: Gemini Quiz
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _openQuiz,
                    icon: const Icon(Icons.quiz_outlined),
                    label: const Text('Gemini Quiz'),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: [
                      _UnitCard(
                        color: const Color(0xFF00BFA6),
                        icon: Icons.science,
                        title: 'Unit 1: Matter in Our Surroundings',
                        subtitle: 'Science – Class 10',
                        progress: _progressBy['iesc101.pdf'] ?? 0,
                        downloaded: _downloadedBy['iesc101.pdf'] ?? false,
                        onOpen: () => _handleOpen('https://ncert.nic.in/textbook/pdf/iesc101.pdf', 'iesc101.pdf'),
                      ),
                      _UnitCard(
                        color: const Color(0xFF00BFA6),
                        icon: Icons.biotech_outlined,
                        title: 'Unit 2: Is Matter Around Us Pure?',
                        subtitle: 'Science – Class 10',
                        progress: _progressBy['iesc102.pdf'] ?? 0,
                        downloaded: _downloadedBy['iesc102.pdf'] ?? false,
                        onOpen: () => _handleOpen('https://ncert.nic.in/textbook/pdf/iesc102.pdf', 'iesc102.pdf'),
                      ),
                      _UnitCard(
                        color: const Color(0xFF00BFA6),
                        icon: Icons.bubble_chart_outlined,
                        title: 'Unit 3: Atoms and Molecules',
                        subtitle: 'Science – Class 10',
                        progress: _progressBy['iesc103.pdf'] ?? 0,
                        downloaded: _downloadedBy['iesc103.pdf'] ?? false,
                        onOpen: () => _handleOpen('https://ncert.nic.in/textbook/pdf/iesc103.pdf', 'iesc103.pdf'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Analytics coming soon')),
                          );
                        },
                        icon: const Icon(Icons.insights_outlined),
                        label: const Text('View Analytics'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Plan Study Day coming soon')),
                          );
                        },
                        icon: const Icon(Icons.event_note_outlined),
                        label: const Text('Plan Study Day'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_downloading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Downloading…'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 220,
                      child: LinearProgressIndicator(value: _progress > 0 ? _progress : null),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.downloaded,
    required this.onOpen,
  });
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final double progress;
  final bool downloaded;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final pct = (progress.clamp(0, 1) * 100).round();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular progress + icon
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0, 1),
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    backgroundColor: Colors.black12,
                  ),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Titles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (downloaded)
                        Row(children: [
                          Icon(Icons.check_circle, color: color, size: 16),
                          const SizedBox(width: 6),
                          const Text('Downloaded'),
                        ])
                      else
                        const Text('Tap to download/open'),
                      const SizedBox(width: 8),
                      Text('•  $pct%'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Action
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 80),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: Theme.of(context).textTheme.labelMedium,
                ),
                onPressed: onOpen,
                child: Text(
                  progress >= 1.0
                      ? 'Complete'
                      : (progress > 0 ? 'Resume' : 'Open'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
