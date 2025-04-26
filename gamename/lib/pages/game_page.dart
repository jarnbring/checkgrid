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

  late List<PieceType>
  selectedPieces; // This is used for randomizing the user's pieces
  late AnimationController _animationController; // Controller for the animation
  late Animation<double> _fadeAnimation; // Fade animation for pieces

  // Constants
  final double imageWidth = 50;
  final double imageHeight = 50;
  final int boardWidth = 8; // Measured in cells
  final int boardHeight = 8; // Measured in cells

  int? y;
  int? x;
  List<Point> selectedPiecesPositions = [];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(_animationController);

    initKillingCells();

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
    _animationController.forward(from: 0.0);
  }

  void initKillingCells() {
    final random = Random();

    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < boardWidth; col++) {
        if (random.nextBool()) {
          board[row][col] = Block(position: Point(row, col), isActive: true);
        }
      }
    }
  }

  Color setCellColor(Block? block) {
    if (block == null) {
      return Colors.grey;
    } else if (block.color != null) {
      return block.color!;
    }
    return Colors.green;
  }

  void showTargetedCells(
    DragTargetDetails<PieceType> details,
    int row,
    int col,
  ) {
    setState(() {
      for (var direction in details.data.movementPattern.directions) {
        for (var offset in direction.offsets) {
          int newRow = row;
          int newCol = col;

          int steps =
              details.data.movementPattern.canMoveMultipleSquares ? 8 : 1;

          for (int i = 0; i < steps; i++) {
            newRow += offset.dy.toInt();
            newCol += offset.dx.toInt();

            if (newRow < 0 ||
                newRow >= boardHeight ||
                newCol < 0 ||
                newCol >= boardWidth)
              break;

            if (board[newRow][newCol] != null &&
                board[newRow][newCol]!.isActive) {
              // Markera cellen om den är aktiv
              board[newRow][newCol]!.isTargeted = true;
              // Stanna efter att en aktiv cell träffas
              break;
            } else if (board[newRow][newCol] != null) {
              // Om det finns något hinder men inte aktiv -> stoppa
              break;
            }
            // Om det är null (tom ruta), fortsätt gå i riktningen
          }
        }
      }
    });
  }

  void setPiecesAndRemoveBlocks() {
    setState(() {
      for (int row = 0; row < boardHeight; row++) {
        for (int col = 0; col < boardWidth; col++) {
          if (board[row][col]?.isTargeted == true) {
            board[row][col] = null;
          }
          if (selectedPiecesPositions.contains(Point(row, col))) {
            board[row][col] = null;
          }
        }
      }
      selectedPiecesPositions.clear();
      setPieces();
      spawnNewRows();
    });
  }

  void spawnNewRows() {
    update();
    for (int row = boardHeight - 1; row > 0; row--) {
      board[row] = List<Block?>.from(board[row - 1]);
    }
    board[0] = List<Block?>.filled(boardWidth, null);
    initKillingCells();
  }

void update() {
  setState(() {
    for (int row = 0; row < boardHeight; row++) {
      for (int col = 0; col < boardWidth; col++) {
        if (board[row][col] == null) {
          board[row][col]?.color = Colors.grey;
        } else if (board[row][col]!.piece != null) {
          board[row][col]?.color = Colors.blue;
        } else {
          // Bestäm färg baserat på rad
          if (row < 1 && board[row][col] != null && board[row][col]!.isActive) {
            board[row][col]?.color = Colors.green;
          } else if (row >= 1 && row < 3 && board[row][col] != null && board[row][col]!.isActive) {
            board[row][col]?.color = Colors.orange;
          } else if (row >= 3 && row < 5 && board[row][col] != null && board[row][col]!.isActive) {
            board[row][col]?.color = Colors.red;
          } else if (row > 5 && row <= 7 && board[row][col] == null) {
            board[row][col]?.color = Colors.deepPurple; // Botten blir lila
          }
        }
      }
    }
  });
}



  Widget _buildContinueButton() {
    return GestureDetector(
      onTap: setPiecesAndRemoveBlocks,
      child: Container(
        width: 3 * 50 + 2 * 10, // 3 bilder + 2 mellanrum (10px varje)
        height: 50, // samma höjd som bilderna
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 57, 159, 255),
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          "Continue",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CheckGrid", style: TextStyle(fontSize: 25)),
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
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 10),
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
                    onWillAcceptWithDetails: (data) {
                      return board[row][col] == null;
                    },
                    onAcceptWithDetails: (details) {
                      setState(() {
                        board[row][col] = Block(
                          position: Point(row, col),
                          piece: details.data,
                          isActive: false,
                        );
                        showTargetedCells(details, row, col);
                        selectedPiecesPositions.add(Point(row, col));
                        selectedPieces.remove(details.data);
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: setCellColor(board[row][col]),
                        ),
                        child:
                            block != null
                                ? (block.piece != null
                                    ? Image.asset(
                                      'assets/images/white_${block.piece!.name}.png',
                                      fit: BoxFit.contain,
                                    )
                                    : (block.isTargeted
                                        ? Image.asset(
                                          'assets/images/cross.png', // Lägg till en bild på ett kryss i assets/images
                                          fit: BoxFit.contain,
                                        )
                                        : null))
                                : null,
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 57, 159, 255),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child:
                              selectedPieces.isEmpty
                                  ? _buildContinueButton()
                                  : Row(
                                    spacing: 10,
                                    children:
                                        selectedPieces
                                            .map(
                                              (piece) => Draggable<PieceType>(
                                                data: piece,
                                                feedback: Image.asset(
                                                  'assets/images/white_${piece.name}.png',
                                                  height: imageHeight,
                                                  width: imageWidth,
                                                  cacheHeight:
                                                      (imageHeight * 1.5)
                                                          .toInt(),
                                                  cacheWidth:
                                                      (imageWidth * 1.0)
                                                          .toInt(),
                                                ),
                                                onDragEnd: (details) {
                                                  if (details.wasAccepted) {
                                                    setState(() {
                                                      selectedPieces.remove(
                                                        piece,
                                                      );
                                                    });
                                                  }
                                                  if (selectedPieces.isEmpty) {
                                                    _buildContinueButton();
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
                                              ),
                                            )
                                            .toList(),
                                  ),
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
