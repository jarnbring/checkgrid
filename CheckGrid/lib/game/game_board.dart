import 'package:checkgrid/game/utilities/cell.dart';
import 'package:checkgrid/pages/tutorial_page.dart';
import 'package:checkgrid/providers/audio_provider.dart';
import 'package:checkgrid/providers/general_provider.dart';
import 'package:checkgrid/providers/settings_provider.dart';
import 'package:checkgrid/providers/skin_provider.dart';
import 'package:flutter/material.dart';
import 'package:checkgrid/game/board.dart';
import 'package:checkgrid/game/utilities/piecetype.dart';
import 'package:provider/provider.dart';

// Handle the board UI, layout etc.

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final board = context.watch<Board>();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color:
            Provider.of<SettingsProvider>(context).themeMode == ThemeMode.dark
                ? const Color.fromARGB(255, 39, 39, 39)
                : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: GeneralProvider.boardWidth,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
          ),
          itemCount: GeneralProvider.boardHeight * GeneralProvider.boardWidth,
          itemBuilder: (context, index) {
            final row = index ~/ GeneralProvider.boardWidth;
            final col = index % GeneralProvider.boardWidth;
            return ChangeNotifierProvider<Cell>.value(
              value: board.board[row][col],
              child: BoardCell(row: row, col: col), // Cell
            );
          },
        ),
      ),
    );
  }
}

class BoardCell extends StatefulWidget {
  final int row, col;

  const BoardCell({super.key, required this.row, required this.col});

  @override
  State<BoardCell> createState() => _BoardCellState();
}

