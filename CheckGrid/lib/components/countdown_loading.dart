import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CountdownLoading extends StatefulWidget {
  final VoidCallback onRestart; // Callback för att anropa restartGame
  final bool isReviveShowing; // Kontrollera om revive-dialogen ska visas

  const CountdownLoading({
    super.key,
    required this.onRestart,
    required this.isReviveShowing,
  });

  @override
  State<CountdownLoading> createState() => _CountdownLoadingState();
}

class _CountdownLoadingState extends State<CountdownLoading> {
  int _counter = 5;
  late Timer _timer;
  bool _isDialogOpen = false; // För att hålla reda på om dialogen är öppen

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter == 0) {
        timer.cancel();
        if (mounted) {
          widget.onRestart();
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      } else {
        setState(() {
          _counter--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(153, 0, 0, 0),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text(
              'Game Over',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 50),
            Stack(
              alignment: Alignment.center,
              children: [
                SpinKitDoubleBounce(color: Colors.blue, size: 250.0),
                Text(
                  '$_counter',
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),

            Container(
              width: 200,
              height: 55,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 40, 188, 45), // flyttad hit
                borderRadius: BorderRadius.circular(15),
              ),
              child: GestureDetector(
                onTap: () {
                  widget
                      .onRestart(); // Kalla på callbacken för att starta om spelet
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Revive?",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
