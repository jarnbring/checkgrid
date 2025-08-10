import 'package:checkgrid/components/glass_box.dart';
import 'package:checkgrid/providers/board_storage.dart';
import 'package:checkgrid/providers/error_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: const Text("Statistics", style: TextStyle(fontSize: 30)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _loadStatistics(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading statistics',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
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
                    spacing: 30,
                    runSpacing: 15,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildStatistic(
                        "Highscore",
                        highscore >= BigInt.from(9223372036854775807)
                            ? 'MAX'
                            : highscore.toDouble(),
                        isWide: true,
                      ),
                      _buildStatistic("Rounds", amountOfRounds.toDouble()),
                      _buildStatistic("Pieces placed", placedPieces.toDouble()),

                      // Kommenterade statistiker kan läggas till senare
                      // _buildStatistic("Time played", 0, isTime: true),
                      // _buildStatistic("Highest combo", 0),
                      // _buildStatistic("Revives", 0),
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

  /// Laddar all statistik från GameStorage (SharedPreferences)
  Future<Map<String, dynamic>> _loadStatistics() async {
    try {
      // Hämta highscore och generell statistik parallellt för bättre prestanda
      final futures = await Future.wait([
        GameStorage.getHighScore(),
        GameStorage.getStatistics(),
      ]);

      final BigInt highscore = futures[0] as BigInt;
      final Map<String, int> stats = futures[1] as Map<String, int>;

      return {
        'highscore': highscore,
        'amountOfRounds': stats['amountOfRounds'] ?? 0,
        'placedPieces': stats['placedPieces'] ?? 0,
      };
    } catch (e) {
      // Logga fel och returnera default-värden
      ErrorService().logError(e, StackTrace.current);

      return {'highscore': BigInt.zero, 'amountOfRounds': 0, 'placedPieces': 0};
    }
  }

  Widget _buildStatistic(
    String title,
    dynamic data, {
    bool? isWide,
    bool? isTime,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withAlpha(70), width: 1.0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: GlassBox(
        height: 135,
        width: isWide == true ? 330 : 150,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Text(
                _formatStatisticValue(data, isTime),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  /// Formaterar statistikvärden för visning
  String _formatStatisticValue(dynamic data, bool? isTime) {
    final String suffix = isTime == true ? ' h' : '';

    if (data is String) {
      return '$data$suffix';
    }

    if (data is double || data is int) {
      final int value = data.toInt();
      return '${NumberFormat('#,###').format(value)}$suffix';
    }

    return '0$suffix';
  }
}
