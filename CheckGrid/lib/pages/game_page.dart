import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gamename/banner_ad.dart';
import 'package:gamename/components/countdown_loading.dart';
import 'package:gamename/game/block.dart';
import 'package:gamename/game/difficulty.dart';
import 'package:gamename/game/piecetype.dart';
import 'package:gamename/providers/general_provider.dart';
import 'package:gamename/settings/settings_page.dart';
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
  List<PieceType> selectedPieces = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final imageWidth = 50.0, imageHeight = 50.0;
  final boardWidth = 8, boardHeight = 8, comboRequirement = 6;

  List<Point<int>> selectedPiecesPositions = [];
  List<Block> targetedCells = [];
  bool isReviveShowing = false;
  BigInt currentScore = BigInt.zero, comboCount = BigInt.zero;
  BigInt latestHighScore = BigInt.zero, displayedHighscore = BigInt.zero;

  final double spawnRate = 0.8;
  Difficulty _difficulty = Difficulty.normal;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadGameState();
      if (selectedPieces.isEmpty &&
          board.every((row) => row.every((block) => block == null))) {
        initKillingCells(spawnRate);
        setPieces();
      } else if (selectedPieces.isNotEmpty ||
          selectedPiecesPositions.isNotEmpty) {
        // Trigger animation for loaded pieces or show Continue button
        _animationController.forward(from: 0.0);
      }
      update();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _saveGameState();
    _animationController.dispose();
    super.dispose();
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

    // Save board
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

    // Save selected pieces
    final piecesToSave = selectedPieces.map((p) => p.name).toList();
    await prefs.setStringList('selected_pieces', piecesToSave);

    // Save scores
    await prefs.setString('current_score', currentScore.toString());
    await prefs.setString('combo_count', comboCount.toString());

    // Save selected pieces positions
    final positionsJson =
        selectedPiecesPositions.map((p) => {'x': p.x, 'y': p.y}).toList();
    await prefs.setString(
      'selected_pieces_positions',
      jsonEncode(positionsJson),
    );

    // Save targeted cells (optional, as they may be transient)
    final targetedJson = targetedCells.map((b) => b.toJson()).toList();
    await prefs.setString('targeted_cells', jsonEncode(targetedJson));
  }

  Future<void> _loadGameState() async {
    final prefs = await SharedPreferences.getInstance();

    // Load board
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
        print('Error loading board: $e');
        board = List.generate(8, (_) => List.filled(8, null));
      }
    }

    // Load selected pieces
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
        print('Error loading selected pieces: $e');
        selectedPieces = [];
      }
    } else {
      selectedPieces = [];
    }

    // Load scores
    final score = prefs.getString('current_score');
    currentScore = score != null ? BigInt.parse(score) : BigInt.zero;

    final combo = prefs.getString('combo_count');
    comboCount = combo != null ? BigInt.parse(combo) : BigInt.zero;

    // Load selected pieces positions
    final positionsJson = prefs.getString('selected_pieces_positions');
    if (positionsJson != null) {
      try {
        final List<dynamic> positionsData = jsonDecode(positionsJson);
        selectedPiecesPositions =
            positionsData
                .map((p) => Point<int>(p['x'] as int, p['y'] as int))
                .toList();
        print('Restored selectedPiecesPositions: $selectedPiecesPositions');
      } catch (e) {
        print('Error loading selected pieces positions: $e');
        selectedPiecesPositions = [];
      }
    }

    // Load targeted cells (optional)
    final targetedJson = prefs.getString('targeted_cells');
    if (targetedJson != null) {
      try {
        final List<dynamic> targetedData = jsonDecode(targetedJson);
        targetedCells =
            targetedData.map((json) => Block.fromJson(json)).toList();
      } catch (e) {
        print('Error loading targeted cells: $e');
        targetedCells = [];
      }
    }

    // Load highscore
    final hs = await _loadHighscore();
    latestHighScore = hs;
    displayedHighscore = hs;
  }

  Future<void> animateBigInt(
    BigInt start,
    BigInt end,
    void Function(BigInt) onUpdate,
  ) async {
    const durationMs = 500;
    const steps = 20;
    final diff = end - start;
    for (var i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: durationMs ~/ steps));
      onUpdate(start + (diff * BigInt.from(i) ~/ BigInt.from(steps)));
    }
  }

  void setPieces() {
    final all = List.of(PieceType.values)..shuffle();
    selectedPieces = all.take(3).toList();
    setState(() {
      _animationController.forward(from: 0.0);
    });
  }

  void initKillingCells(double spawnChance) {
    assert(
      spawnChance >= 0.0 && spawnChance <= 1.0,
      'spawnChance must be between 0.0 and 1.0',
    );
    final rng = Random();
    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < boardWidth; col++) {
        if (rng.nextDouble() < spawnChance) {
          board[row][col] = Block(
            position: Point<int>(row, col),
            isActive: true,
            color: Colors.green,
          );
        }
      }
    }
    update();
  }

  void addScore() async {
    final count = targetedCells.length;
    comboCount =
        count >= comboRequirement ? comboCount + BigInt.one : BigInt.zero;
    final base = BigInt.from(10) * BigInt.from(count);
    final totalScore = base * (comboCount + BigInt.one);

    final oldScore = currentScore;
    final newScore = oldScore + totalScore;
    targetedCells.clear();

    final oldHigh = latestHighScore;
    final newHigh = newScore > oldHigh ? newScore : oldHigh;
    if (newScore > oldHigh) {
      await _saveHighscore(newScore);
      latestHighScore = newHigh;
    }

    final scoreAnim = animateBigInt(
      oldScore,
      newScore,
      (v) => setState(() => currentScore = v),
    );
    final highAnim =
        (newScore > oldHigh)
            ? animateBigInt(
              oldHigh,
              newHigh,
              (v) => setState(() => displayedHighscore = v),
            )
            : Future.value();

    await Future.wait([scoreAnim, highAnim]);
  }

  void spawnNewRows() {
    if (isReviveShowing) return;
    for (var row = boardHeight - 1; row > 0; row--) {
      board[row] = List.from(board[row - 1]);
    }
    board[0] = List.filled(boardWidth, null);
    addScore();
    initKillingCells(spawnRate);
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
      spawnNewRows();
    });
  }

  void showTargetedCells(DragTargetDetails<PieceType> d, int row, int col) {
    setState(() {
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
              targetedCells.add(b);
              break;
            }
          }
        }
      }
    });
  }

  void update() {
    if (loseCondition()) return;
    setState(() {
      for (var r = 0; r < boardHeight; r++) {
        for (var c = 0; c < boardWidth; c++) {
          final b = board[r][c];
          if (r >= 6) {
            if (b == null) {
              board[r][c] = Block(
                position: Point<int>(r, c),
                isActive: false,
                hasPiece: false,
                color: Colors.blueGrey,
              );
            } else {
              b.color = Colors.blueGrey;
            }
          } else if (b != null) {
            if (b.hasPiece || b.piece != null) {
              b.color = Colors.blue;
            } else if (b.isActive) {
              b.color =
                  r < 2
                      ? Colors.green
                      : r < 4
                      ? Colors.orange
                      : Colors.red;
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

  void _restartGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('game_board');
    await prefs.remove('selected_pieces');
    await prefs.remove('current_score');
    await prefs.remove('combo_count');
    await prefs.remove('selected_pieces_positions');
    await prefs.remove('targeted_cells');

    setState(() {
      board = List.generate(8, (_) => List.filled(8, null));
      selectedPiecesPositions.clear();
      setPieces();
      initKillingCells(spawnRate);
      currentScore = BigInt.zero;
      comboCount = BigInt.zero;
      displayedHighscore = latestHighScore;
      isReviveShowing = false;
    });
  }

  void _showLoseDialogSafe() {
    if (!isReviveShowing && mounted) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              backgroundColor: Colors.transparent,
              content: CountdownLoading(
                onRestart: _restartGame,
                isReviveShowing: isReviveShowing,
              ),
            ),
      );
    }
  }

  Widget _buildScore() => Text(
    NumberFormat("#,###").format(currentScore.toInt()),
    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
  );

  Widget _buildCombo() {
    return Text("Combo: $comboCount", style: const TextStyle(fontSize: 20));
  }

  Widget _buildHighscore() => Text(
    "Highscore: ${NumberFormat('#,###').format(displayedHighscore.toInt())}",
    style: const TextStyle(fontSize: 20),
  );

  Widget _buildScoreAndCombo() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [_buildHighscore(), const SizedBox(width: 120), _buildCombo()],
  );

  Widget _buildSelectedPieces(bool isLandscape, double pad) {
    const iconSize = 75.0;
    return Container(
      width: 250,
      height: iconSize + 28,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 57, 159, 255),
        borderRadius: BorderRadius.circular(30),
      ),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder:
            (_, __) => Opacity(
              opacity: _fadeAnimation.value,
              child:
                  selectedPieces.isEmpty && selectedPiecesPositions.isNotEmpty
                      ? GestureDetector(
                        onTap: setPiecesAndRemoveBlocks,
                        child: Container(
                          width: 250,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 57, 159, 255),
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
                              return Flexible(
                                child: Draggable<PieceType>(
                                  data: p,
                                  feedback: Image.asset(
                                    'assets/images/white_${p.name}.png',
                                    width: imageWidth + 1,
                                    height: imageHeight + 10,
                                  ),

                                  feedbackOffset: Offset(
                                    -imageWidth / 3,
                                    -imageHeight / 3,
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.2,
                                    child: Image.asset(
                                      'assets/images/white_${p.name}.png',
                                      width: iconSize,
                                      height: iconSize,
                                    ),
                                  ),
                                  onDragEnd:
                                      (d) =>
                                          d.wasAccepted
                                              ? setState(() {
                                                selectedPieces.remove(p);
                                              })
                                              : null,
                                  child: Image.asset(
                                    'assets/images/white_${p.name}.png',
                                    width: iconSize,
                                    height: iconSize,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
            ),
      ),
    );
  }

  Widget _buildPlayArea(bool isTablet, bool isLandscape, double pad) {
    return Padding(
      padding:
          isLandscape
              ? EdgeInsets.symmetric(horizontal: pad)
              : isTablet
              ? const EdgeInsets.symmetric(horizontal: 100, vertical: 20)
              : const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
                  );
                  showTargetedCells(d, r, c);
                  selectedPiecesPositions.add(Point<int>(r, c));
                  selectedPieces.remove(d.data);
                });
              }
            },
            builder:
                (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color:
                        b == null
                            ? (r >= 6 ? Colors.blueGrey : Colors.grey)
                            : (b.piece != null ? Colors.blue : b.color),
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
                          : null,
                ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gen = context.watch<GeneralProvider>();
    final w = gen.getScreenWidth(context);
    final pad = w * 0.3125;
    final isTablet = gen.isTablet(context),
        isLandscape = gen.getLandscapeMode(context);

    final generalProvider = context.watch<GeneralProvider>();
    double bannerAdHeight = generalProvider.getBannerAdHeight();
    double screenHeight =
        generalProvider.getScreenHeight(context) - bannerAdHeight;
    double scaleFactorHeight = 13.3;

    if (loseCondition() && !isReviveShowing) {
      Future.delayed(const Duration(milliseconds: 100), _showLoseDialogSafe);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await _saveGameState();
            Navigator.of(context).pop();
          },
        ),

        centerTitle: true,
        title: const Text("CheckGrid", style: TextStyle(fontSize: 34)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu), // Ikon för menyn
            onSelected: (String value) {
              // Hantera valet från menyn
              switch (value) {
                case 'new_game':
                  _restartGame();
                  break;
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                  break;
                case 'difficulty':
                  _showDifficultyDialog(context);
                  break;
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'new_game',
                    child: Text('Restart game'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: Text('Settings'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'difficulty',
                    child: Text('Difficulty'),
                  ),
                ],
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: screenHeight / scaleFactorHeight * 0.2),
            _buildScore(),
            SizedBox(height: screenHeight / scaleFactorHeight * 0.2),
            _buildPlayArea(isTablet, isLandscape, pad),
            _buildScoreAndCombo(),
            SizedBox(height: screenHeight / scaleFactorHeight * 0.5),
            _buildSelectedPieces(isLandscape, pad),
          ],
        ),
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }

  // Funktion för att visa AlertDialog för svårighetsval
  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Choose Difficulty')],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Chill'),
                onTap: () {
                  _setDifficulty(Difficulty.chill);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Normal'),
                onTap: () {
                  _setDifficulty(Difficulty.normal);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Max'),
                onTap: () {
                  _setDifficulty(Difficulty.max);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Funktion för att uppdatera svårigheten
  void _setDifficulty(Difficulty difficulty) {
    setState(() {
      _difficulty = difficulty;
    });
  }
}
