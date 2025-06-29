import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// エラーの重要度レベル
enum ErrorSeverity {
  high, // クリティカルエラー：必ずSentryに送信し、rethrowする
  medium, // 中程度のエラー：Sentryに送信するが、処理は継続
  low, // 軽微なエラー：開発環境でのみログ出力、本番ではSentryに送信
}

class FirebaseRepositoryErrorHandler {
  static const _tag = 'FirebaseRepository';

  /// エラーハンドリングのメインメソッド
  static void handleError({
    required Object error,
    required StackTrace stackTrace,
    required String operation,
    required ErrorSeverity severity,
    String? userId,
    Map<String, dynamic>? extra,
    bool shouldRethrow = false,
  }) {
    // デバッグプリント（開発時用）
    debugPrint('[$_tag] Error in $operation: $error');

    // Sentryへの送信判定
    if (_shouldSendToSentry(severity)) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('repository', _tag);
          scope.setTag('operation', operation);
          scope.setTag('severity', severity.name);

          if (userId != null) {
            scope.setUser(SentryUser(id: userId));
          }

          scope.setContexts('firebase_operation', {
            'operation': operation,
            'severity': severity.name,
            ...?extra,
          });
        },
      );
    }

    // 高優先度エラーまたは明示的に指定された場合はrethrow
    if (shouldRethrow || severity == ErrorSeverity.high) {
      throw error;
    }
  }

  /// Streamのエラーハンドリング用メソッド
  static T handleStreamError<T>({
    required Object error,
    required StackTrace stackTrace,
    required String operation,
    required T defaultValue,
    required ErrorSeverity severity,
    String? userId,
    Map<String, dynamic>? extra,
  }) {
    handleError(
      error: error,
      stackTrace: stackTrace,
      operation: operation,
      severity: severity,
      userId: userId,
      extra: extra,
      shouldRethrow: false,
    );
    return defaultValue;
  }

  /// Sentryに送信すべきかどうかの判定
  static bool _shouldSendToSentry(ErrorSeverity severity) {
    // 本番環境では全てのエラーを送信
    if (kReleaseMode) {
      return true;
    }

    // 開発環境では高・中優先度のみ送信
    return severity == ErrorSeverity.high || severity == ErrorSeverity.medium;
  }

  /// エラーの重要度を判定
  static ErrorSeverity determineErrorSeverity(String operation) {
    // クリティカルな操作
    const highPriorityOperations = [
      'signInAnonymously',
      'createUserDocumentIfNotExists',
      'getUser',
      'updateUserDocument',
      'applyInvitationCode',
      'addUserCard',
      'updateUserCard',
      'deleteUserCard',
      'deleteAllCardsForVideo',
      'addOrUpdateSharedVideo',
      'uploadScreenshot',
      'decrementUserGem',
      'incrementUserGem',
      'batchWriteUserCards',
      'batchWriteUserDailyStats',
      'batchWriteSharedVideos',
    ];

    // 中程度の重要度の操作
    const mediumPriorityOperations = [
      'updateUserDailyStat',
      'getUserDailyStat',
      'getSharedVideo',
      'getUserVideoIds',
      'updateUserStreaks',
      'markHiveDataAsMigrated',
      'updateFavoriteChannel',
    ];

    if (highPriorityOperations.contains(operation)) {
      return ErrorSeverity.high;
    } else if (mediumPriorityOperations.contains(operation)) {
      return ErrorSeverity.medium;
    } else {
      return ErrorSeverity.low;
    }
  }
}
