import '../../features/auth/domain/auth_user_message.dart';
import '../../l10n/app_localizations.dart';

/// Maps backend / repository English messages to [AppLocalizations] strings.
extension AuthMessageLocalizer on AppLocalizations {
  String localizeAuthUserMessage(String message) {
    switch (message.trim()) {
      case AuthUserMessage.serverUnreachable:
        return authErrServerUnreachable;
      case AuthUserMessage.somethingWrong:
        return authErrSomethingWrong;
      case AuthUserMessage.requestFailed:
        return authErrRequestFailed;
      case AuthUserMessage.emailAlreadyRegistered:
        return authErrEmailAlreadyRegistered;
      case AuthUserMessage.confirmEmailBeforeContinuing:
        return authErrConfirmEmail;
      case AuthUserMessage.passwordDoesNotMeetRequirements:
        return authErrPasswordRequirements;
      case AuthUserMessage.enterValidEmail:
        return authErrEnterValidEmail;
      case AuthUserMessage.rateLimited:
        return authErrRateLimited;
      case AuthUserMessage.otpExpired:
        return authErrOtpExpired;
      case AuthUserMessage.invalidVerificationCode:
        return authErrInvalidOtp;
      case AuthUserMessage.sessionFailed:
        return authErrSessionFailed;
      case AuthUserMessage.unexpectedError:
        return authErrUnexpected;
      case AuthUserMessage.signOutFailed:
        return authErrSignOutFailed;
      default:
        return _fallbackAuthMessage(message);
    }
  }

  String _fallbackAuthMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid') &&
        (lower.contains('credential') ||
            lower.contains('password') ||
            lower.contains('login'))) {
      return authErrInvalidCredentials;
    }
    if (lower.contains('email') && lower.contains('confirm')) {
      return authErrConfirmEmail;
    }
    if (localeName.startsWith('tr')) {
      return authErrUnexpected;
    }
    return message;
  }
}
