import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gamename/game/block.dart';
import 'package:gamename/game/piecetype.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  // Create a 2D board with nulls (empty cells)
  List<List<Block?>> board = List.generate(8, (_) => List.filled(8, null));

  late List<PieceType> selectedPieces; // This is used for randomizing the user's pieces
  late AnimationController _animationController; // Controller for the animation
  late Animation<double> _fadeAnimation; // Fade animation for pieces

  // Constants
  final double imageWidth = 50;
  final double imageHeight = 50;
  final int boardWidth = 8; // Measured in cells
  final int boardHeight = 8; // Measured in cells

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for fade-in effect
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Initialize the fade animation after the controller is ready
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(_animationController);

    // Initialize other elements
    initKillingCells();
    
    // Now call setPieces() after the animation controller is ready
    setPieces();
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose the animation controller
    super.dispose();
  }

  void setPieces() {
    // Retrieves all pieces the user can get
    final allPieces = List<PieceType>.from(PieceType.values)..shuffle();
    // Randomizes the pieces
    selectedPieces = allPieces.take(3).toList();

    // Start the fade-in animation when new pieces are added
    _animationController.forward(from: 0.0); // Start the animation from 0.0
  }

  void initKillingCells() {
    final random = Random();

    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < boardWidth; col++) {
        if (random.nextBool()) {
          board[row][col] = Block(isActive: true);
        }
      }
    }
  }

  Color setCellColor(Block? block) {
    if (block == null) {
      return Colors.grey; // Empty cell
    } else if (block.isActive) {
      return Colors.red; // Killcell
    } else if (block.piece != null) {
      return Colors.blue; // Piece on the cell
    }
    return Colors.green; // Targeted cell
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
                        board[row][col] = Block(
                          piece: details.data,
                          isActive: false,
                        ); // Initializes the board
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: setCellColor(board[row][col]),
                        ),
                        child:
                            block?.piece != null
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
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 27, 209, 255),
              ),
              width: 350,
              child: Row(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Using AnimatedBuilder to handle fade transition of pjäser
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Row(
                          children: selectedPieces
                              .map((piece) => Draggable<PieceType>(
                                    data: piece,
                                    feedback: Image.asset(
                                      'assets/images/white_${piece.name}.png',
                                      height: imageHeight,
                                      width: imageWidth,
                                      cacheHeight: (imageHeight * 1.5).toInt(),
                                      cacheWidth: (imageWidth * 1.0).toInt(),
                                    ),
                                    onDragEnd: (details) {
                                      if (details.wasAccepted) {
                                        setState(() {
                                          selectedPieces.remove(piece); // Tar bort pjäsen från selectedPieces om den accepterades
                                        });
                                      }
                                      if (selectedPieces.isEmpty) {
                                        setState(() {
                                          setPieces(); // Uppdaterar pjäserna när det inte finns några kvar.
                                        });
                                      }
                                    },
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
                                  ))
                              .toList(),
                        ),
                      );
                    },
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
