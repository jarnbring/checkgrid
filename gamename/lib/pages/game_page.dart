import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gamename/components/countdown_loading.dart';
import 'package:gamename/game/block.dart';
import 'package:gamename/game/piecetype.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final int comboRequirement = 6;

  // Variables
  int? y;
  int? x;
  List<Point> selectedPiecesPositions = [];
  List<Block> targetedCells = [];
  bool isReviveShowing = false;
  bool? isFirstLoad;
  BigInt currentScore = BigInt.zero;
  BigInt comboCount = BigInt.zero;
  BigInt? latestHighScore;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(_animationController);

    isFirstLoad = true;
    getHighscore();
    initKillingCells();
    setPieces();
    update();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> saveHighscore(BigInt score) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('highscore', score.toString());
  }

  Future<BigInt> getHighscore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? highscoreString = prefs.getString('highscore');
    if (highscoreString != null) {
      latestHighScore = BigInt.parse(highscoreString);
      return BigInt.parse(highscoreString);
    } else {
      return BigInt.zero;
    }
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
          board[row][col] = Block(
            position: Point(row, col),
            isActive: true,
            color: Colors.green,
          );
        }
      }
    }
    update();
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
                newCol >= boardWidth) {
              break;
            }

            if (board[newRow][newCol] != null &&
                board[newRow][newCol]!.isActive) {
              board[newRow][newCol]!.isTargeted = true;
              targetedCells.add(board[newRow][newCol]!);
              break;
            }
          }
        }
      }
    });
  }

  void setPiecesAndRemoveBlocks() {
    setState(() {
      update();
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

  void addScore() async {
    int numberOfCells = targetedCells.length;

    if (numberOfCells >= comboRequirement) {
      comboCount += BigInt.from(1);
    } else {
      comboCount = BigInt.zero;
    }

    BigInt baseScore = BigInt.from(10) * BigInt.from(numberOfCells);
    BigInt comboMultiplier = comboCount + BigInt.one;

    BigInt totalScore = baseScore * comboMultiplier;

    currentScore += totalScore;

    targetedCells.clear();

    BigInt highscore = await getHighscore();
    if (currentScore > highscore) {
      await saveHighscore(currentScore);
    }
  }

  void spawnNewRows() {
    if (isReviveShowing) return;

    // Spawn new rows
    for (int row = boardHeight - 1; row > 0; row--) {
      board[row] = List<Block?>.from(board[row - 1]);
    }
    board[0] = List<Block?>.filled(boardWidth, null);

    addScore();
    initKillingCells();
    update();
  }

  void update() {
    if (loseCondition()) return;
    setState(() {
      for (int row = 0; row < boardHeight; row++) {
        for (int col = 0; col < boardWidth; col++) {
          var block = board[row][col];

          if (row == 6 || row == 7) {
            if (block == null) {
              board[row][col] = Block(
                position: Point(row, col),
                isActive: false,
                hasPiece: false,
                color: Colors.blueGrey,
              );
            } else {
              block.color = Colors.blueGrey;
            }
          } else if (block != null) {
            // Kontrollera om blocket har en bit (hasPiece är sant)
            if (block.hasPiece) {
              block.color =
                  Colors.blue; // Sätt färgen till blå om det finns en bit
            } else if (block.piece != null) {
              block.color =
                  Colors
                      .blue; // Om det finns en bit (stycke), sätt färgen till blå
            } else if (block.isActive) {
              if (row == 0 || row == 1) {
                block.color = Colors.green;
              } else if (row == 2 || row == 3) {
                block.color = Colors.orange;
              } else if (row == 4 || row == 5) {
                block.color = Colors.red;
              }
            }
          }
        }
      }
    });
  }

  bool loseCondition() {
    for (int row = 0; row < boardHeight; row++) {
      for (int col = 0; col < boardWidth; col++) {
        if (board[row][col] != null &&
            (row == 6 || row == 7) &&
            board[row][col]?.isActive == true) {
          return true;
        }
      }
    }
    return false;
  }

  void _restartGame() {
    setState(() {
      board = List.generate(8, (_) => List.filled(8, null));
      selectedPiecesPositions.clear();
      setPieces();
      initKillingCells();
      currentScore = BigInt.zero;
      comboCount = BigInt.zero;
      isReviveShowing = false;
    });
  }

  void _showLoseDialog(BuildContext context) {
    if (isReviveShowing) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: CountdownLoading(
            onRestart: _restartGame,
            isReviveShowing: isReviveShowing,
          ), // Inkludera CountdownDialog här
        );
      },
    );
  }

  void _showLoseDialogSafe() {
    if (mounted) {
      _showLoseDialog(context);
    }
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

  Widget _buildCombo() {
    return comboCount == BigInt.zero
        ? AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Text(
                "Combo: ${comboCount.toString()}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            );
          },
        )
        : Text(
          "Combo: ${comboCount.toString()}",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
  }

  Widget _buildScore() {
    // Lägg till att det ökar nummervis, inte bara läggs till (animation?)
    return Text(
      NumberFormat("#,###").format(currentScore.toInt()),
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildHighscore() {
    return FutureBuilder<BigInt>(
      future: getHighscore(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !isFirstLoad!) {
          return Text(
            "Highscore: ${NumberFormat("#,###").format(latestHighScore)}",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          );
        } else if (snapshot.hasError) {
          return Text('Error loading highscore: ${snapshot.error}');
        } else {
          BigInt highscore = snapshot.data ?? BigInt.zero;
          return Text(
            "Highscore: ${NumberFormat("#,###").format(highscore.toInt())}",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loseCondition() && !isReviveShowing) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          _showLoseDialogSafe();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "CheckGrid",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              _buildScore(),
            ],
          ),
        ),
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
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
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
                      return (board[row][col] == null ||
                          (board[row][col]?.hasPiece == false &&
                              board[row][col]?.isActive == false));
                    },
                    onAcceptWithDetails: (details) {
                      setState(() {
                        board[row][col] = Block(
                          position: Point(row, col),
                          piece: details.data,
                          isActive: false,
                          hasPiece: true,
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
                          color:
                              board[row][col] == null
                                  ? (row == 6 || row == 7
                                      ? Colors.blueGrey
                                      : Colors.grey)
                                  : (board[row][col]?.piece != null
                                      ? Colors.blue
                                      : board[row][col]?.color ?? Colors.grey),
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
                                          'assets/images/cross.png',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHighscore(),
                const SizedBox(width: 50),
                _buildCombo(),
              ],
            ),

            const SizedBox(height: 20),

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
