// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_cards_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing a member's physical ID cards.
///
/// Fetches all cards for a specific member by ID.

@ProviderFor(MemberCardsController)
final memberCardsControllerProvider = MemberCardsControllerFamily._();

/// Controller for managing a member's physical ID cards.
///
/// Fetches all cards for a specific member by ID.
final class MemberCardsControllerProvider
    extends $AsyncNotifierProvider<MemberCardsController, List<MemberCard>> {
  /// Controller for managing a member's physical ID cards.
  ///
  /// Fetches all cards for a specific member by ID.
  MemberCardsControllerProvider._(
      {required MemberCardsControllerFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'memberCardsControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memberCardsControllerHash();

  @override
  String toString() {
    return r'memberCardsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MemberCardsController create() => MemberCardsController();

  @override
  bool operator ==(Object other) {
    return other is MemberCardsControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberCardsControllerHash() =>
    r'1f7e68470ab36942430ef4b4cbac814c8882ecd8';

/// Controller for managing a member's physical ID cards.
///
/// Fetches all cards for a specific member by ID.

final class MemberCardsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
            MemberCardsController,
            AsyncValue<List<MemberCard>>,
            List<MemberCard>,
            FutureOr<List<MemberCard>>,
            String> {
  MemberCardsControllerFamily._()
      : super(
          retry: null,
          name: r'memberCardsControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Controller for managing a member's physical ID cards.
  ///
  /// Fetches all cards for a specific member by ID.

  MemberCardsControllerProvider call(
    String memberId,
  ) =>
      MemberCardsControllerProvider._(argument: memberId, from: this);

  @override
  String toString() => r'memberCardsControllerProvider';
}

/// Controller for managing a member's physical ID cards.
///
/// Fetches all cards for a specific member by ID.

abstract class _$MemberCardsController
    extends $AsyncNotifier<List<MemberCard>> {
  late final _$args = ref.$arg as String;
  String get memberId => _$args;

  FutureOr<List<MemberCard>> build(
    String memberId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<MemberCard>>, List<MemberCard>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<MemberCard>>, List<MemberCard>>,
        AsyncValue<List<MemberCard>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
