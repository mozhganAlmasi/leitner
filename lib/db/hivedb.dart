import 'package:hive/hive.dart';

class LeitnerStorage {
  static const List<int> intervals = [1, 2, 4, 8, 16];
  static final LeitnerStorage _instance = LeitnerStorage._internal();
  factory LeitnerStorage() => _instance;

  LeitnerStorage._internal();

  static const String _boxName = 'leitnerBox';
  Box? _box;

  /// مقداردهی اولیه Hive فقط یک‌بار انجام می‌شود
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
  }

  /// ذخیره اطلاعات مطالعه یک جمله
  Future<void> saveReview(int sentenceId , DateTime lastReviewDate , int intervalDays ) async {
   try{
     await _box?.put(sentenceId, {
       'last_review_date' : lastReviewDate.toIso8601String(),
       'next_interval_days' : intervalDays ,
     });
   }catch(e){
     print(e.toString());
   }
  }

  Future<List<int>> getAllIdsInHive() async {
    final List<int> reviewIds = [];

    for (var key in _box!.keys) {
      reviewIds.add(key as int); // تبدیل کلیدها به int
    }

    print("تمام id‌ها: $reviewIds");
    return reviewIds; // برگرداندن لیست id‌ها
  }

  Future<void> getAllSentenceInHive() async {
    final allReviews = <int, dynamic>{};

    for (var key in _box!.keys) {
      final review = await _box!.get(key);
      allReviews[key] = review;
    }

    print("تمام داده‌ها: $allReviews");
  }
  /// دریافت لیست جملاتی که زمان مرور آن‌ها رسیده است
  Future<List<Map<String , dynamic>>> getDueReviewsSentence() async {
    try {
      if (_box == null) return [];

      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day); // فقط تاریخ، بدون ساعت

      return _box!.keys
          .where((key) {
        final review = _box!.get(key);
        if (review == null || review['last_review_date'] == null || review['next_interval_days'] == null) {
          return false;
        }

        final lastReviewDate = DateTime.tryParse(review['last_review_date']);
        if (lastReviewDate == null) return false;

        final nextReviewDate = lastReviewDate.add(Duration(days: intervals[review['next_interval_days']]));
        final normalizedNextReview = DateTime(nextReviewDate.year, nextReviewDate.month, nextReviewDate.day);

        return normalizedNextReview.isBefore(normalizedToday) || normalizedNextReview.isAtSameMomentAs(normalizedToday);
      })
          .map((key){
        final data = Map<String, dynamic>.from(_box!.get(key));
        data['id'] = key; // اضافه کردن key به خروجی
        return data;
      })
          .toList();
    } catch (e) {
      print("Error in getDueReviews: $e");
      return [];
    }
  }

  /// حذف اطلاعات مطالعه یک جمله
  Future<void> deleteReview(int sentenceId) async {
    await _box?.delete(sentenceId);
  }

  /// پاک‌سازی کامل داده‌های مطالعه‌شده
  Future<void> clearAllReviews() async {
    await _box?.clear();
  }
}
