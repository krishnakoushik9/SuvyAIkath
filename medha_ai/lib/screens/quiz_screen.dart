import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_question.dart';
import '../services/gemini_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with WidgetsBindingObserver {
  final _gemini = GeminiService();
  List<QuizQuestion> _questions = [];
  int _index = 0;
  int _score = 0;
  bool _loading = false;
  bool _answered = false;
  bool _initialized = false;
  bool _connected = false;

  Future<void> _loadQuiz() async {
    setState(() => _loading = true);
    try {
      final list = await _gemini.generateQuiz('Chemical Reactions and Equations');
      _questions = list.map((e) => QuizQuestion.fromMap(e as Map<String, dynamic>)).toList();
      await _cacheQuiz(list);
      _connected = true;
    } catch (_) {
      try {
        final fb = await _gemini.loadFallbackQuiz();
        _questions = fb.map((e) => QuizQuestion.fromMap(e as Map<String, dynamic>)).toList();
        _connected = false;
      } catch (_) {
        _questions = [];
        _connected = false;
      }
    }
    setState(() {
      _index = 0;
      _score = 0;
      _answered = false;
      _loading = false;
    });
  }

  Future<void> _cacheQuiz(List<dynamic> raw) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quiz_cache.json', jsonEncode(raw));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Auto-generate on first entry
    Future.microtask(() async {
      if (!_initialized) {
        _initialized = true;
        await _loadQuiz();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Regenerate on app wake
      _loadQuiz();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Gemini status pill
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (_connected ? Colors.green : Colors.red).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _connected ? Colors.green : Colors.red, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _connected ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_connected ? 'Gemini: Connected' : 'Gemini: Offline',
                        style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_loading) const LinearProgressIndicator(),
            if (!_loading && _questions.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Q${_index + 1}/${_questions.length}  •  Score: $_score',
                    style: Theme.of(context).textTheme.labelLarge),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _QuestionView(
                  key: ValueKey<int>(_index), // This forces a complete rebuild when index changes
                  question: _questions[_index],
                  answered: _answered,
                  onAnswer: (isCorrect, selectedIndex) {
                    if (_answered) return;
                    setState(() {
                      _answered = true;
                      if (isCorrect) _score++;
                      _questions[_index] = _questions[_index].copyWith(
                        selectedAnswer: selectedIndex,
                        isAnswered: true,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_index > 0)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _index--;
                          _answered = _questions[_index].isAnswered;
                        });
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Previous'),
                    )
                  else
                    const SizedBox(width: 120), // Maintain consistent spacing
                  
                  if (_index < _questions.length - 1)
                    FilledButton.icon(
                      onPressed: _answered
                          ? () {
                              setState(() {
                                _index++;
                                _answered = _questions[_index].isAnswered;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(_answered ? 'Next' : 'Select an answer'),
                    )
                  else if (_answered)
                    FilledButton.icon(
                      onPressed: () {
                        // Show results or restart quiz
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Quiz Complete!'),
                            content: Text('Your score: $_score/${_questions.length}'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _loadQuiz();
                                },
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Finish Quiz'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // AI Flash cards pill
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('AI Flash cards'),
                      content: const Text('Still in development'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.bolt_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('AI Flash cards'),
                    ],
                  ),
                ),
              ),
            ],
            if (!_loading && _questions.isEmpty)
              const Text('Quiz unavailable. Please try again later.'),
          ],
        ),
      ),
    );
  }
}

class _QuestionView extends StatefulWidget {
  const _QuestionView({
    Key? key,
    required this.question, 
    required this.answered,
    required this.onAnswer,
  }) : super(key: key);
  
  final QuizQuestion question;
  final bool answered;
  final void Function(bool correct, int selectedIndex) onAnswer;

  @override
  State<_QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<_QuestionView> {
  int? selected;
  
  @override
  void initState() {
    super.initState();
    selected = widget.question.selectedAnswer;
  }
  
  @override
  void didUpdateWidget(_QuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      selected = widget.question.selectedAnswer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question.question, 
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        for (var i = 0; i < widget.question.options.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: _tileColor(i),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: ListTile(
              title: Text(widget.question.options[i]),
              onTap: () {
                if (widget.answered) return;
                setState(() {
                  selected = i;
                });
                final correct = i == widget.question.correctAnswer;
                widget.onAnswer(correct, i);
              },
              trailing: _iconFor(i),
              enabled: !widget.answered || selected == i,
            ),
          ),
        const SizedBox(height: 8),
        if (widget.answered && widget.question.explanation.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Explanation:', 
                  style: Theme.of(context).textTheme.titleSmall),
              Text(widget.question.explanation,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
      ],
    );
  }

  Color _tileColor(int i) {
    if (!widget.answered) return Colors.white;
    if (i == widget.question.correctAnswer) return Colors.green.withOpacity(0.15);
    if (i == selected) return Colors.red.withOpacity(0.12);
    return Colors.white;
  }

  Widget? _iconFor(int i) {
    if (!widget.answered) return null;
    if (i == widget.question.correctAnswer) {
      return const Icon(Icons.check, color: Colors.green);
    }
    if (i == selected && i != widget.question.correctAnswer) {
      return const Icon(Icons.close, color: Colors.red);
    }
    return null;
  }
}
