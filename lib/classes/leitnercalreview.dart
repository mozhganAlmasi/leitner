class LeitnerSystem {
  // فواصل زمانی لایتنر (برحسب روز)
  static const List<int> intervals = [1, 2, 4, 8, 16];

  /// این تابع تاریخ مرور بعدی را بر اساس الگوریتم لایتنر تعیین می‌کند.
  /// [lastReviewDate]: تاریخ آخرین مرور
  /// [isCorrect]: نتیجه پاسخ کاربر (درست یا غلط)
  /// [currentStage]: مرحله فعلی جمله در جعبه لایتنر
  /// خروجی: تاریخ مرور بعدی و مرحله جدید
  static Map<String, dynamic> nextReviewDate(
      DateTime lastReviewDate, bool isCorrect, int currentStage) {
    DateTime today = DateTime.now();
    int daysPassed = today.difference(lastReviewDate).inDays;

    int nextStage;
    if (isCorrect) {
      if (daysPassed > intervals[currentStage]) {
        // اگر از زمان مرور گذشته باشد، یک مرحله به عقب برگردد
        nextStage = (currentStage - 1).clamp(0, intervals.length - 1);
      } else {
        nextStage = (currentStage + 1).clamp(0, intervals.length - 1);
      }
    } else {
      nextStage = 0; // بازگشت به مرحله اول در صورت پاسخ نادرست
    }

    int nextInterval = intervals[nextStage];

    return {
      "nextDate": today.add(Duration(days: nextInterval)),
      "nextStage": nextStage
    };
  }
}
