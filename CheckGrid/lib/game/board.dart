import 'dart:math';
import 'package:checkgrid/game/dialogs/game_over/revive_dialog.dart';
import 'package:checkgrid/game/utilities/cell.dart';
import 'package:checkgrid/game/utilities/piecetype.dart';
import 'package:checkgrid/game/utilities/difficulty.dart';
import 'package:checkgrid/game/utilities/score.dart';
import 'package:checkgrid/providers/board_provider.dart';
import 'package:checkgrid/providers/error_service.dart';
import 'package:checkgrid/providers/general_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
  bool isAnimatingHighScore = false;

  int currentCombo = 0;
  final int comboRequirement = 6;

  // Animation vars - DESSA SAKNADES!
  bool _isClearingBoard = false;
  final Set<String> _fadingCells = <String>{};

  // Helpers
  final Random rng = Random();

  // Getters
  Difficulty get difficulty => _difficulty;
  bool get isClearingBoard => _isClearingBoard; // SAKNADES!

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

  // SAKNAD METOD: getCellId
  String getCellId(int row, int col) {
    return '$row-$col';
  }

  // SAKNAD METOD: isCellFading
  bool isCellFading(int row, int col) {
    return _fadingCells.contains(getCellId(row, col));
  }

  // Uppdaterad addScore funktion med kombinerad animation
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
  void restartGame(BuildContext context, bool shouldAnimate) async {
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
    watchedAds = 0;
    clearPiecesOnBoard();
    spawnInitialActiveCells();
    setNewSelectedPieces();
    if (!context.mounted) return;
    saveBoard(context);

    notifyListeners();
  }

  void resetScore() async {
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
      final boardBox = context.read<BoardProvider>().getBoardBox;
      final statisticsBox =
          context.read<BoardProvider>().getStatisticsBox; // Lägg till detta

      // Start by looking if the game is over, if so, the user should be redirected to the gameover page
      isGameOver = await boardBox.get('isGameOver') ?? false;
      if (isGameOver) {
        // ignore: use_build_context_synchronously
        context.go('/gameover', extra: this);
        return;
      }

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

      // Load highscore från statistics box
      final savedHighScore = statisticsBox.get('highScore');
      if (savedHighScore != null) {
        try {
          highScore = BigInt.parse(savedHighScore);
        } catch (e) {
          highScore = BigInt.zero;
        }
      } else {
        highScore = BigInt.zero;
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
      isReviveShowing = await boardBox.get('isReviveShowing');

      updateColors();
      notifyListeners();
    } catch (e, stacktrace) {
      if (!context.mounted) return;
      ErrorService().showError(
        context,
        "Something went wrong while loading the board.",
        useTopPosition: true,
      );
      ErrorService().logError(e, stacktrace);
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
