import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../store/workout_store.dart';
import '../../shared/enums.dart';

class LiftProgressPage extends StatefulWidget {
  const LiftProgressPage({super.key});

  @override
  State<LiftProgressPage> createState() => _LiftProgressPageState();
}

class _LiftProgressPageState extends State<LiftProgressPage> {
  final WorkoutStore _store = WorkoutStore.instance;
  String? _selectedExerciseId;
  String? _selectedExerciseName;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() async {
    await _store.fetchExercises();
    if (_store.exercises != null && _store.exercises!.isNotEmpty) {
      setState(() {
        _selectedExerciseId = _store.exercises!.first.id;
        _selectedExerciseName = _store.exercises!.first.name;
      });
      _store.fetchLiftProgress(_selectedExerciseId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Lift Progress",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoading && (_store.exercises?.isEmpty ?? true)) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }

          final exercises = _store.exercises ?? [];

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Analyze Your Lift Performance",
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate().fadeIn().slideY(begin: 0.1),
                const SizedBox(height: 6),
                Text(
                  "Track maximum weight lifted over time to measure progressive overload gains.",
                  style: TextStyle(color: Colors.grey[600]),
                ).animate().fadeIn(delay: 100.ms),
                
                const SizedBox(height: 24),

                // Exercise Dropdown
                if (exercises.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedExerciseId,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                        dropdownColor: Colors.white,
                        items: exercises.map((e) {
                          return DropdownMenuItem<String>(
                            value: e.id,
                            child: Text(
                              e.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final name = exercises.firstWhere((e) => e.id == val).name;
                            setState(() {
                              _selectedExerciseId = val;
                              _selectedExerciseName = name;
                            });
                            _store.fetchLiftProgress(val);
                          }
                        },
                      ),
                    ),
                  ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 48),

                // Lift Chart
                Expanded(
                  child: Observer(
                    builder: (_) {
                      if (_store.progressState == LoadingStatusEnum.loading) {
                        return const Center(child: CircularProgressIndicator(color: Colors.black));
                      }
                      
                      final dataPoints = _store.liftProgress ?? [];
                      if (dataPoints.isEmpty) {
                        return Center(
                          child: Text(
                            "No sets logged yet for $_selectedExerciseName.",
                            style: TextStyle(color: Colors.grey[500], fontSize: 15),
                          ),
                        );
                      }

                      // Group by date to get max weight
                      final Map<String, double> maxWeightsByDate = {};
                      for (var dp in dataPoints) {
                        final dateStr = dp.date;
                        final w = dp.weight;
                        if (!maxWeightsByDate.containsKey(dateStr) || w > maxWeightsByDate[dateStr]!) {
                          maxWeightsByDate[dateStr] = w;
                        }
                      }

                      final sortedDates = maxWeightsByDate.keys.toList()..sort();
                      final chartSpots = <FlSpot>[];
                      for (int i = 0; i < sortedDates.length; i++) {
                        chartSpots.add(FlSpot(i.toDouble(), maxWeightsByDate[sortedDates[i]]!));
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: false),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 32,
                                        getTitlesWidget: (val, meta) {
                                          final idx = val.toInt();
                                          if (idx >= 0 && idx < sortedDates.length) {
                                            // Format date: e.g. "06/03"
                                            try {
                                              final date = DateTime.parse(sortedDates[idx]);
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  DateFormat('MM/dd').format(date),
                                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                                ),
                                              );
                                            } catch (_) {}
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (val, meta) {
                                          return Text(
                                            "${val.toInt()} kg",
                                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: chartSpots,
                                      isCurved: true,
                                      color: Colors.black,
                                      barWidth: 3.5,
                                      isStrokeCapRound: true,
                                      dotData: const FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.black.withAlpha(15),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              const Text("Max weight lifted (kg)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ],
                      ).animate().fadeIn();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
