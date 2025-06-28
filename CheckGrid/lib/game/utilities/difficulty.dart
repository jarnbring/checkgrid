enum Difficulty { easy, medium, hard }

extension DifficultyExtension on Difficulty {
  double get spawnRate {
    switch (this) {
      case Difficulty.easy:
        return 0.60;
      case Difficulty.medium:
        return 0.70;
      case Difficulty.hard:
        return 0.80;
    }
  }

  // int newRows = 2;
  // Just an example, you can adjust this based on difficulty
  // if (_difficulty == Difficulty.hard) {
  //   newRows = 3;
  // }
  int get initialRows {
    switch (this) {
      case Difficulty.easy:
        return 2;
      case Difficulty.medium:
        return 2;
      case Difficulty.hard:
        return 3;
    }
  }

  int get rowsToSpawn {
    switch (this) {
      case Difficulty.easy:
        return 1;
      case Difficulty.medium:
        return 2;
      case Difficulty.hard:
        return 2;
    }
  }
}
