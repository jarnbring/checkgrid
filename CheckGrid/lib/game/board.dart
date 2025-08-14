import 'dart:async';
import 'dart:math';
import 'package:checkgrid/game/dialogs/revive_dialog.dart';
import 'package:checkgrid/game/utilities/cell.dart';
import 'package:checkgrid/game/utilities/piecetype.dart';
import 'package:checkgrid/game/utilities/difficulty.dart';
import 'package:checkgrid/game/utilities/score.dart';
import 'package:checkgrid/providers/board_storage.dart';
import 'package:checkgrid/providers/general_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Board extends ChangeNotifier {
  // Board vars
  final List<List<Cell>> board;
  final List<PlacedPiece> placedPieces = [];

  // Positions and selected pieces
  List<PieceType> selectedPieces = [];
  final Map<Point<int>, List<Cell>> targetedCellsMap = {};
  final List<Point<int>> selectedPiecesPositions = [];

  // Game-logic vars
  Difficulty _difficulty;
  bool isGameOver = false;
  bool isReviveShowing = false;
  int watchedAds = 0;
  bool isInputBlocked = false;

  // Score vars
  BigInt currentScore = BigInt.zero;
  BigInt highScore = BigInt.zero;
  bool isAnimatingHighScore = false;
  BigInt lastScore = BigInt.zero;
  bool isHighScore = false;

  int currentCombo = 0;
  final int comboRequirement = 6;

  // Animation vars
  bool _isClearingBoard = false;
  final Set<String> _fadingCells = <String>{};
  bool _isAnimatingNewPieces = false;

  // Helpers
  final Random rng = Random();

  // Getters
  Difficulty get difficulty => _difficulty;
  bool get isClearingBoard => _isClearingBoard;
  bool get isAnimatingNewPieces => _isAnimatingNewPieces;

  // Setters
  set difficulty(Difficulty value) {
    if (_difficulty != value) {
      _difficulty = value;
      notifyListeners();
    }
  }

  // Constructor
  Board({Difficulty initialDifficulty = Difficulty.medium})
    : _difficulty = initialDifficulty,
      board = List.generate(
        GeneralProvider.boardHeight,
        (row) => List.generate(
          GeneralProvider.boardWidth,
          (col) => Cell(position: Point(row, col)),
        ),
      );

  // OPTIMERING 1: Spara endast celler som har data (inte tomma celler)
  Map<String, dynamic> _getBoardDataOptimized() {
    final Map<String, dynamic> activeCells = {};

    for (var row = 0; row < GeneralProvider.boardHeight; row++) {
      for (var col = 0; col < GeneralProvider.boardWidth; col++) {
        final cell = board[row][col];

        // Spara endast celler som har någon data
        if (cell.hasPiece ||
            cell.isActive ||
            cell.isTargeted ||
            cell.piece != null) {
          activeCells['$row,$col'] = {
            'hasPiece': cell.hasPiece,
            'isActive': cell.isActive,
            'isTargeted': cell.isTargeted,
            'piece': cell.piece?.name,
          };
        }
      }
    }

    return activeCells;
  }

  // OPTIMERING 2: Ladda optimerad board-data
  void _loadBoardDataOptimized(Map<String, dynamic> activeCells) {
    // Nollställ hela brädet först
    for (var row = 0; row < GeneralProvider.boardHeight; row++) {
      for (var col = 0; col < GeneralProvider.boardWidth; col++) {
        final cell = board[row][col];
        cell.hasPiece = false;
        cell.isActive = false;
        cell.isTargeted = false;
        cell.piece = null;
      }
    }

    // Ladda endast aktiva celler
    activeCells.forEach((key, data) {
      final coords = key.split(',');
      final row = int.parse(coords[0]);
      final col = int.parse(coords[1]);

      final cell = getCell(row, col);
      if (cell != null) {
        cell.hasPiece = data['hasPiece'] ?? false;
        cell.isActive = data['isActive'] ?? false;
        cell.isTargeted = data['isTargeted'] ?? false;
        final pieceName = data['piece'];
        cell.piece =
            pieceName != null
                ? PieceType.values.firstWhere((e) => e.name == pieceName)
                : null;
      }
    });
  }

  // OPTIMERING 3: Förbättrad targeted cells map sparning
  Map<String, dynamic> _getTargetedCellsMapOptimized() {
    if (targetedCellsMap.isEmpty) return {};

    final Map<String, List<String>> optimizedMap = {};
    targetedCellsMap.forEach((point, cells) {
      final key = '${point.x},${point.y}';
      optimizedMap[key] = cells.map((cell) => '${cell.x},${cell.y}').toList();
    });

    return optimizedMap;
  }

  void _loadTargetedCellsMapOptimized(Map<String, dynamic> data) {
    targetedCellsMap.clear();

    data.forEach((key, cellKeys) {
      final coords = key.split(',');
      final point = Point<int>(int.parse(coords[0]), int.parse(coords[1]));

      final cells = <Cell>[];
      for (final cellKey in cellKeys) {
        final cellCoords = cellKey.split(',');
        final cell = getCell(
          int.parse(cellCoords[0]),
          int.parse(cellCoords[1]),
        );
        if (cell != null) cells.add(cell);
      }
      targetedCellsMap[point] = cells;
    });
  }

  String getCellId(int row, int col) {
    return '$row-$col';
  }

  bool isCellFading(int row, int col) {
    return _fadingCells.contains(getCellId(row, col));
  }

  Future<void> addScore() async {
    final BigInt oldScore = currentScore;
    final allTargetedCells =
        targetedCellsMap.values.expand((cells) => cells).toSet().toList();
    // Handle combo
    final removedCells = allTargetedCells.length;
    currentCombo = removedCells >= comboRequirement ? currentCombo + 1 : 1;

    // Långsammare poängformel
    final baseScore = 1; // Minskat från 2 till 1
    final comboMultiplier = pow(
      1.08,
      currentCombo,
    ); // Minskat från 1.15 till 1.08
    final cellBonus =
        removedCells * log(removedCells + 1) * 0.5; // Halverad bonus
    final scoreToAdd =
        (baseScore * removedCells * comboMultiplier + cellBonus).floor();

    final BigInt finalScore = currentScore + BigInt.from(scoreToAdd);
    // Kontrollera om det blir ett nytt highscore ELLER om vi redan har highscore
    final bool willBeNewHighScore = finalScore > highScore;
    final bool wasAlreadyHighScore =
        currentScore == highScore && currentScore > BigInt.zero;
    if (willBeNewHighScore) {
      highScore = finalScore;
    }
    // Om vi redan hade highscore eller får nytt highscore, använd highscore-animering
    if ((wasAlreadyHighScore || willBeNewHighScore) &&
        finalScore > BigInt.zero) {
      // Markera att vi animerar highscore
      isAnimatingHighScore = true;
      isHighScore = true;
      notifyListeners();
      // Använd kombinerad animering med highscore-parameter
      await GameAnimations.animateScore(oldScore, finalScore, (
        v, [
        isHighScore,
      ]) {
        currentScore = v;
        notifyListeners();
      }, isHighScore: true);
      // Animering klar
      isAnimatingHighScore = false;
      notifyListeners();
    } else {
      // För vanlig score: normal animering utan highscore-parameter
      await GameAnimations.animateScore(oldScore, finalScore, (
        v, [
        isHighScore,
      ]) {
        currentScore = v;
        notifyListeners();
      });
    }
    //currentScore = BigInt.from(2223372036854775803);
    notifyListeners();
  }

  // Update every cells color
  void updateColors() {
    final height = GeneralProvider.boardHeight;
    final width = GeneralProvider.boardWidth;
    int zoneCount = 3;
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        final cell = board[row][col];
        final activeCondition =
            cell.hasPiece || cell.isActive || cell.piece != null;

        // Grundfärg - mjuk gradient base
        cell.color = Color.fromARGB(255, 59, 64, 83); // Mörk blågrå

        // Nollställ gradient för alla celler först!
        cell.gradient = null;

        // Vilken zon är vi i? (0 = topp, 3 = botten)
        int zone = ((row / height) * zoneCount).floor();
        if (zone >= zoneCount) zone = zoneCount - 1;

        if (row == height - 1) {
          cell.color = Color.fromARGB(
            255,
            64,
            83,
            117,
          ); // Djupare grå med lila ton
        }

        // Sätt färg efter zon och status - riktiga gradienter
        if ((zone == 2) && activeCondition) {
          // Used for glowing animation later
          cell.gradient = LinearGradient(
            colors: [Color(0xFFFF6B6B), Color.fromARGB(255, 255, 50, 50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        } else if (zone == 1 && activeCondition) {
          cell.gradient = LinearGradient(
            colors: [
              Color.fromARGB(255, 246, 216, 99),
              Color.fromARGB(255, 251, 191, 51),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        } else if (zone == 0 && activeCondition) {
          cell.gradient = LinearGradient(
            colors: [Color(0xFF4FD1C7), Color(0xFF6BCF7F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        }

        // Prioritera cyan/turkos för pjäser
        if (cell.hasPiece || cell.piece != null) {
          cell.color = Colors.blue;
        }
      }
    }
    notifyListeners();
  }

  Cell? getCell(int row, int col) {
    if (row < 0 ||
        row >= GeneralProvider.boardHeight ||
        col < 0 ||
        col >= GeneralProvider.boardWidth) {
      return null;
    }
    return board[row][col];
  }

  // UPPDATERAD placePiece MED SAVE-REASONING
  void placePiece(PieceType piece, int row, int col, {BuildContext? context}) {
    // Kontrollera om vi redan har 3 placerade pjäser
    if (selectedPiecesPositions.length >= 3) {
      return; // Tillåt inte fler än 3 pjäser
    }

    final block = getCell(row, col);
    if (block != null && !block.hasPiece && !block.isActive) {
      block.piece = piece;
      block.hasPiece = true;
      selectedPieces.remove(piece);
      selectedPiecesPositions.add(Point(row, col));

      notifyListeners();

      // Spara med reasoning - VIKTIGT: använd throttled för att undvika race conditions
      if (context != null) {
        saveBoardThrottled(context, reason: "piece_placed");
      }
    }
  }

  void update() {
    notifyListeners();
  }

  void markTargetedCells(PieceType piece, int row, int col) {
    // Mark targeted cells and save in targetedCellsMap
    final targetedCells = getTargetedCells(piece, row, col);
    for (final cell in targetedCells) {
      cell.isTargeted = true;
    }
    targetedCellsMap[Point(row, col)] = targetedCells;

    notifyListeners();
  }

  Future<void> restartGame(BuildContext context, bool shouldAnimate) async {
    resetScore();
    if (shouldAnimate) {
      await animatedClearBoard();
    } else {
      clearBoard();
    }

    placedPieces.clear();
    selectedPieces.clear();
    targetedCellsMap.clear();
    selectedPiecesPositions.clear();
    isGameOver = false;
    isReviveShowing = false;
    isHighScore = false;
    watchedAds = 0;
    clearPiecesOnBoard();
    spawnInitialActiveCells();
    await setNewSelectedPieces(context: context);
    if (!context.mounted) return;
    // Spara ny spelstatus EFTER allt är klart
    await saveBoard(context);
    
    notifyListeners();
  }

  void resetScore() async {
    lastScore = currentScore;
    // Kolla om nuvarande score är ett highscore
    final bool isCurrentlyHighScore =
        currentScore == highScore && currentScore > BigInt.zero;

    if (isCurrentlyHighScore) {
      // Sätt flaggan för att behålla guldiga effekter under animationen
      isAnimatingHighScore = true;
      notifyListeners();
    }

    await GameAnimations.decreaseScoreToZero(
      currentScore,
      (v, [isHighScore]) {
        currentScore = v;
        notifyListeners();
      },
      isHighScore: isCurrentlyHighScore, // Bara om det faktiskt är highscore
    );

    // Stäng av animationsflaggan efter animationen är klar
    if (isCurrentlyHighScore) {
      isAnimatingHighScore = false;
      notifyListeners();
    }

    currentCombo = 0;
    currentScore = BigInt.zero;
  }

  /// Clears all cells on the board (removes pieces, active and targeted states).
  /// Does not notify listeners directly; used as a helper in other methods.
  Future<void> animatedClearBoard() async {
    isInputBlocked = true;
    _isClearingBoard = true;
    _fadingCells.clear();
    notifyListeners();

    // Gå igenom raderna nedifrån och uppåt
    for (var row = GeneralProvider.boardHeight - 1; row >= 0; row--) {
      // Samla alla celler i denna rad som behöver clearas
      List<int> cellsToClear = [];
      for (var col = 0; col < GeneralProvider.boardWidth; col++) {
        final block = board[row][col];
        if (block.piece != null ||
            block.hasPiece ||
            block.isActive ||
            block.isTargeted) {
          cellsToClear.add(col);
        }
      }

      // Om det finns celler att cleara i denna rad
      if (cellsToClear.isNotEmpty) {
        // Starta fade-animation för alla celler i raden samtidigt
        for (var col in cellsToClear) {
          _fadingCells.add(getCellId(row, col));
        }
        notifyListeners();

        // Vänta på fade-animationen
        await Future.delayed(const Duration(milliseconds: 300));

        // Cleara cellerna efter fade
        for (var col in cellsToClear) {
          final block = board[row][col];
          block.piece = null;
          block.hasPiece = false;
          block.isActive = false;
          block.isTargeted = false;
          _fadingCells.remove(getCellId(row, col));
        }

        isInputBlocked = false;

        // VIKTIGT: Uppdatera färger efter varje rad
        updateColors();
        notifyListeners();

        // Kort paus innan nästa rad
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    _isClearingBoard = false;
    _fadingCells.clear();

    // Slutlig färguppdatering
    updateColors();
    notifyListeners();
  }

  void clearBoard() {
    for (var row = 0; row < GeneralProvider.boardHeight; row++) {
      for (var col = 0; col < GeneralProvider.boardWidth; col++) {
        final block = board[row][col];
        block.piece = null;
        block.hasPiece = false;
        block.isActive = false;
        block.isTargeted = false;
      }
    }

    updateColors();
    notifyListeners();
  }

  void clearPiecesOnBoard() {
    for (var row = 0; row < GeneralProvider.boardHeight; row++) {
      for (var col = 0; col < GeneralProvider.boardWidth; col++) {
        final cell = board[row][col];
        if (cell.hasPiece) {
          cell.piece = null;
          cell.hasPiece = false;
          cell.isActive = false;
          cell.isTargeted = false;
        }
      }
    }
    placedPieces.clear();
  }

  Future<void> spawnActiveCells() async {
    final height = GeneralProvider.boardHeight;
    final width = GeneralProvider.boardWidth;
    final rowsToSpawn = _difficulty.rowsToSpawn;
    final int lastRow = height - 1;

    // Checks if we will have an active cell that will end up
    // outside of the boardheight by calculating how many rows
    // will spawn and check the bottom of those rows. If an active cell
    // is there, we know that it will end up outside of the playarea => Gameover
    for (var row = height - rowsToSpawn; row < height; row++) {
      for (var col = 0; col < width; col++) {
        if (board[row][col].isActive) {
          isGameOver = true;
        }
      }
    }

    // 1. Flytta ner rader (bara om spelet inte är över)
    for (var row = height - 1; row >= rowsToSpawn; row--) {
      for (var col = 0; col < width; col++) {
        board[row][col] = board[row - rowsToSpawn][col];
        board[row][col].x = row;
        board[row][col].y = col;
      }
    }

    // Create new rows on the top
    for (var row = 0; row < rowsToSpawn; row++) {
      for (var col = 0; col < width; col++) {
        board[row][col] = Cell(position: Point(row, col));
        if (rng.nextDouble() < _difficulty.spawnRate) {
          board[row][col].isActive = true;
        }
      }
    }

    // Check if the game is over by checking the last row
    for (int col = 0; col < GeneralProvider.boardWidth; col++) {
      final Cell cell = board[lastRow][col];
      if (cell.isActive) {
        isGameOver = true;
        return;
      }
    }

    notifyListeners();
  }

  // UPPDATERAD setNewSelectedPieces MED CONTEXT-PARAMETER
  Future<void> setNewSelectedPieces({BuildContext? context}) async {
    // Sätt animationsflaggan
    _isAnimatingNewPieces = true;
    notifyListeners();

    final shuffled = List.of(PieceType.values)..shuffle(rng);
    selectedPieces = shuffled.take(3).toList();
    notifyListeners();

    // Vänta 500ms för animationen
    await Future.delayed(const Duration(milliseconds: 500));

    // Stäng av animationsflaggan
    _isAnimatingNewPieces = false;
    notifyListeners();
  }

  // Anropa denna när spelet startar eller när du vill ha nya pjäser
  void prepareNewBoard() {
    clearBoard();
    placedPieces.clear();
    spawnInitialActiveCells();
    setNewSelectedPieces();
    notifyListeners();
  }

  void spawnInitialActiveCells() {
    // Kan lägga till en koll ifall spawnRate är valid (känns onödigt men kolla!)

    for (var row = 0; row < _difficulty.initialRows; row++) {
      // Kollar hur många rows som ska spawnas beroende på difficulty
      for (var col = 0; col < GeneralProvider.boardWidth; col++) {
        if (rng.nextDouble() < _difficulty.spawnRate) {
          // Kollar hur hög chans varje cell ska ha vara aktiv
          final cell = board[row][col];
          cell.isActive = true;
          cell.hasPiece = false;
          cell.piece = null;
        }
      }
    }

    updateColors();
  }

  /// Returnerar en lista med alla block som ska tas bort när en pjäs placeras på [row], [col]
  List<Cell> getTargetedCells(PieceType piece, int row, int col) {
    List<Cell> targeted = [];
    final movement = piece.movementPattern;
    for (var dir in movement.directions) {
      for (var off in dir.offsets) {
        var newRow = row, newCol = col;
        final steps = movement.canMoveMultipleSquares ? 1000 : 1;
        for (var i = 0; i < steps; i++) {
          newRow += off.dy.toInt();
          newCol += off.dx.toInt();
          if (newRow < 0 ||
              newRow >= GeneralProvider.boardHeight ||
              newCol < 0 ||
              newCol >= GeneralProvider.boardWidth) {
            break;
          }
          final block = board[newRow][newCol];
          if (block.isActive) {
            targeted.add(block);
            break; // Endast första aktiva blocket i riktningen
          }
        }
      }
    }
    return targeted;
  }

  /// Markerar targeted och preview cells för UI-preview när man drar en pjäs
  void previewTargetedCells(PieceType piece, int row, int col) {
    // Nollställ endast isPreview
    for (var row = 0; row < GeneralProvider.boardHeight; row++) {
      for (var col = 0; col < GeneralProvider.boardWidth; col++) {
        board[row][col].isPreview = false;
      }
    }

    // Kontrollera om cellen är giltig för placering
    final block = getCell(row, col);
    if (block == null || block.hasPiece || block.isActive) {
      notifyListeners();
      return;
    }

    // Visa preview på targeted blocks för denna pjäs och position
    final targetedCells = getTargetedCells(piece, row, col);
    for (final cell in targetedCells) {
      cell.isPreview = true;
    }
    notifyListeners();
  }

  /// Nollställer preview-markeringar
  void clearPreview() {
    for (var row = 0; row < GeneralProvider.boardHeight; row++) {
      for (var col = 0; col < GeneralProvider.boardWidth; col++) {
        board[row][col].isPreview = false;
      }
    }
    notifyListeners();
  }

  void removePlacedPieces() {
    // Ta bort placerade pjäser
    for (final pos in selectedPiecesPositions) {
      final cell = getCell(pos.x, pos.y);
      if (cell != null) {
        cell.piece = null;
        cell.hasPiece = false;
        cell.isActive = false;
        cell.isTargeted = false;
      }
    }
    selectedPiecesPositions.clear();
    notifyListeners();
  }

  void removeTargetedCells() {
    // Ta bort targeted cells (de som är markerade med kryss)
    for (final cells in targetedCellsMap.values) {
      for (final cell in cells) {
        cell.piece = null;
        cell.hasPiece = false;
        cell.isActive = false;
        cell.isTargeted = false;
      }
    }

    targetedCellsMap.clear();
    notifyListeners();
  }

  void createNewBoard() {
    clearBoard();
    placedPieces.clear();
    selectedPieces.clear();
    targetedCellsMap.clear();
    selectedPiecesPositions.clear();
    isGameOver = false;
    isReviveShowing = false;
    watchedAds = 0;
    resetScore();
    spawnInitialActiveCells();
    setNewSelectedPieces();

    notifyListeners();
  }

  Future<void> clearAllBoardData(BuildContext context) async {
    await GameStorage.clearCurrentGame();
  }

  Future<void> createNewBoardWithCleanup(BuildContext context) async {
    // Rensa all gammal board-data först
    await clearAllBoardData(context);

    // Skapa ny board
    clearBoard();
    placedPieces.clear();
    selectedPieces.clear();
    targetedCellsMap.clear();
    selectedPiecesPositions.clear();
    isGameOver = false;
    isReviveShowing = false;
    watchedAds = 0;
    resetScore();
    spawnInitialActiveCells();

    // Vänta på att nya pjäser är satta
    if (!context.mounted) return;
    await setNewSelectedPieces(context: context);

    // Spara den nya tomma boarden
    if (!context.mounted) return;
    await saveBoard(context);

    notifyListeners();
  }

  // Ersätt updateAmountOfRounds:
  void updateAmountOfRounds(BuildContext context) async {
    await GameStorage.incrementRounds();
  }

  // Ersätt updatePlacedPiecesStatistic:
  void updatePlacedPiecesStatistic(BuildContext context) async {
    await GameStorage.incrementPlacedPieces();
  }

  void updateHighscore(BuildContext context) async {
    await GameStorage.saveHighScore(highScore);
  }

  // OPTIMERING 4: Förbättrat saving system
  Timer? _saveDebounceTimer;
  bool _isSaving = false;

  // FÖRBÄTTRAD THROTTLED SAVE MED DEBUGGING
  void saveBoardThrottled(
    BuildContext context, {
    Duration debounce = const Duration(milliseconds: 1500), // Kortare debounce
    String? reason, // För debugging
  }) {
    // Avbryt tidigare timer
    _saveDebounceTimer?.cancel();

    // Sätt ny timer
    _saveDebounceTimer = Timer(debounce, () async {
      if (!_isSaving && context.mounted) {
        await saveBoard(context);
      }
    });
  }

  // FÖRBÄTTRAD SAVE MED DEBUGGING OCH BÄTTRE ERROR HANDLING
  Future<void> saveBoard(BuildContext context) async {
    try {
      _isSaving = true;

      await GameStorage.saveCurrentGame(
        boardData: _getBoardDataOptimized(),
        targetedCellsMap: _getTargetedCellsMapOptimized(),
        selectedPieces: selectedPieces.map((e) => e.name).toList(),
        selectedPiecesPositions: selectedPiecesPositions,
        difficulty: _difficulty.name,
        watchedAds: watchedAds,
        isGameOver: isGameOver,
        isReviveShowing: isReviveShowing,
        currentScore: currentScore.toString(),
        currentCombo: currentCombo,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Save board error: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _isSaving = false;
    }
  }

  // FÖRBÄTTRAD LOAD MED BÄTTRE DEBUGGING
  Future<void> loadBoard(BuildContext context) async {
    try {
      final gameData = await GameStorage.loadCurrentGame();

      if (gameData == null && context.mounted) {
        restartGame(context, false);
        return;
      }

      // Ladda highscore från SharedPreferences
      highScore = await GameStorage.getHighScore();

      // Ladda speldata från JSON
      isGameOver = gameData!['isGameOver'] ?? false;

      if (isGameOver) {
        if (context.mounted) {
          context.go('/gameover', extra: this);
        }
        return;
      }

      // Ladda selected pieces
      final savedSelectedPieces = gameData['selectedPieces'] as List?;
      if (savedSelectedPieces != null) {
        selectedPieces =
            savedSelectedPieces
                .map((e) => PieceType.values.firstWhere((pt) => pt.name == e))
                .toList();
      }

      // Ladda score och combo
      final savedScore = gameData['currentScore'];
      if (savedScore != null) {
        currentScore = BigInt.parse(savedScore);
        lastScore = currentScore;
        notifyListeners();
      }
      currentCombo = gameData['currentCombo'] ?? 0;

      // Ladda board data
      final boardData = gameData['board'];
      if (boardData != null) {
        _loadBoardDataOptimized(Map<String, dynamic>.from(boardData));
      }

      // Ladda selected pieces positions
      final savedPositions = gameData['selectedPiecesPositions'] as List?;
      selectedPiecesPositions.clear();
      if (savedPositions != null) {
        for (final pos in savedPositions) {
          selectedPiecesPositions.add(Point<int>(pos['x'], pos['y']));
        }
      }

      // Ladda targeted cells map
      final targetedData = gameData['targetedCellsMap'];
      if (targetedData != null) {
        _loadTargetedCellsMapOptimized(Map<String, dynamic>.from(targetedData));
      }

      // Ladda difficulty
      final savedDifficulty = gameData['difficulty'];
      if (savedDifficulty != null) {
        _difficulty = Difficulty.values.firstWhere(
          (d) => d.name == savedDifficulty,
          orElse: () => Difficulty.medium,
        );
      }

      // Ladda övrig data
      watchedAds = gameData['watchedAds'] ?? 0;
      isReviveShowing = gameData['isReviveShowing'] ?? false;

      updateColors();
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('❌ Load board error: $e');
      debugPrint('Stack trace: $stackTrace');
      await GameStorage.clearCurrentGame();
    }
  }

  // Debug: Sätt game over och notifiera
  void debugSetRevive(BuildContext context) {
    showReviveDialog(context, this);
    notifyListeners();
  }

  void debugSetGameOver() {
    watchedAds = 4;
    isGameOver = true;
  }

  // OPTIMERING 9: Destroy metod för att rensa allt när objektet förstörs
  @override
  void dispose() {
    _saveDebounceTimer?.cancel();
    super.dispose();
  }
}
