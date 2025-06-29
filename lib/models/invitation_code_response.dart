/// 招待コード適用の結果を表すクラス
class ApplyInvitationCodeResponse {
  final ApplyInvitationCodeStatus status;
  final String displayMessage;

  ApplyInvitationCodeResponse({
    required this.status,
    required this.displayMessage,
  });

  bool get isSuccess => status == ApplyInvitationCodeStatus.success;
}

/// 招待コード適用のステータス
enum ApplyInvitationCodeStatus {
  success,
  errorUserNotFound,
  errorAlreadyUsed,
  errorInvalidCode,
  errorSelfCode,
  errorGeneric,
}