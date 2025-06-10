import 'package:flutter/material.dart';

class StatsiticsPage extends StatefulWidget {
  const StatsiticsPage({super.key});

  @override
  State<StatsiticsPage> createState() => _StatsiticsPageState();
}

class _StatsiticsPageState extends State<StatsiticsPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildStatistic(
    String title,
    double data, {
    bool? isWide,
    bool? isTime,
  }) {
    return Container(
      height: 125,
      width: isWide == null ? 150 : 315,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(200, 0, 0, 0),
            blurRadius: 8,
            offset: Offset(4, 4),
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
              '${data.toInt()}${isTime == true ? ' h' : ''}',
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
        title: Text("Statistics", style: TextStyle(fontSize: 22)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.center,
                children: [
                  _buildStatistic("Rounds", 194.0),
                  _buildStatistic("Time played", 358.0, isTime: true),
                  _buildStatistic("Highscore", 9999999999999.0, isWide: true),
                  _buildStatistic("Pieces placed", 19867.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
