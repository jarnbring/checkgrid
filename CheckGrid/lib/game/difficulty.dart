enum Difficulty { chill, normal, max }

extension DifficultyExtension on Difficulty {
  double get spawnRate {
    switch (this) {
      case Difficulty.chill:
        return 0.5;
      case Difficulty.normal:
        return 0.75;
      case Difficulty.max:
        return 1.0;
    }
  }
}
