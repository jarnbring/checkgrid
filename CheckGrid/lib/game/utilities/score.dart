import 'package:checkgrid/components/outlined_text.dart';
import 'package:checkgrid/game/board.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Score extends StatelessWidget {
  const Score({super.key});

  @override
  Widget build(BuildContext context) {
    final board = context.watch<Board>();
    final scoreText =
        board.currentScore >= BigInt.from(9223372036854775807)
            ? "MAX"
            : NumberFormat("#,###").format(board.currentScore.toInt());

    return LayoutBuilder(
      builder: (context, constraints) {
        // Beräkna lämplig fontstorlek baserat på tillgänglig bredd
        double fontSize = _calculateFontSize(scoreText, constraints.maxWidth);

        return OutlinedText(text: scoreText, fontSize: fontSize);
      },
    );
  }

  double _calculateFontSize(String text, double availableWidth) {
    // Uppskatta teckenbredd (ungefär)
    double estimatedCharWidth =
        20; // Ungefärlig bredd per tecken vid fontSize 32
    double estimatedTextWidth = text.length * estimatedCharWidth;

    if (estimatedTextWidth <= availableWidth) {
      return 32; // Behåll ursprunglig storlek
    }

    // Skala ner baserat på förhållandet
    double scale = availableWidth / estimatedTextWidth;
    return (32 * scale).clamp(16, 32); // Minimum 16, maximum 32
  }
}