class _BoardCellState extends State<BoardCell> with TickerProviderStateMixin {
  late AnimationController _placementController;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _bounceAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _placementController = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );

    _hoverController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    // Animationer ska bara köras när en pjäs placeras, annars vara på 1.0
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _placementController, curve: Curves.elasticOut),
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _placementController,
        curve: Interval(0.8, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Sätt placement controller till slutposition för befintliga pjäser
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cell = context.read<Cell>();
      if (cell.piece != null && _placementController.value == 0.0) {
        _placementController.value =
            1.0; // Sätt till slutposition utan animation
      }
    });
  }

  @override
  void dispose() {
    _placementController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.read<GeneralProvider>();
    final skinProvider = context.watch<SkinProvider>();
    final board = context.read<Board>();

    return Consumer<Cell>(
      builder: (context, cell, _) {
        // Kontrollera om denna cell håller på att fade:a bort
        final isFading = board.isCellFading(widget.row, widget.col);

        return MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
            _hoverController.forward();
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            _hoverController.reverse();
          },
          child: DragTarget<PieceType>(
            onWillAcceptWithDetails: (details) {
              // What requirements is needed to place a piece
              bool canPlace =
                  !cell.hasPiece &&
                  !cell.isActive &&
                  board.isClearingBoard ==
                      false; // Needed to avoid placing pieces during the clearBoard animation, ex when you revive and the board is clearing. You are not supposed to be able to place pieces during the animation.
              board.previewTargetedCells(details.data, widget.row, widget.col);
              return canPlace;
            },
            onLeave: (_) {
              board.clearPreview();
            },
            onAcceptWithDetails: (details) {
              context.read<AudioProvider>().playPlacePiece();
              board.placePiece(details.data, widget.row, widget.col);
              board.markTargetedCells(details.data, widget.row, widget.col);
              board.clearPreview();
              board.updateColors();

              // RESET och sedan trigger placement animation
              _placementController.reset();
              _placementController.forward();

              // Resten av din kod...
              if (board.selectedPieces.isNotEmpty) {
                context.read<SettingsProvider>().doVibration(1);
              } else if (board.selectedPieces.isEmpty) {
                context.read<SettingsProvider>().doVibration(3);
              }

              final tutorial = context.read<TutorialController>();
              if (tutorial.tutorialStep <= 4 && tutorial.isActive) {
                tutorial.nextStep();
                return;
              }

              board.saveBoard(context);
              board.updatePlacedPiecesStatistic(context);
            },
            builder: (context, candidateData, rejectedData) {
              return AnimatedBuilder(
                animation: Listenable.merge([
                  _placementController,
                  _hoverController,
                ]),
                builder: (context, child) {
                  double hoverScale =
                      1.0 +
                      (_glowAnimation.value * 0.05); // Mindre hover-effekt
                  // Bara animera scale när pjäs placeras, annars alltid 1.0
                  double placementScale =
                      cell.piece != null ? _scaleAnimation.value : 1.0;

                  return AnimatedOpacity(
                    // Lägg till fade-animation här
                    opacity: isFading ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: AnimatedScale(
                      // Optional: lägg till scale-effekt när den fade:ar
                      scale: isFading ? 0.8 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: Transform.scale(
                        scale: placementScale * hoverScale,
                        child: Container(
                          decoration: (cell.getDecoration() as BoxDecoration)
                              .copyWith(
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: _buildBoxShadows(cell),
                              ),
                          child: Stack(
                            children: [
                              if (cell.piece != null)
                                Transform.scale(
                                  scale: _bounceAnimation.value,
                                  child: Image.asset(
                                    'assets/images/pieces/${skinProvider.selectedSkin.name}/${skinProvider.selectedSkin.name}_${cell.piece!.name}.png',
                                    width: generalProvider.iconSize,
                                    height: generalProvider.iconSize,
                                  ),
                                ),

                              if (cell.isPreview || cell.isTargeted)
                                Opacity(
                                  opacity: cell.isTargeted ? 1.0 : 0.5,
                                  child: Image.asset(
                                    'assets/images/cross.png',
                                    width: generalProvider.iconSize,
                                    height: generalProvider.iconSize,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  List<BoxShadow>? _buildBoxShadows(Cell cell) {
    List<BoxShadow> shadows = [];

    // Hover glow effect
    if (_isHovered) {
      shadows.add(
        BoxShadow(
          color: Colors.blue.withOpacity(0.6 * _glowAnimation.value),
          blurRadius: 15 * _glowAnimation.value,
          spreadRadius: 3 * _glowAnimation.value,
        ),
      );
    }

    // Preview glow effect
    if (cell.isPreview) {
      Color glowColor;

      // Definiera dina gradients för jämförelse
      final greenGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(79, 209, 199, 1.0), // 0.3098, 0.8196, 0.7804
          Color.fromRGBO(107, 207, 127, 1.0), // 0.4196, 0.8118, 0.4980
        ],
      );

      final redGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(255, 107, 107, 1.0), // 1.0000, 0.4196, 0.4196
          Color.fromRGBO(255, 50, 50, 1.0), // 1.0000, 0.1961, 0.1961
        ],
      );

      final yellowGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(246, 216, 99, 1.0), // 0.9647, 0.8471, 0.3882
          Color.fromRGBO(251, 191, 51, 1.0), // 0.9843, 0.7490, 0.2000
        ],
      );

      // Jämför gradienter och sätt glow-färg
      if (_gradientsEqual(cell.gradient as LinearGradient?, greenGradient)) {
        glowColor = Color.fromRGBO(79, 209, 199, 1.0); // Grön-cyan
      } else if (_gradientsEqual(
        cell.gradient as LinearGradient?,
        redGradient,
      )) {
        glowColor = Color.fromRGBO(255, 107, 107, 1.0); // Röd
      } else if (_gradientsEqual(
        cell.gradient as LinearGradient?,
        yellowGradient,
      )) {
        glowColor = Color.fromRGBO(246, 216, 99, 1.0); // Gul
      } else {
        glowColor = Colors.blue; // fallback
      }

      shadows.add(
        BoxShadow(
          color: glowColor.withOpacity(0.7),
          blurRadius: 15,
          spreadRadius: 3,
        ),
      );
    }

    return shadows.isEmpty ? null : shadows;
  }

  // Hjälpmetod för att jämföra gradienter
  bool _gradientsEqual(LinearGradient? gradient1, LinearGradient gradient2) {
    if (gradient1 == null) return false;

    // Jämför färgerna (första färgen räcker oftast)
    if (gradient1.colors.isNotEmpty && gradient2.colors.isNotEmpty) {
      return gradient1.colors.first.value == gradient2.colors.first.value;
    }

    return false;
  }
}
