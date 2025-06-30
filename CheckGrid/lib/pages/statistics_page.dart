import 'package:checkgrid/providers/board_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  Future<Map<String, dynamic>> _loadStatistics(BuildContext context) async {
    final boardProvider = context.watch<BoardProvider>();

    final highScoreRaw = boardProvider.getStatisticsBox.get('highScore');
    final amountOfRounds =
        boardProvider.getStatisticsBox.get('amountOfRounds') ?? 0;
    final placedPieces =
        boardProvider.getStatisticsBox.get('placedPieces') ?? 0;

    BigInt parseBigIntOrZero(dynamic value) {
      if (value == null) return BigInt.zero;
      if (value is BigInt) return value;
      if (value is int) return BigInt.from(value);
      if (value is String) {
        try {
          return BigInt.parse(value);
        } catch (_) {
          return BigInt.zero;
        }
      }
      return BigInt.zero;
    }

    return {
      'highscore': parseBigIntOrZero(highScoreRaw),
      'amountOfRounds': amountOfRounds,
      'placedPieces': placedPieces,
    };
  }

  Widget _buildStatistic(
    String title,
    dynamic data, {
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
              data is String
                  ? '$data${isTime == true ? ' h' : ''}'
                  : '${NumberFormat('#,###').format(data.toInt())}${isTime == true ? ' h' : ''}',
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Statistics", style: TextStyle(fontSize: 22)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _loadStatistics(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('No data'));
            }

            final data = snapshot.data!;
            final highscore = data['highscore'] as BigInt;
            final amountOfRounds = data['amountOfRounds'] as int;
            final placedPieces = data['placedPieces'] as int;

            return SingleChildScrollView(
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
                      _buildStatistic(
                        "Highscore",
                        highscore >= BigInt.from(9223372036854775807)
                            ? '∞'
                            : highscore.toDouble(),
                        isWide: true,
                      ),
                      _buildStatistic(
                        "Rounds",
                        amountOfRounds.toDouble(),
                        isWide: true,
                      ),
                      //_buildStatistic("Time played", 0, isTime: true),
                      _buildStatistic(
                        "Pieces placed",
                        placedPieces.toDouble(),
                        isWide: true,
                      ),
                      // _buildStatistic(
                      //  "Highest combo",
                      //  0, //longestComboStreak.toDouble(),
                      // ),
                      // _buildStatistic("Revives", amountOfRounds.toDouble()),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
