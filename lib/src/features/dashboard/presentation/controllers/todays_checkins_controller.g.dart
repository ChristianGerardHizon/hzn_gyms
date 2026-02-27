// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todays_checkins_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Count of check-ins today for the current branch.

@ProviderFor(todaysCheckInsCount)
final todaysCheckInsCountProvider = TodaysCheckInsCountProvider._();

/// Count of check-ins today for the current branch.

final class TodaysCheckInsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of check-ins today for the current branch.
  TodaysCheckInsCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'todaysCheckInsCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$todaysCheckInsCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return todaysCheckInsCount(ref);
  }
}

String _$todaysCheckInsCountHash() =>
    r'a4dc7f9ae52e034e1abd55f4f0e1cb6480725fef';
