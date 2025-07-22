class GameAnimations {
  static Future<void> increaseScore(
    BigInt oldScore,
    BigInt newScore,
    void Function(BigInt) onUpdate, {
    int durationMs = 500,
    int steps = 10,
  }) async {
    final diff = newScore - oldScore;
    for (var i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: durationMs ~/ steps));
      onUpdate(oldScore + (diff * BigInt.from(i) ~/ BigInt.from(steps)));
    }
  }
}
