import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PDFViewerScreen extends StatelessWidget {
  const PDFViewerScreen({super.key, required this.filePath, required this.title});
  final String filePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    final exists = File(filePath).existsSync();
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: exists
          ? _TrackedPdf(filePath: filePath, title: title)
          : const Center(child: Text('File not found')),
    );
  }
}

class _TrackedPdf extends StatefulWidget {
  const _TrackedPdf({required this.filePath, required this.title});
  final String filePath;
  final String title;

  @override
  State<_TrackedPdf> createState() => _TrackedPdfState();
}

class _TrackedPdfState extends State<_TrackedPdf> {
  int _pages = 0;

  String get _keyBase => widget.title; // using filename as key

  Future<void> _saveProgress(int page, int total) async {
    final prefs = await SharedPreferences.getInstance();
    final fraction = total > 0 ? (page + 1) / total : 0.0;
    await prefs.setInt('page_$_keyBase', page);
    await prefs.setInt('pages_$_keyBase', total);
    await prefs.setDouble('progress_$_keyBase', fraction.clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return PDFView(
      filePath: widget.filePath,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      onRender: (pages) async {
        _pages = pages ?? 0;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('pages_$_keyBase', _pages);
      },
      onPageChanged: (page, total) {
        final p = page ?? 0;
        final t = total ?? _pages;
        _saveProgress(p, t);
      },
    );
  }
}
