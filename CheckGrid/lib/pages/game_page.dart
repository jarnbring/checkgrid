import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:CheckGrid/animations/game_animations.dart';
import 'package:CheckGrid/ads/banner_ad.dart';
import 'package:CheckGrid/components/countdown_loading.dart';
import 'package:CheckGrid/components/icon_widget.dart';
import 'package:CheckGrid/game/block.dart';
import 'package:CheckGrid/game/difficulty.dart';
import 'package:CheckGrid/game/piecetype.dart';
import 'package:CheckGrid/providers/settings_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late GameAnimations _animations;
  late bool useGlossEffect;

  final imageWidth = 50.0, imageHeight = 50.0;
  final boardWidth = 8, boardHeight = 8, comboRequirement = 6;

  // Initialize an empty board and pieces
  List<List<Block?>> board = List.generate(8, (_) => List.filled(8, null));
  List<PieceType> selectedPieces = [];
  List<Point<int>> selectedPiecesPositions = [];
  Map<Point<int>, List<Block>> targetedCellsMap = {};
  List<Block> previewCells = [];

  BigInt currentScore = BigInt.zero, comboCount = BigInt.zero;
  BigInt latestHighScore = BigInt.zero, displayedHighscore = BigInt.zero;

  bool isReviveShowing = false;
  bool isGameOver = false;

  Difficulty _difficulty = Difficulty.normal;

  @override
  void initState() {
    super.initState();

    _animations = GameAnimations(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadGameState();
      if (selectedPieces.isEmpty &&
          board.every((row) => row.every((block) => block == null))) {
        initKillingCells(_difficulty);
        setPieces();
      } else if (selectedPieces.isNotEmpty ||
          selectedPiecesPositions.isNotEmpty) {
        _animations.animationController.forward(from: 0.0);
      }
      update();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _saveGameState();
    _animations.dispose();
    super.dispose();
  }

  void update() {
    if (loseCondition()) return;
    setState(() {
      // Updating colors
      for (var row = 0; row < boardHeight; row++) {
        for (var col = 0; col < boardWidth; col++) {
          final cell = board[row][col];
          if (row >= 6) {
            if (cell == null) {
              board[row][col] = Block(
                position: Point<int>(row, col),
                isActive: false,
                hasPiece: false,
                fallbackColor: Colors.blueGrey,
              );
            }
          } else if (cell != null) {
            if (cell.hasPiece || cell.piece != null) {
              cell.gradient =
                  useGlossEffect
                      ? const LinearGradient(
                        colors: [
                          Colors.blue,
                          Color.fromARGB(255, 100, 180, 255),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                      : null;
              cell.fallbackColor = Colors.blue;
            } else if (cell.isActive) {
              if (row < 2) {
                cell.gradient =
                    useGlossEffect
                        ? const LinearGradient(
                          colors: [
                            Colors.green,
                            Color.fromARGB(255, 150, 255, 150),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : null;
                cell.fallbackColor = Colors.green;
              } else if (row < 4) {
                cell.gradient =
                    useGlossEffect
                        ? const LinearGradient(
                          colors: [
                            Colors.orange,
                            Color.fromARGB(255, 255, 200, 100),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : null;
                cell.fallbackColor = Colors.orange;
              } else {
                cell.gradient =
                    useGlossEffect
                        ? const LinearGradient(
                          colors: [
                            Colors.red,
                            Color.fromARGB(255, 255, 100, 100),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : null;
                cell.fallbackColor = Colors.red;
              }
            }
          }
        }
      }
    });
  }

  void _restartGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('game_board');
    await prefs.remove('selected_pieces');
    await prefs.remove('current_score');
    await prefs.remove('combo_count');
    await prefs.remove('selected_pieces_positions');
    await prefs.remove('targeted_cells_map');
    await prefs.remove('preview_cells');

    setState(() {
      board = List.generate(8, (_) => List.filled(8, null));
      selectedPiecesPositions.clear();
      targetedCellsMap.clear();
      setPieces();
      initKillingCells(_difficulty);
      previewCells.clear();
      currentScore = BigInt.zero;
      comboCount = BigInt.zero;
      displayedHighscore = latestHighScore;
      isReviveShowing = false;
      isGameOver = false;
    });
  }

  void setPieces() {
    final all = List.of(PieceType.values)..shuffle();
    selectedPieces = all.take(3).toList();
    setState(() {
      _animations.animationController.forward(from: 0.0);
    });
  }

  void initKillingCells(Difficulty difficulty) {
    assert(difficulty.spawnRate >= 0.0 && difficulty.spawnRate <= 1.0);
    int newRows = 2;
    if (difficulty == Difficulty.max) {
      newRows = 3;
    }
    final rng = Random();
    for (var row = 0; row < newRows; row++) {
      for (var col = 0; col < boardWidth; col++) {
        if (rng.nextDouble() < difficulty.spawnRate) {
          board[row][col] = Block(
            position: Point<int>(row, col),
            isActive: true,
            gradient:
                useGlossEffect
                    ? const LinearGradient(
                      colors: [
                        Colors.green,
                        Color.fromARGB(255, 150, 255, 150),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            fallbackColor: Colors.green,
          );
        }
      }
    }
    update();
  }

  void addScore() async {
    final allTargetedCells =
        targetedCellsMap.values.expand((cells) => cells).toSet().toList();
    final count = allTargetedCells.length;
    comboCount =
        count >= comboRequirement ? comboCount + BigInt.one : BigInt.zero;
    final base = BigInt.from(10) * BigInt.from(count);
    final totalScore = base * (comboCount + BigInt.one);

    final oldScore = currentScore;
    final newScore = oldScore + totalScore;

    final oldHigh = latestHighScore;
    final newHigh = newScore > oldHigh ? newScore : oldHigh;
    if (newScore > oldHigh) {
      await _saveHighscore(newScore);
      latestHighScore = newHigh;
    }

    final scoreAnim = _animations.animateBigInt(
      oldScore,
      newScore,
      (v) => setState(() => currentScore = v),
    );
    final highAnim =
        (newScore > oldHigh)
            ? _animations.animateBigInt(
              oldHigh,
              newHigh,
              (v) => setState(() => displayedHighscore = v),
            )
            : Future.value();

    await Future.wait([scoreAnim, highAnim]);
  }

  void spawnNewRows(Difficulty difficulty) {
    if (isReviveShowing) return;
    for (var row = boardHeight - 1; row > 0; row--) {
      board[row] = List.from(board[row - 1]);
    }
    board[0] = List.filled(boardWidth, null);
    addScore();
    initKillingCells(_difficulty);
    targetedCellsMap.clear();
    update();
  }

  void setPiecesAndRemoveBlocks() {
    setState(() {
      update();
      for (var r = 0; r < boardHeight; r++) {
        for (var c = 0; c < boardWidth; c++) {
          if (board[r][c]?.isTargeted == true ||
              selectedPiecesPositions.contains(Point<int>(r, c))) {
            board[r][c] = null;
          }
        }
      }
      selectedPiecesPositions.clear();
      setPieces();
      spawnNewRows(_difficulty);
    });
  }

  void showTargetedCells(
    DragTargetDetails<PieceType> d,
    int row,
    int col, {
    bool isPreviewMode = false,
  }) {
    setState(() {
      if (isPreviewMode) {
        for (var block in previewCells) {
          block.isPreview = false;
        }
        previewCells.clear();
      } else {
        List<Block> currentTargeted = [];
        for (var dir in d.data.movementPattern.directions) {
          for (var off in dir.offsets) {
            var nr = row, nc = col;
            final steps = d.data.movementPattern.canMoveMultipleSquares ? 8 : 1;
            for (var i = 0; i < steps; i++) {
              nr += off.dy.toInt();
              nc += off.dx.toInt();
              if (nr < 0 || nr >= boardHeight || nc < 0 || nc >= boardWidth)
                break;
              final b = board[nr][nc];
              if (b != null && b.isActive) {
                b.isTargeted = true;
                currentTargeted.add(b);
                break;
              }
            }
          }
        }
        targetedCellsMap[Point<int>(row, col)] = currentTargeted;
      }

      if (isPreviewMode) {
        for (var dir in d.data.movementPattern.directions) {
          for (var off in dir.offsets) {
            var nr = row, nc = col;
            final steps = d.data.movementPattern.canMoveMultipleSquares ? 8 : 1;
            for (var i = 0; i < steps; i++) {
              nr += off.dy.toInt();
              nc += off.dx.toInt();
              if (nr < 0 || nr >= boardHeight || nc < 0 || nc >= boardWidth)
                break;
              final b = board[nr][nc];
              if (b != null && b.isActive) {
                b.isPreview = true;
                previewCells.add(b);
                break;
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
          isGameOver = true;
          return true;
        }
      }
    }
    isGameOver = false;
    return false;
  }

  void _doVibration(int impact) {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    if (!settingsProvider.isVibrationOn) {
      return;
    }

    switch (impact) {
      case 1:
        HapticFeedback.lightImpact();
        break;
      case 2:
        HapticFeedback.mediumImpact();
        break;
      case 3:
        HapticFeedback.heavyImpact();
        break;
      case 4:
        HapticFeedback.vibrate();
        break;
    }
  }

  Widget _buildSelectedPieces() {
    const iconSize = 75.0;
    const extraVisualOffset = Offset(0, -20);
    return Container(
      width: 250,
      height: iconSize + 28,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: useGlossEffect ? null : const Color.fromARGB(255, 57, 159, 255),
        gradient:
            useGlossEffect
                ? const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 57, 159, 255),
                    Color.fromARGB(255, 100, 180, 255),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
                : null,
        borderRadius: BorderRadius.circular(30),
        boxShadow:
            useGlossEffect
                ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: AnimatedBuilder(
        animation: _animations.fadeAnimation,
        builder:
            (_, __) => Opacity(
              opacity: _animations.fadeAnimation.value,
              child:
                  selectedPieces.isEmpty && selectedPiecesPositions.isNotEmpty
                      ? GestureDetector(
                        onTap: () {
                          setPiecesAndRemoveBlocks();
                          _doVibration(2);
                        },
                        child: Container(
                          width: 250,
                          height: 50,
                          decoration: BoxDecoration(
                            color:
                                useGlossEffect
                                    ? null
                                    : const Color.fromARGB(255, 57, 159, 255),
                            gradient:
                                useGlossEffect
                                    ? const LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 57, 159, 255),
                                        Color.fromARGB(255, 100, 180, 255),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    )
                                    : null,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Continue",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            selectedPieces.map((p) {
                              Offset? dragStartLocalPosition;

                              return Flexible(
                                child: StatefulBuilder(
                                  builder: (context, setLocalState) {
                                    return GestureDetector(
                                      onPanStart: (details) {
                                        setLocalState(() {
                                          dragStartLocalPosition =
                                              details.localPosition;
                                        });
                                      },
                                      onPanEnd: (_) {
                                        setLocalState(() {
                                          dragStartLocalPosition = null;
                                        });
                                      },
                                      child: Draggable<PieceType>(
                                        data: p,
                                        feedback:
                                            dragStartLocalPosition == null
                                                ? Image.asset(
                                                  'assets/images/white_${p.name}.png',
                                                  width: imageWidth,
                                                  height: imageHeight,
                                                )
                                                : Transform.translate(
                                                  offset:
                                                      -dragStartLocalPosition! +
                                                      extraVisualOffset,
                                                  child: Image.asset(
                                                    'assets/images/white_${p.name}.png',
                                                    width: imageWidth,
                                                    height: imageHeight,
                                                  ),
                                                ),
                                        feedbackOffset:
                                            dragStartLocalPosition == null
                                                ? Offset.zero
                                                : -dragStartLocalPosition! +
                                                    extraVisualOffset,
                                        childWhenDragging: Opacity(
                                          opacity: 0.2,
                                          child: Image.asset(
                                            'assets/images/white_${p.name}.png',
                                            width: iconSize,
                                            height: iconSize,
                                          ),
                                        ),
                                        onDragEnd: (d) {
                                          setState(() {
                                            for (var block in previewCells) {
                                              block.isPreview = false;
                                            }
                                            previewCells.clear();
                                            if (d.wasAccepted) {
                                              selectedPieces.remove(p);
                                            }
                                          });
                                          setLocalState(() {
                                            dragStartLocalPosition = null;
                                          });
                                        },
                                        child: Image.asset(
                                          'assets/images/white_${p.name}.png',
                                          width: iconSize,
                                          height: iconSize,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                      ),
            ),
      ),
    );
  }

  Widget _buildPlayArea() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),

      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
        ),
        itemCount: 64,
        itemBuilder: (_, idx) {
          final r = idx ~/ 8, c = idx % 8, b = board[r][c];
          return DragTarget<PieceType>(
            onWillAcceptWithDetails:
                (d) => b == null || (!b.hasPiece && !b.isActive),
            onAcceptWithDetails: (d) {
              if (b == null || (!b.hasPiece && !b.isActive)) {
                setState(() {
                  board[r][c] = Block(
                    position: Point<int>(r, c),
                    piece: d.data,
                    isActive: false,
                    hasPiece: true,
                    gradient:
                        useGlossEffect
                            ? const LinearGradient(
                              colors: [
                                Colors.blue,
                                Color.fromARGB(255, 100, 180, 255),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                            : null,
                    fallbackColor: Colors.blue,
                  );
                  showTargetedCells(d, r, c, isPreviewMode: false);
                  selectedPiecesPositions.add(Point<int>(r, c));
                  selectedPieces.remove(d.data);

                  _doVibration(1);
                });
              }
            },
            onMove: (details) {
              if (b == null || (!b.hasPiece && !b.isActive)) {
                showTargetedCells(details, r, c, isPreviewMode: true);
              }
            },
            onLeave: (_) {
              setState(() {
                for (var block in previewCells) {
                  block.isPreview = false;
                }
                previewCells.clear();
              });
            },
            builder:
                (_, _, _) => AnimatedBuilder(
                  animation:
                      useGlossEffect
                          ? _animations.glossAnimation
                          : Listenable.merge([]),
                  builder:
                      (context, child) => CustomPaint(
                        painter: GlossyBlockPainter(
                          gradient: b?.gradient,
                          glossPosition:
                              useGlossEffect
                                  ? _animations.glossAnimation.value
                                  : 0.0,
                          fallbackColor:
                              b == null
                                  ? (r >= 6 ? Colors.blueGrey : Colors.grey)
                                  : b.fallbackColor,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child:
                              b == null
                                  ? null
                                  : b.piece != null
                                  ? Image.asset(
                                    'assets/images/white_${b.piece!.name}.png',
                                    fit: BoxFit.contain,
                                  )
                                  : b.isTargeted
                                  ? Image.asset(
                                    'assets/images/cross.png',
                                    fit: BoxFit.contain,
                                  )
                                  : b.isPreview
                                  ? Opacity(
                                    opacity: 0.5,
                                    child: Image.asset(
                                      'assets/images/cross.png',
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                  : null,
                        ),
                      ),
                ),
          );
        },
      ),
    );
  }

  Widget _buildScore() {
    return Text(
      NumberFormat("#,###").format(currentScore.toInt()),
      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCombo() {
    return Text("Combo: $comboCount", style: const TextStyle(fontSize: 20));
  }

  Widget _buildHighscore() {
    return Text(
      "Highscore: ${NumberFormat('#,###').format(displayedHighscore.toInt())}",
      style: const TextStyle(fontSize: 20),
    );
  }

  Widget _buildScoreAndCombo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [_buildHighscore()],
    );
  }

  void _showLoseDialogSafe() {
    if (!isReviveShowing && mounted) {
      isReviveShowing = true;

      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) {
          return CountdownLoading(
            afterAd: () {
              board = List.generate(8, (_) => List.filled(8, null));
              selectedPiecesPositions.clear();
              targetedCellsMap.clear();
              setPieces();
              initKillingCells(_difficulty);
              previewCells.clear();
              isGameOver = false;
              isReviveShowing = false;
            },
            onRestart: _restartGame,
            isReviveShowing: isReviveShowing,
          );
        },
      ).then((_) {
        isReviveShowing = false;
      });
    }
  }

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Choose Difficulty', style: TextStyle())],
          ),
          content: Container(
            constraints: BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Note: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                              "This will restart your current progress and start a new game!",
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: Text('Chill'),
                    onTap: () {
                      _setDifficulty(Difficulty.chill);
                      Navigator.of(context).pop();
                    },
                    trailing: IconWidget(icon: Icons.ac_unit),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text('Normal'),
                    onTap: () {
                      _setDifficulty(Difficulty.normal);
                      Navigator.of(context).pop();
                    },
                    trailing: IconWidget(icon: Icons.headphones_rounded),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text('Max'),
                    onTap: () {
                      _setDifficulty(Difficulty.max);
                      Navigator.of(context).pop();
                    },
                    trailing: IconWidget(icon: Icons.flash_on),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _setDifficulty(Difficulty difficulty) {
    setState(() {
      _difficulty = difficulty;
      _restartGame();
    });
  }

  Future<BigInt> _loadHighscore() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('highscore');
    return s != null ? BigInt.parse(s) : BigInt.zero;
  }

  Future<void> _saveHighscore(BigInt score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('highscore', score.toString());
  }

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();

    final boardJson =
        board
            .asMap()
            .map(
              (row, cols) => MapEntry(
                row.toString(),
                cols.asMap().map(
                  (col, block) => MapEntry(col.toString(), block?.toJson()),
                ),
              ),
            )
            .values
            .toList();
    await prefs.setString('game_board', jsonEncode(boardJson));

    final piecesToSave = selectedPieces.map((p) => p.name).toList();
    await prefs.setStringList('selected_pieces', piecesToSave);

    await prefs.setString('current_score', currentScore.toString());
    await prefs.setString('combo_count', comboCount.toString());

    final positionsJson =
        selectedPiecesPositions.map((p) => {'x': p.x, 'y': p.y}).toList();
    await prefs.setString(
      'selected_pieces_positions',
      jsonEncode(positionsJson),
    );

    final targetedCellsJson = targetedCellsMap.map(
      (pos, cells) =>
          MapEntry('${pos.x},${pos.y}', cells.map((b) => b.toJson()).toList()),
    );
    await prefs.setString('targeted_cells_map', jsonEncode(targetedCellsJson));

    final previewJson = previewCells.map((b) => b.toJson()).toList();
    await prefs.setString('preview_cells', jsonEncode(previewJson));
  }

  Future<void> _loadGameState() async {
    final prefs = await SharedPreferences.getInstance();

    final boardJson = prefs.getString('game_board');
    if (boardJson != null) {
      try {
        final List<dynamic> boardData = jsonDecode(boardJson);
        board = List.generate(
          8,
          (row) => List.generate(8, (col) {
            final blockJson = boardData[row][col.toString()];
            return blockJson != null ? Block.fromJson(blockJson) : null;
          }),
        );
      } catch (e) {
        board = List.generate(8, (_) => List.filled(8, null));
      }
    }

    final pieces = prefs.getStringList('selected_pieces');
    if (pieces != null && pieces.isNotEmpty) {
      try {
        selectedPieces =
            pieces
                .map(
                  (name) => PieceType.values.firstWhere(
                    (e) => e.name == name,
                    orElse: () => throw Exception('Invalid PieceType: $name'),
                  ),
                )
                .toList();
      } catch (e) {
        debugPrint('Error loading selected pieces: $e');
        selectedPieces = [];
      }
    } else {
      selectedPieces = [];
    }

    final score = prefs.getString('current_score');
    currentScore = score != null ? BigInt.parse(score) : BigInt.zero;

    final combo = prefs.getString('combo_count');
    comboCount = combo != null ? BigInt.parse(combo) : BigInt.zero;

    final positionsJson = prefs.getString('selected_pieces_positions');
    if (positionsJson != null) {
      try {
        final List<dynamic> positionsData = jsonDecode(positionsJson);
        selectedPiecesPositions =
            positionsData
                .map((p) => Point<int>(p['x'] as int, p['y'] as int))
                .toList();
      } catch (e) {
        debugPrint('Error loading selected pieces positions: $e');
        selectedPiecesPositions = [];
      }
    }

    final targetedCellsJson = prefs.getString('targeted_cells_map');
    if (targetedCellsJson != null) {
      try {
        final Map<String, dynamic> targetedData = jsonDecode(targetedCellsJson);
        targetedCellsMap = targetedData.map((key, value) {
          final posParts = key.split(',');
          final pos = Point<int>(
            int.parse(posParts[0]),
            int.parse(posParts[1]),
          );
          final cells =
              (value as List<dynamic>)
                  .map((json) => Block.fromJson(json))
                  .toList();
          return MapEntry(pos, cells);
        });
        for (var cells in targetedCellsMap.values) {
          for (var block in cells) {
            if (board[block.position.x][block.position.y] != null) {
              board[block.position.x][block.position.y]!.isTargeted = true;
            }
          }
        }
      } catch (e) {
        targetedCellsMap = {};
      }
    }

    final previewJson = prefs.getString('preview_cells');
    if (previewJson != null) {
      try {
        final List<dynamic> previewData = jsonDecode(previewJson);
        previewCells = previewData.map((json) => Block.fromJson(json)).toList();
      } catch (e) {
        debugPrint('Error loading preview cells: $e');
        previewCells = [];
      }
    }

    final hs = await _loadHighscore();
    latestHighScore = hs;
    displayedHighscore = hs;
  }

  @override
  Widget build(BuildContext context) {
    useGlossEffect = context.watch<SettingsProvider>().useGlossEffect;

    if (loseCondition() && !isReviveShowing) {
      Future.delayed(const Duration(milliseconds: 100), _showLoseDialogSafe);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            _saveGameState().then((_) {
              if (!mounted) return;
              context.goNamed('/menu');
            });
          },
        ),
        centerTitle: true,
        title: const Text("CheckGrid", style: TextStyle(fontSize: 34)),
        actions: [
          MenuAnchor(
            builder:
                (context, controller, child) => IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                ),
            menuChildren: [
              MenuItemButton(
                onPressed: () {
                  _restartGame();
                },
                child: const Text('Restart game'),
              ),
              MenuItemButton(
                onPressed: () async {
                  context.pushNamed("/settings").then((_) => update());
                },
                child: const Text('Settings'),
              ),
              MenuItemButton(
                onPressed: () {
                  _showDifficultyDialog(context);
                },
                child: const Text('Difficulty'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            _buildScore(),
            SizedBox(height: 20),
            _buildPlayArea(),
            SizedBox(height: 20),
            _buildScoreAndCombo(),
            SizedBox(height: 20),
            _buildSelectedPieces(),
          ],
        ),
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }
}
