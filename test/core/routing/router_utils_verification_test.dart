import 'package:flutter_test/flutter_test.dart';

import 'package:hzn_gyms/src/core/routing/router_utils.dart';
import 'package:hzn_gyms/src/core/routing/routes/auth.routes.dart';

void main() {
  test('verify-email and confirm-verification are auth-ignored routes', () {
    expect(
      RouterUtils.ignoredRoutes.any((r) => r == VerifyEmailRoute.path),
      isTrue,
    );
    expect(
      RouterUtils.ignoredRoutes.any(
        (r) => ConfirmVerificationRoute.path.startsWith(r) || r == '/confirm-verification',
      ),
      isTrue,
    );
  });

  test('VerifyEmailRoute path is /verify-email', () {
    expect(VerifyEmailRoute.path, '/verify-email');
  });
}
