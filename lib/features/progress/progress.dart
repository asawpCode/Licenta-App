class MeditationProgress {
  final int totalMinutesMeditated;

  MeditationProgress(this.totalMinutesMeditated);

  int getPoints() {
    return totalMinutesMeditated ~/ 5;
  }

  static double calculateProgressPercentage(int points) {
    const int beginnerMax = 20;
    const int knowledgeableMax = 81;
    const int advancedMax = 160;

    double percentage;
    if (points <= beginnerMax) {
      percentage = points / beginnerMax;
    } else if (points <= knowledgeableMax) {
      percentage = (points - beginnerMax) / (knowledgeableMax - beginnerMax);
    } else if (points <= advancedMax) {
      percentage =
          (points - knowledgeableMax) / (advancedMax - knowledgeableMax);
    } else {
      percentage = 1.0;
    }
    return percentage > 1.0 ? 1.0 : percentage;
  }

  String getLevel() {
    int points = getPoints();
    if (points <= 20) {
      return 'Incepător';
    } else if (points <= 81) {
      return 'Cunoscător';
    } else if (points <= 160) {
      return 'Avansat';
    } else {
      return 'PRO';
    }
  }
}
