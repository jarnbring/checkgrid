import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gamename/game/block.dart';
import 'package:gamename/game/piecetype.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<List<Block?>> board = List.generate(8, (_) => List.filled(8, null));

  late List<PieceType> selectedPieces;

  double imageWidth = 50;
  double imageHeight = 50;

  @override
  void initState() {
    super.initState();

    final random = Random();

    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 8; col++) {
        if (random.nextBool()) {
          board[row][col] = Block(isActive: true);
        }
      }
    }

    final allPieces = List<PieceType>.from(PieceType.values)..shuffle();
    selectedPieces = allPieces.take(3).toList();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CheckGrid"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(40),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 3,
                  childAspectRatio: 1,
                ),
                itemCount: 64,
                itemBuilder: (context, index) {
                  final row = index ~/ 8;
                  final col = index % 8;
                  final block = board[row][col];

                  return DragTarget<PieceType>(
                    onAcceptWithDetails: (details) {
                      setState(() {
                        board[row][col] = Block(piece: details.data, isActive: false);
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: block?.color ?? Colors.grey[300],  // Använd färgen från blocket
                        ),
                        child: block?.piece != null
                            ? Image.asset(
                                'assets/images/white_${block!.piece!.name}.png',
                                fit: BoxFit.contain,
                              )
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(color: const Color.fromARGB(255, 27, 209, 255)),
              width: 350,
              child: Row(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var piece in selectedPieces)
                    Draggable<PieceType>(
                      data: piece,
                      feedback: Image.asset(
                        'assets/images/white_${piece.name}.png',
                        height: imageHeight,
                        width: imageWidth,
                        cacheHeight: (imageHeight * 1.5).toInt(),
                        cacheWidth: (imageWidth * 1.0).toInt(),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.2,
                        child: Image.asset(
                          'assets/images/white_${piece.name}.png',
                          height: 50,
                          width: 50,
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/white_${piece.name}.png',
                        height: 50,
                        width: 50,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
