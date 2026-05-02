/// Canonical English strings for auth errors and snackbars.
/// Keep in sync with [AppLocalizations] mapping in [auth_message_localizer.dart].
abstract final class AuthUserMessage {
  static const serverUnreachable =
      'Unable to reach the server. Check your connection and try again.';
  static const somethingWrong = 'Something went wrong. Please try again.';
  static const requestFailed = 'Request failed. Please try again.';
  static const emailAlreadyRegistered =
      'This email is already registered. Try signing in instead.';
  static const confirmEmailBeforeContinuing =
      'Please confirm your email address before continuing.';
  static const passwordDoesNotMeetRequirements =
      'Password does not meet the requirements.';
  static const enterValidEmail = 'Please enter a valid email address.';
  static const rateLimited =
      'Too many attempts. Please wait a moment and try again.';
  static const otpExpired = 'This code has expired. Request a new one.';
  static const invalidVerificationCode =
      'Invalid verification code. Please check and try again.';
  static const sessionFailed =
      'Could not establish a session. Please try again.';

  static const unexpectedError =
      'An unexpected error occurred. Please try again.';
  static const signOutFailed = 'Sign out failed. Please try again.';
}
