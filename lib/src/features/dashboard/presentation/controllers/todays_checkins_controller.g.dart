// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todays_checkins_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Count of check-ins today for the current branch / organization.

@ProviderFor(todaysCheckInsCount)
final todaysCheckInsCountProvider = TodaysCheckInsCountProvider._();

/// Count of check-ins today for the current branch / organization.

final class TodaysCheckInsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of check-ins today for the current branch / organization.
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
    r'4da4ce13b69e96b971c4b7ff57e28d16b34c6b11';
