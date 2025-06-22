import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Score extends StatelessWidget {
  final BigInt score;

  const Score({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Text(
      NumberFormat("#,###").format(score.toInt()),
      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
    );
  }
}
