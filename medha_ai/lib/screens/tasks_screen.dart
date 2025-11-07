import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<_Task> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('tasks.json');
    if (raw != null) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _tasks = list.map((e) => _Task.fromMap(e)).toList();
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks.json', jsonEncode(_tasks.map((e) => e.toMap()).toList()));
  }

  Future<void> _addTaskDialog() async {
    final titleCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Subject • Topic')),
            const SizedBox(height: 8),
            TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Note / Time estimate (optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              setState(() {
                _tasks.add(_Task(title: titleCtrl.text.trim(), note: noteCtrl.text.trim()));
              });
              _save();
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _toggleDone(int i) {
    setState(() => _tasks[i] = _tasks[i].copyWith(done: !_tasks[i].done));
    _save();
    if (_tasks[i].done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Text('Task Completed '),
            Lottie.network('https://assets6.lottiefiles.com/packages/lf20_touohxv0.json', width: 60, repeat: false),
          ]),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📅 Today's Study Plan")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tasks.length,
              itemBuilder: (context, i) {
                final t = _tasks[i];
                return Card(
                  child: CheckboxListTile(
                    value: t.done,
                    onChanged: (_) => _toggleDone(i),
                    title: Text(t.title),
                    subtitle: t.note.isNotEmpty ? Text(t.note) : null,
                    controlAffinity: ListTileControlAffinity.leading,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _Task {
  final String title;
  final String note;
  final bool done;
  _Task({required this.title, this.note = '', this.done = false});
  _Task copyWith({String? title, String? note, bool? done}) =>
      _Task(title: title ?? this.title, note: note ?? this.note, done: done ?? this.done);
  Map<String, dynamic> toMap() => {"title": title, "note": note, "done": done};
  factory _Task.fromMap(Map<String, dynamic> m) => _Task(
        title: m['title'] as String,
        note: (m['note'] ?? '') as String,
        done: (m['done'] ?? false) as bool,
      );
}
