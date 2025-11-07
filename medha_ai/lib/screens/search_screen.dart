import 'package:flutter/material.dart';
import '../services/file_service.dart';
import 'pdf_viewer_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  bool _listening = false;
  final _fileService = FileService();
  bool _downloading = false;
  double _progress = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = const [
      ('Chapter 1: Chemical Reactions and Equations', 'https://ncert.nic.in/textbook/pdf/iesc101.pdf', 'iesc101.pdf'),
      ('Chapter 2: Acids, Bases and Salts', 'https://ncert.nic.in/textbook/pdf/iesc102.pdf', 'iesc102.pdf'),
      ('Chapter 3: Metals and Non-metals', 'https://ncert.nic.in/textbook/pdf/iesc103.pdf', 'iesc103.pdf'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Search chapters...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() => _listening = !_listening);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _listening ? Colors.black : Colors.white,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.mic, color: _listening ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final (title, url, filename) = results[i];
                      return Card(
                        child: ListTile(
                          title: Text(title as String),
                          subtitle: const Text('Tap to download/open'),
                          onTap: () async {
                            setState(() { _downloading = true; _progress = 0; });
                            final path = await _fileService.ensureDownloaded(
                              url: url as String,
                              filename: filename as String,
                              onProgress: (r, t) { if (!mounted) return; setState(() { _progress = t>0? r/t : 0; }); },
                            );
                            if (!mounted) return;
                            setState(() { _downloading = false; });
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => PDFViewerScreen(filePath: path, title: filename as String)),
                            );
                          },
                        ),
                      );
                    },
                  ),
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
