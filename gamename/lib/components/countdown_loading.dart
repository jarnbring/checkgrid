import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CountdownLoading extends StatefulWidget {
  final VoidCallback onRestart; // Callback för att anropa restartGame
  final bool isReviveShowing; // Kontrollera om revive-dialogen ska visas

  const CountdownLoading({super.key, required this.onRestart, required this.isReviveShowing});

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
        widget.onRestart(); // Anropa restartGame när räknaren är slut
        Navigator.pop(context); // Stänger dialogrutan eller widgeten
      }
      if (_counter > 0) {
        setState(() {
          _counter--;
        });
      } else {
        _timer.cancel();
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
    if (widget.isReviveShowing) {
      return SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Text(
              'Game Over',
              style: TextStyle(
                fontSize: 30,
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
            const SizedBox(height: 20),

            Container(
              color: const Color.fromARGB(255, 50, 226, 56),
              width: 200,
              child: GestureDetector(
                onTap: () {
                  if (!_isDialogOpen) {
                    _isDialogOpen = true; // Markera att dialogen är öppen
                    widget.onRestart(); // Kalla på callbacken för att starta om spelet
                    Navigator.pop(context); // Stänger den aktuella dialogrutan
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
