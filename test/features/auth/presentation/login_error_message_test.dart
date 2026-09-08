import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/core/foundation/failure.dart';
import 'package:hzn_gyms/src/core/i18n/strings.g.dart';
import 'package:hzn_gyms/src/features/auth/presentation/login_error_message.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  test('maps google_no_staff identifier', () {
    expect(
      loginErrorMessage(
        const AuthFailure('x', null, 'google_no_staff'),
      ),
      t.failures.googleNoStaffAccount,
    );
  });

  test('maps google_launch_failed identifier', () {
    expect(
      loginErrorMessage(
        const AuthFailure('x', null, 'google_launch_failed'),
      ),
      t.failures.googleSignInFailed,
    );
  });

  test('maps otp_invalid identifier', () {
    expect(
      loginErrorMessage(
        const AuthFailure('Invalid or expired OTP', null, 'otp_invalid'),
      ),
      t.failures.invalidLoginCode,
    );
  });

  test('falls back to invalid credentials', () {
    expect(loginErrorMessage(Exception('boom')), t.failures.invalidCredentials);
  });
}
