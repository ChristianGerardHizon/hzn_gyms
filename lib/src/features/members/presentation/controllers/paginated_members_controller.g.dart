// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_members_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing paginated members list.

@ProviderFor(PaginatedMembersController)
final paginatedMembersControllerProvider =
    PaginatedMembersControllerProvider._();

/// Controller for managing paginated members list.
final class PaginatedMembersControllerProvider extends $AsyncNotifierProvider<
    PaginatedMembersController, PaginatedState<Member>> {
  /// Controller for managing paginated members list.
  PaginatedMembersControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'paginatedMembersControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$paginatedMembersControllerHash();

  @$internal
  @override
  PaginatedMembersController create() => PaginatedMembersController();
}

String _$paginatedMembersControllerHash() =>
    r'e6c3e9b0518d6993d48e4dc85a84b1a04395bcff';

/// Controller for managing paginated members list.

abstract class _$PaginatedMembersController
    extends $AsyncNotifier<PaginatedState<Member>> {
  FutureOr<PaginatedState<Member>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<PaginatedState<Member>>, PaginatedState<Member>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<PaginatedState<Member>>, PaginatedState<Member>>,
        AsyncValue<PaginatedState<Member>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
