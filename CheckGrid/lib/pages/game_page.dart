import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gamename/banner_ad.dart';
import 'package:gamename/components/countdown_loading.dart';
import 'package:gamename/game/block.dart';
import 'package:gamename/game/piecetype.dart';
import 'package:gamename/providers/general_provider.dart';
import 'package:gamename/providers/settings_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  List<List<Block?>> board = List.generate(8, (_) => List.filled(8, null));

  late List<PieceType> selectedPieces;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Constants
  final int boardWidth = 8;
  final int boardHeight = 8;
  final int comboRequirement = 6;

  // Variables
  List<Point> selectedPiecesPositions = [];
  List<Block> targetedCells = [];
  bool isReviveShowing = false;
  bool isFirstLoad = true;
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
    await prefs.setString('highscore', score.toString());
  }

  Future<BigInt> getHighscore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? highscoreString = prefs.getString('highscore');
    if (highscoreString != null) {
      latestHighScore = BigInt.parse(highscoreString);
      return BigInt.parse(highscoreString);
    }
    return BigInt.zero;
  }

  void setPieces() {
    final allPieces = List<PieceType>.from(PieceType.values)..shuffle();
    selectedPieces = allPieces.take(3).toList();
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
            if (block.hasPiece || block.piece != null) {
              block.color = Colors.blue;
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
            board[row][col]!.isActive) {
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
          ),
        );
      },
    );
  }

  void _showLoseDialogSafe() {
    if (mounted) {
      _showLoseDialog(context);
    }
  }

  Widget _buildContinueButton(double cellSize, double fontSize) {
    final settingsProvider = context.watch<SettingsProvider>();
    return GestureDetector(
      onTap: setPiecesAndRemoveBlocks,
      child: Container(
        width: cellSize * 3 + cellSize * 0.4,
        height: cellSize,
        decoration: BoxDecoration(
          color:
              settingsProvider.isDarkMode
                  ? Colors.blueGrey[700]
                  : const Color.fromARGB(255, 57, 159, 255),
          borderRadius: BorderRadius.circular(cellSize * 0.6),
        ),
        alignment: Alignment.center,
        child: Text(
          "Continue",
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize * 0.9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCombo(double fontSize) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Text(
            "Combo: ${comboCount.toString()}",
            style: TextStyle(fontSize: fontSize),
          ),
        );
      },
    );
  }

  Widget _buildScore(double fontSize) {
    return Text(
      NumberFormat("#,###").format(currentScore.toInt()),
      style: TextStyle(fontSize: fontSize),
    );
  }

  Widget _buildHighscore(double fontSize) {
    return FutureBuilder<BigInt>(
      future: getHighscore(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !isFirstLoad) {
          return Text(
            "Highscore: ${NumberFormat("#,###").format(latestHighScore ?? BigInt.zero)}",
            style: TextStyle(fontSize: fontSize),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          BigInt highscore = snapshot.data ?? BigInt.zero;
          return Text(
            "Highscore: ${NumberFormat("#,###").format(highscore.toInt())}",
            style: TextStyle(fontSize: fontSize),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loseCondition() && !isReviveShowing) {
      Future.delayed(const Duration(milliseconds: 100), _showLoseDialogSafe);
    }

    // Hämta båda providers
    final generalProvider = context.watch<GeneralProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final cellSize = generalProvider.getResponsiveCellSize(context);
    final padding = generalProvider.getResponsivePadding(10, context);
    final fontSize = generalProvider.getResponsiveSize(20, context);
    final spacing = generalProvider.getResponsiveSize(3, context);
    final appBarHeight = generalProvider.getResponsiveAppBarHeight(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: appBarHeight,
        title: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              generalProvider.getResponsiveSize(20, context),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("CheckGrid", style: TextStyle(fontSize: fontSize)),
              _buildScore(fontSize),
            ],
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: fontSize),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: padding * 3,
                      vertical: padding * 1,
                    ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
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
                                  (board[row][col]!.hasPiece == false &&
                                      board[row][col]!.isActive == false));
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
                                  borderRadius: BorderRadius.circular(
                                    cellSize * 0.1,
                                  ),
                                  color:
                                      board[row][col] == null
                                          ? (row == 6 || row == 7
                                              ? (settingsProvider.isDarkMode
                                                  ? Colors.blueGrey[800]
                                                  : Colors.blueGrey)
                                              : (settingsProvider.isDarkMode
                                                  ? Colors.grey[700]
                                                  : Colors.grey))
                                          : (board[row][col]!.piece != null
                                              ? Colors.blue
                                              : board[row][col]!.color ??
                                                  Colors.grey),
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHighscore(fontSize),
                        const SizedBox(width: 50),
                        _buildCombo(fontSize),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing * 5),
                  Container(
                    decoration: BoxDecoration(
                      color:
                          settingsProvider.isDarkMode
                              ? Colors.blueGrey[700]
                              : const Color.fromARGB(255, 57, 159, 255),
                      borderRadius: BorderRadius.circular(
                        generalProvider.getResponsiveSize(30, context),
                      ),
                    ),
                    padding: EdgeInsets.all(padding),
                    child: AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child:
                              selectedPieces.isEmpty
                                  ? _buildContinueButton(cellSize, fontSize)
                                  : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:
                                        selectedPieces
                                            .map(
                                              (piece) => Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: spacing,
                                                ),
                                                child: Draggable<PieceType>(
                                                  data: piece,
                                                  feedback: Image.asset(
                                                    'assets/images/white_${piece.name}.png',
                                                    height: cellSize,
                                                    width: cellSize,
                                                    cacheHeight:
                                                        (cellSize * 1.5)
                                                            .toInt(),
                                                    cacheWidth:
                                                        (cellSize).toInt(),
                                                  ),
                                                  onDragEnd: (details) {
                                                    if (details.wasAccepted) {
                                                      setState(() {
                                                        selectedPieces.remove(
                                                          piece,
                                                        );
                                                      });
                                                    }
                                                  },
                                                  childWhenDragging: Opacity(
                                                    opacity: 0.2,
                                                    child: Image.asset(
                                                      'assets/images/white_${piece.name}.png',
                                                      height: cellSize,
                                                      width: cellSize,
                                                    ),
                                                  ),
                                                  child: Image.asset(
                                                    'assets/images/white_${piece.name}.png',
                                                    height: cellSize,
                                                    width: cellSize,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(child: BannerAdWidget()),
    );
  }
}
