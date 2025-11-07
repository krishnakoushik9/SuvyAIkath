import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = const [
      _SubjectProgress('Science', 0xFF00BFA6, 0.62),
      _SubjectProgress('Maths', 0xFF4F46E5, 0.35),
      _SubjectProgress('English', 0xFFF87171, 0.48),
      _SubjectProgress('Social', 0xFFF59E0B, 0.22),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DailyQuote(),
          const SizedBox(height: 16),
          _Card(
            title: 'Hours studied (Mon–Sun)',
            child: SizedBox(height: 180, child: _WeeklyHoursChart()),
          ),
          const SizedBox(height: 12),
          _Card(
            title: 'Completion by subject',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final s in subjects)
                  _Donut(
                    label: s.name,
                    color: Color(s.color),
                    value: s.progress,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            title: 'Weekly insights',
            child: const Text('Great consistency! Science is your top subject this week.'),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _WeeklyHoursChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = [1.0, 1.5, 0.5, 2.0, 1.2, 2.5, 1.8];
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 3,
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
              const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              final i = v.toInt();
              return i >= 0 && i < labels.length
                  ? Text(labels[i])
                  : const SizedBox.shrink();
            }),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i])],
            isCurved: true,
            barWidth: 3,
            color: Theme.of(context).colorScheme.primary,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }
}

class _Donut extends StatelessWidget {
  const _Donut({required this.label, required this.color, required this.value});
  final String label;
  final Color color;
  final double value;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 36,
                  sections: [
                    PieChartSectionData(value: value, color: color, showTitle: false, radius: 14),
                    PieChartSectionData(value: 1 - value, color: Colors.black12, showTitle: false, radius: 14),
                  ],
                ),
              ),
              Text('${(value * 100).round()}%'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}

class _DailyQuote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quotes = const [
      'Small progress is still progress.',
      'Study smarter, not harder.',
      'Consistency beats intensity.',
      'Every page counts.',
    ];
    final day = DateTime.now().weekday; // 1..7
    final q = quotes[(day - 1) % quotes.length];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.format_quote_rounded),
            const SizedBox(width: 12),
            Expanded(child: Text(q)),
          ],
        ),
      ),
    );
  }
}

class _SubjectProgress {
  final String name;
  final int color;
  final double progress;
  const _SubjectProgress(this.name, this.color, this.progress);
}
