enum Difficulty { easy, medium, hard }

extension DifficultyExtension on Difficulty {
  double get spawnRate {
    switch (this) {
      case Difficulty.easy:
        return 0.5;
      case Difficulty.medium:
        return 0.75;
      case Difficulty.hard:
        return 1.0;
    }
  }
}
