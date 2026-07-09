// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'members_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing the list of members.

@ProviderFor(MembersController)
final membersControllerProvider = MembersControllerProvider._();

/// Controller for managing the list of members.
final class MembersControllerProvider
    extends $AsyncNotifierProvider<MembersController, List<Member>> {
  /// Controller for managing the list of members.
  MembersControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membersControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membersControllerHash();

  @$internal
  @override
  MembersController create() => MembersController();
}

String _$membersControllerHash() => r'eedce3c8903d68561a16d8ff60881baac4a06afa';

/// Controller for managing the list of members.

abstract class _$MembersController extends $AsyncNotifier<List<Member>> {
  FutureOr<List<Member>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Member>>, List<Member>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Member>>, List<Member>>,
              AsyncValue<List<Member>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
