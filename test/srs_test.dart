import 'package:flutter_test/flutter_test.dart';
import 'package:swipelingo/services/srs.dart' as srs; // テスト対象のファイルをインポート

void main() {
  group('SRS Logic Tests', () {
    test('updateStrength increases strength on correct answer', () {
      const currentStrength = 2.0;
      const expectedMultiplier = 1.7; // srs.dart のデフォルト値
      final newStrength = srs.updateStrength(currentStrength, true);
      expect(newStrength, closeTo(currentStrength * expectedMultiplier, 0.01));
    });

    test('updateStrength decreases strength on incorrect answer', () {
      const currentStrength = 2.0;
      const expectedMultiplier = 0.6; // srs.dart のデフォルト値
      final newStrength = srs.updateStrength(currentStrength, false);
      expect(newStrength, closeTo(currentStrength * expectedMultiplier, 0.01));
    });

    test('updateStrength respects minimum strength', () {
      const currentStrength = 0.1;
      const minStrength = 0.1; // srs.dart のデフォルト値
      final newStrength = srs.updateStrength(currentStrength, false, minStrength: minStrength);
      // 0.1 * 0.6 = 0.06 だが、下限値 0.1 にクランプされるはず
      expect(newStrength, equals(minStrength));
    });

     test('updateStrength respects maximum strength', () {
      const currentStrength = 80.0;
      const maxStrength = 100.0; // srs.dart のデフォルト値
      final newStrength = srs.updateStrength(currentStrength, true, maxStrength: maxStrength);
      // 80.0 * 1.7 = 136.0 だが、上限値 100.0 にクランプされるはず
      expect(newStrength, equals(maxStrength));
    });


    test('calcNextReview calculates future date for positive strength', () {
      final now = DateTime.now();
      const strength = 2.5;
      final nextReview = srs.calcNextReview(now, strength);
      expect(nextReview.isAfter(now), isTrue);
      // 簡単なチェック: 強度が高いほど間隔が長くなるはず
      final nextReviewWeaker = srs.calcNextReview(now, 1.0);
      expect(nextReview.isAfter(nextReviewWeaker), isTrue);
    });

     test('calcNextReview calculates short interval for low strength', () {
      final now = DateTime.now();
      const strength = 0.1; // 最小強度に近い値
      final nextReview = srs.calcNextReview(now, strength);
      // 最小間隔 (1時間) に近いはず
      expect(nextReview.difference(now).inHours, lessThanOrEqualTo(1));
       // 強度が1.0未満の場合は即座に復習（Duration.zero）
      final nextReviewZero = srs.calcNextReview(now, 0);
      expect(nextReviewZero.difference(now).inMinutes, equals(0));
    });

    test('calcNextReview respects maximum interval', () {
      final now = DateTime.now();
      const veryHighStrength = 500.0; // 非常に高い強度
      const maxDays = 365;
      final nextReview = srs.calcNextReview(now, veryHighStrength);
      // 最大間隔 (1年) を超えないはず
      expect(nextReview.difference(now).inDays, lessThanOrEqualTo(maxDays));
    });

    // TODO: Add more edge cases if necessary
  });
}