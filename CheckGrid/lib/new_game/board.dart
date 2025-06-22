import 'dart:math';
import 'package:checkgrid/new_game/utilities/cell.dart';
import 'package:checkgrid/new_game/utilities/piecetype.dart';
import 'package:checkgrid/new_game/utilities/difficulty.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Handle board logic, ex clearBoard etc.

class Board extends ChangeNotifier {
  // Board vars
  static const int boardSide = 8;
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
        boardSide,
        (row) =>
            List.generate(boardSide, (col) => Cell(position: Point(row, col))),
      );


  // Update every cells color
  void updateColors() {
    for (int row = 0; row < boardSide; row++) {
      for (int col = 0; col < boardSide; col++) {
        final cell = board[row][col];
        final activeCondition =
            cell.hasPiece || cell.isActive || cell.piece != null;

        // Drawing priority, high number = high priority

        // 1
        if (!cell.isActive) {
          cell.color = Colors.grey;
        }

        // 2
        if (row >= 6) {
          cell.color = Colors.blueGrey;
        }

        // 3
        if (row >= 4 && activeCondition) {
          cell.color = Colors.red;
        } else if (row >= 2 && activeCondition) {
          cell.color = Colors.orange;
        } else if (row >= 0 && activeCondition) {
          cell.color = Colors.green;
        }

        // 4
        if (cell.hasPiece || cell.piece != null) {
          cell.color = Colors.blue;
        }
      }
    }
    notifyListeners();
  }

  // 
  bool checkGameOver() {
    for (int row = 0; row < boardSide; row++) {
      for (int col = 0; col < boardSide;) {
        final Cell cell = board[row][col];
        // If the cell is not active, we can move to the next cell
        if (!cell.isActive) break;

        // If the cell is on the wrong row, we can move to the next cell
        if (row != (boardSide - 1) || row != (boardSide - 2)) break;

        // We have reached a cell that fires the game over condition
        isGameOver = true;
        
        return true;
      }
    }
    // No cells fires the game over condition
    isGameOver = false;

    return false;
  }

  Cell? getCell(int row, int col) {
    if (row < 0 || row >= boardSide || col < 0 || col >= boardSide) return null;
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

  void markTargetedCells(PieceType piece, int row, int col) {
    // Markera targeted cells och spara i targetedCellsMap
    final targetedCells = getTargetedCells(piece, row, col);
    for (final cell in targetedCells) {
      cell.isTargeted = true;
    }
    targetedCellsMap[Point(row, col)] = targetedCells;

    notifyListeners();
  }

  void restartGame() {
    clearBoard();
    placedPieces.clear();
    notifyListeners();
  }

  void clearBoard() {
    for (var row = 0; row < boardSide; row++) {
      for (var col = 0; col < boardSide; col++) {
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
    for (var row = 0; row < boardSide; row++) {
      for (var col = 0; col < boardSide; col++) {
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
    // 1. Flytta ner rader
    for (var row = boardSide - 1; row > 0; row--) {
      for (var col = 0; col < boardSide; col++) {
        board[row][col] = board[row - 1][col];
      }
    }
    // 2. Skapa ny rad överst
    for (var col = 0; col < boardSide; col++) {
      board[0][col] = Cell(position: Point(0, col));
      if (rng.nextDouble() < _difficulty.spawnRate) {
        board[0][col].isActive = true;
        // Sätt färg/gradient om du vill
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

    for (var row = 0; row < _difficulty.spawnRows; row++) {
      // Kollar hur många rows som ska spawnas beroende på difficulty
      for (var col = 0; col < boardSide; col++) {
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
        var nr = row, nc = col;
        final steps = movement.canMoveMultipleSquares ? Board.boardSide : 1;
        for (var i = 0; i < steps; i++) {
          nr += off.dy.toInt();
          nc += off.dx.toInt();
          if (nr < 0 ||
              nr >= Board.boardSide ||
              nc < 0 ||
              nc >= Board.boardSide) {
            break;
          }
          final block = board[nr][nc];
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
    for (var r = 0; r < boardSide; r++) {
      for (var c = 0; c < boardSide; c++) {
        board[r][c].isPreview = false;
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
    for (var r = 0; r < boardSide; r++) {
      for (var c = 0; c < boardSide; c++) {
        board[r][c].isPreview = false;
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
}
