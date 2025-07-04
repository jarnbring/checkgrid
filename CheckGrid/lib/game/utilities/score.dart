import 'package:checkgrid/game/board.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Score extends StatelessWidget {
  const Score({super.key});

  @override
  Widget build(BuildContext context) {
    final board = context.watch<Board>();

    return Text(
      board.currentScore >= BigInt.from(9223372036854775807)
          ? "∞"
          : NumberFormat("#,###").format(board.currentScore.toInt()),
      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }
}
