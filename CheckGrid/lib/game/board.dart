import 'dart:math';
import 'package:checkgrid/animations/game_animations.dart';
import 'package:checkgrid/game/dialogs/game_over/revive_dialog.dart';
import 'package:checkgrid/game/utilities/cell.dart';
import 'package:checkgrid/game/utilities/piecetype.dart';
import 'package:checkgrid/game/utilities/difficulty.dart';
import 'package:checkgrid/providers/board_provider.dart';
import 'package:checkgrid/providers/general_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Handle board logic, ex clearBoard etc.

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

  // Score vars
  BigInt currentScore = BigInt.zero;
  BigInt highScore = BigInt.zero;

  int currentCombo = 0;
  final int comboRequirement = 6;

  // Helpers
  final Random rng = Random();

  // Getters
  Difficulty get difficulty => _difficulty;

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

  void addScore() async {
    final BigInt oldScore = currentScore;

    final allTargetedCells =
        targetedCellsMap.values.expand((cells) => cells).toSet().toList();

    // Handle combo
    final removedCells = allTargetedCells.length;
    currentCombo = removedCells >= comboRequirement ? currentCombo + 1 : 1;

    // Ny poängformel
    final baseScore = 2;
    final comboMultiplier = pow(1.15, currentCombo);
    final cellBonus = removedCells * log(removedCells + 1);
    final scoreToAdd =
        (baseScore * removedCells * comboMultiplier + cellBonus).floor();

    currentScore = currentScore + BigInt.from(scoreToAdd);
    final newHigh = currentScore > highScore ? currentScore : highScore;
    if (currentScore > highScore) {
      highScore = newHigh;
    }

    await GameAnimations.increaseScore(oldScore, currentScore, (v) {
      currentScore = v;
      notifyListeners();
    });

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

        // Grundfärg
        cell.color = Colors.grey;

        // Vilken zon är vi i? (0 = topp, 3 = botten)
        int zone = ((row / height) * zoneCount).floor();
        if (zone >= zoneCount) zone = zoneCount - 1;

        if (row == height - 1) {
          cell.color = Colors.blueGrey;
        }

        // Sätt färg efter zon och status
        if ((zone == 2) && activeCondition) {
          cell.color = Colors.red;
        } else if (zone == 1 && activeCondition) {
          cell.color = Colors.orange;
        } else if (zone == 0 && activeCondition) {
          cell.color = Colors.green;
        }

        // Prioritera blå för pjäser
        if (cell.hasPiece || cell.piece != null) {
          cell.color = Colors.blue;
        }
      }
    }
    notifyListeners();
  }

  // Check if the game is over, change boardSide - x to change when
  // the game is over.
  void checkGameOver() {
    // Kolla sista och näst sista raden
    for (
      int row = GeneralProvider.boardHeight - 1;
      row < GeneralProvider.boardHeight;
      row++
    ) {
      for (int col = 0; col < GeneralProvider.boardWidth; col++) {
        final Cell cell = board[row][col];
        if (cell.isActive) {
          isGameOver = true;
          return; // Avsluta direkt om vi hittar en aktiv cell
        }
      }
    }
    isGameOver = false;
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

  void placePiece(PieceType piece, int row, int col) {
    final block = getCell(row, col);
    if (block != null && !block.hasPiece && !block.isActive) {
      block.piece = piece;
      block.hasPiece = true;
      selectedPieces.remove(piece);
      selectedPiecesPositions.add(Point(row, col));

      notifyListeners();
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

  // Resets the board and all game state to start a new game.
  // Clears all placed pieces, selected pieces, targeted cells, and resets flags.
  // Spawns new initial active cells and selects new pieces for the player.
  // Notifies listeners so the UI can update.
  void restartGame(BuildContext context) {
    clearBoard();
    placedPieces.clear();
    selectedPieces.clear();
    targetedCellsMap.clear();
    selectedPiecesPositions.clear();
    isGameOver = false;
    isReviveShowing = false;
    watchedAds = 0;
    resetScore();
    clearPiecesOnBoard();
    spawnInitialActiveCells();
    setNewSelectedPieces();
    saveBoard(context);

    notifyListeners();
  }

  void resetScore() {
    currentCombo = 0;
    currentScore = BigInt.zero;
  }

  /// Clears all cells on the board (removes pieces, active and targeted states).
  /// Does not notify listeners directly; used as a helper in other methods.
  void clearBoard() {
    for (var row = 0; row < GeneralProvider.boardHeight; row++) {
      for (var col = 0; col < GeneralProvider.boardWidth; col++) {
        final block = board[row][col];
        if (block.piece != null ||
            block.hasPiece ||
            block.isActive ||
            block.isTargeted) {
          block.piece = null;
          block.hasPiece = false;
          block.isActive = false;
          block.isTargeted = false;
        }
      }
    }
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

    // 1. Flytta ner rader
    for (var row = height - 1; row >= rowsToSpawn; row--) {
      for (var col = 0; col < width; col++) {
        board[row][col] = board[row - rowsToSpawn][col];
        // Uppdatera positionen på cellen
        board[row][col].x = row;
        board[row][col].y = col;
      }
    }

    // 2. Skapa nya rader överst
    for (var row = 0; row < rowsToSpawn; row++) {
      for (var col = 0; col < width; col++) {
        board[row][col] = Cell(position: Point(row, col));
        if (rng.nextDouble() < _difficulty.spawnRate) {
          board[row][col].isActive = true;
          // Sätt färg/gradient om du vill
        }
      }
    }

    notifyListeners();
  }

  void setNewSelectedPieces() {
    final shuffled = List.of(PieceType.values)..shuffle(rng);
    selectedPieces = shuffled.take(3).toList();
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
    // Behövs denna????
    // Nollställ endast isPreview
    for (var row = 0; row < GeneralProvider.boardHeight; row++) {
      for (var col = 0; col < GeneralProvider.boardWidth; col++) {
        board[row][col].isPreview = false;
      }
    }

    // WHAT?
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

  // Updates the amountOfRounds statistic
  void updateAmountOfRounds(BuildContext context) async {
    final boardProvider = context.read<BoardProvider>();

    // Amount of games
    int amountOfRounds = boardProvider.getStatisticsBox.get(
      'amountOfRounds',
      defaultValue: 0,
    );
    boardProvider.getStatisticsBox.put('amountOfRounds', amountOfRounds + 1);
  }

  void updatePlacedPiecesStatistic(BuildContext context) async {
    final boardProvider = context.read<BoardProvider>();

    int storedPlacedPieces = boardProvider.getStatisticsBox.get(
      'placedPieces',
      defaultValue: 0,
    );
    storedPlacedPieces = storedPlacedPieces + 1;
    boardProvider.getStatisticsBox.put('placedPieces', storedPlacedPieces);
  }

  void updateHighscore(BuildContext context) async {
    final boardProvider = context.read<BoardProvider>();
    // Highscore
    boardProvider.getStatisticsBox.put('highScore', highScore.toString());
  }

  void saveBoard(BuildContext context) async {
    final boardBox = context.read<BoardProvider>().getBoardBox;

    List<Map<String, dynamic>> cellData =
        board.expand((row) => row).map((cell) {
          return {
            'x': cell.x,
            'y': cell.y,
            'hasPiece': cell.hasPiece,
            'isActive': cell.isActive,
            'isTargeted': cell.isTargeted,
            'piece': cell.piece?.name,
          };
        }).toList();

    List<Map<String, dynamic>> targetedCellsMapData =
        targetedCellsMap.entries.map((entry) {
          return {
            'point': {'x': entry.key.x, 'y': entry.key.y},
            'cells':
                entry.value.map((cell) => {'x': cell.x, 'y': cell.y}).toList(),
          };
        }).toList();

    await boardBox.put('board', cellData);
    await boardBox.put('targetedCellsMap', targetedCellsMapData);
    await boardBox.put('_difficulty', _difficulty.name);
    await boardBox.put(
      'selectedPieces',
      selectedPieces.map((e) => e.name).toList(),
    );
    await boardBox.put('watchedAds', watchedAds);
    await boardBox.put('isGameOver', isGameOver);
    await boardBox.put('isReviveShowing', isReviveShowing);
    await boardBox.put('currentScore', currentScore.toString());
  }

  Future<void> loadBoard(BuildContext context) async {
    try {
      // For debug
      // await Future.delayed(const Duration(seconds: 10));

      final boardBox = context.read<BoardProvider>().getBoardBox;

      // Load selected pieces
      final savedSelectedPieces = boardBox.get(
        'selectedPieces',
        defaultValue: <String>[],
      );
      selectedPieces =
          (savedSelectedPieces as List)
              .map((e) => PieceType.values.firstWhere((pt) => pt.name == e))
              .toList();

      // Load score
      final savedScore = await boardBox.get('currentScore');
      if (savedScore != null) {
        currentScore = BigInt.parse(savedScore);
      }

      // Load board cells
      final cellData = await boardBox.get('board');
      if (cellData != null) {
        for (final data in cellData) {
          final cell = getCell(data['x'], data['y']);
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
        }
      }

      // Load targeted cells map
      final targetedCellsMapData = await boardBox.get('targetedCellsMap');
      targetedCellsMap.clear();
      if (targetedCellsMapData != null) {
        for (final entry in targetedCellsMapData) {
          final pointData = entry['point'];
          final point = Point<int>(pointData['x'], pointData['y']);

          final cells = <Cell>[];
          for (final cellPos in entry['cells']) {
            final cell = getCell(cellPos['x'], cellPos['y']);
            if (cell != null) cells.add(cell);
          }
          targetedCellsMap[point] = cells;
        }
      }

      // Load difficulty
      final savedDifficulty = await boardBox.get('_difficulty');
      _difficulty = Difficulty.values.firstWhere(
        (d) => d.name == savedDifficulty,
        orElse: () => Difficulty.medium,
      );

      // Load other variables
      watchedAds = await boardBox.get('watchedAds');
      isGameOver = await boardBox.get('isGameOver');
      isReviveShowing = await boardBox.get('isReviveShowing');

      updateColors();
      notifyListeners();
    } catch (e, stacktrace) {
      debugPrint('Error loading board: $e');
      debugPrint('$stacktrace');
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
}
