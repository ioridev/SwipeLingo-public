import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:intl/intl.dart';

/// 過去の活動量を表示するヒートマップウィジェット。
class HeatmapChart extends StatelessWidget {
  /// キーが日付 (DateTime、日付部分のみ使用)、値が活動量 (int) のマップ。
  final Map<DateTime, int> data;

  /// 表示する週の数。
  final int weeksToShow;

  /// 各マス目のサイズ。
  final double squareSize;

  /// マス目間のパディング。
  final double squarePadding;

  /// マス目の角丸。
  final double borderRadius;

  /// 活動量に応じた色のリスト (薄い色から濃い色へ)。
  final List<Color>? colorSteps;

  /// 活動量がゼロの場合のマス目の色。指定されない場合はデフォルトの灰色。
  final Color? zeroActivityColor;

  /// 曜日ラベルのスタイル。
  final TextStyle? dayLabelStyle;

  /// 月ラベルのスタイル。
  final TextStyle? monthLabelStyle;

  const HeatmapChart({
    super.key,
    required this.data,
    this.weeksToShow = 15, // 約3.5ヶ月分
    this.squareSize = 16.0,
    this.squarePadding = 2.0,
    this.borderRadius = 4.0,
    this.colorSteps,
    this.zeroActivityColor,
    this.dayLabelStyle,
    this.monthLabelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NeumorphicTheme.currentTheme(context);
    // デフォルトの色ステップ (Neumorphic の色をベースに、アルファ値を調整)
    // withOpacity は非推奨のため、直接 Color を定義するか、他の方法を使う
    // デフォルトの色ステップ (Neumorphic の色をベースに、アルファ値を調整)
    // 正の活動量に対する色。ゼロ活動量は別途処理。
    final defaultPositiveActivityColors = [
      theme.accentColor.withAlpha(100), // 少ない
      theme.accentColor.withAlpha(150),
      theme.accentColor.withAlpha(200),
      theme.accentColor.withAlpha(255), // 多い
    ];
    // ユーザー指定の colorSteps があればそれを使用し、なければデフォルトの正活動量色リストを使用
    final actualColorSteps = colorSteps ?? defaultPositiveActivityColors;

    // 表示する最後の日 (今日)
    final today = DateTime.now();
    final endDate = DateTime(today.year, today.month, today.day);
    // 表示する最初の日を計算 (weeksToShow 分遡る)
    // 日曜始まりで計算するため、今日の曜日を考慮
    final daysToSubtract = (endDate.weekday % 7) + (weeksToShow - 1) * 7;
    final startDate = endDate.subtract(Duration(days: daysToSubtract));

    // 最大活動量を見つけて色の段階を決める (単純な線形スケール)
    int maxActivity = 1; // 0除算を防ぐため最低1
    if (data.isNotEmpty) {
      maxActivity = data.values.fold(0, (max, v) => v > max ? v : max);
      if (maxActivity == 0) maxActivity = 1; // 全て0の場合
    }
    // 色を取得する関数
    Color getColor(int activity) {
      if (activity <= 0) {
        // 活動量がゼロ以下の場合は、指定された zeroActivityColor を使うか、デフォルトの灰色を使う
        return zeroActivityColor ?? Colors.grey.withOpacity(0.5);
      }

      // 活動量が正の場合
      if (actualColorSteps.isEmpty) {
        // 色ステップが空の場合は、フォールバックとして灰色を返す
        return Colors.grey.withOpacity(0.5);
      }

      if (maxActivity == 0) {
        // 最大活動量が0だが activity > 0 という状況は通常ありえないが、
        // 安全のために actualColorSteps の最初の色を返す
        return actualColorSteps[0];
      }

      // 活動量に応じて色ステップから色を選択
      // 各色ステップが担当する活動量の範囲を計算
      final double stepValue = maxActivity / actualColorSteps.length;
      int index = (activity / stepValue).ceil() - 1;
      // 計算されたインデックスが有効な範囲内にあることを保証
      index = index.clamp(0, actualColorSteps.length - 1);

      return actualColorSteps[index];
    }

    // ヒートマップ本体の GridView のみを返す
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: weeksToShow, // 列数 = 週数
        mainAxisSpacing: squarePadding,
        crossAxisSpacing: squarePadding,
      ),
      itemCount: weeksToShow * 7, // 7 days * weeksToShow
      shrinkWrap: true, // Column や Row 内で使う場合や、スクロールさせない場合に必要
      physics: const NeverScrollableScrollPhysics(), // スクロール不要
      itemBuilder: (context, index) {
        // GridView は左上から右下へ配置される
        // 実際のカレンダー表示 (左が過去、右が未来) に合わせるためインデックスを調整
        final col = index % weeksToShow;
        final row = index ~/ weeksToShow;
        final date = startDate.add(Duration(days: col * 7 + row));

        // 日付が未来の場合は表示しない (または別のスタイル)
        if (date.isAfter(endDate)) {
          return SizedBox(width: squareSize, height: squareSize);
        }

        final activity = data[date] ?? 0;
        final color = getColor(activity);

        return Container(
          width: squareSize,
          height: squareSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          // TODO: タップで詳細表示などのインタラクションを追加可能
          // child: Tooltip(message: '${DateFormat.yMd().format(date)}: $activity'),
        );
      },
    );
  }

  // 以下のメソッドは不要になったため削除
  // _buildDayLabelColumn
  // _buildMonthLabels
  // _buildMonthLabelRow
}
