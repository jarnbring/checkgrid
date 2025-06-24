import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  BigInt? highscore;
  BigInt? longestComboStreak;
  int? amountOfRounds;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();

    final hs = prefs.getString('highscore');
    final comboStreak = prefs.getString('longest_combo_streak');
    final roundsPlayed = prefs.getString('rounds_played');

    setState(() {
      highscore = hs != null ? BigInt.parse(hs) : BigInt.zero;
      longestComboStreak =
          comboStreak != null ? BigInt.parse(comboStreak) : BigInt.zero;
      amountOfRounds = roundsPlayed != null ? int.parse(roundsPlayed) : 0;
      isLoading = false;
    });
  }

  Widget _buildStatistic(
    String title,
    double data, {
    bool? isWide,
    bool? isTime,
  }) {
    return Container(
      height: 125,
      width: isWide == true ? 315 : 150,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(200, 0, 0, 0),
            blurRadius: 8,
            offset: Offset(2, 2),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent,
            Colors.lightBlue,
            const Color.fromARGB(255, 3, 212, 244),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Text(
              '${NumberFormat('#,###').format(data.toInt())}${isTime == true ? ' h' : ''}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics", style: TextStyle(fontSize: 22)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/menu');
            }
          },
        ),
      ),
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildStatistic("Rounds", amountOfRounds!.toDouble()),

                          _buildStatistic("Time played", 0, isTime: true),
                          _buildStatistic(
                            "Highscore",
                            highscore!.toDouble(),
                            isWide: true,
                          ),
                          _buildStatistic("Pieces placed", 0),
                          _buildStatistic(
                            "Highest combo",
                            longestComboStreak!.toDouble(),
                          ),
                          _buildStatistic(
                            "Revives",
                            amountOfRounds!.toDouble(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }
}
