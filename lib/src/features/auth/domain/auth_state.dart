import 'package:dart_mappable/dart_mappable.dart';

import 'user.dart';

part 'auth_state.mapper.dart';

/// Represents the authentication state with user and token.
///
/// This is the data stored when a user is authenticated.
@MappableClass()
class AuthState with AuthStateMappable {
  /// The authentication token.
  final String token;

  /// The authenticated user record.
  final User user;

  const AuthState({
    required this.token,
    required this.user,
  });

  /// Whether the user's account is verified.
  bool get isVerified => user.verified;
}
