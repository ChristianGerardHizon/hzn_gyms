import '../../../core/foundation/failure.dart';
import '../../../core/i18n/strings.g.dart';

/// Maps auth [Failure]s to login-page copy.
String loginErrorMessage(Object? error) {
  if (error is Failure) {
    switch (error.identifier) {
      case 'google_no_staff':
        return t.failures.googleNoStaffAccount;
      case 'google_launch_failed':
        return t.failures.googleSignInFailed;
      case 'otp_invalid':
        return t.failures.invalidLoginCode;
      default:
        if (error is AuthFailure) {
          final msg = error.messageString;
          if (msg.isNotEmpty &&
              msg != 'Something went wrong' &&
              !msg.startsWith('Server request')) {
            return msg;
          }
        }
    }
  }
  return t.failures.invalidCredentials;
}
