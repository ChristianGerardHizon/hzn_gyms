// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_groups_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing POS groups for the current branch.
///
/// Provides CRUD operations on groups and group items.
/// Groups are loaded with their items expanded (products).

@ProviderFor(PosGroupsController)
final posGroupsControllerProvider = PosGroupsControllerProvider._();

/// Controller for managing POS groups for the current branch.
///
/// Provides CRUD operations on groups and group items.
/// Groups are loaded with their items expanded (products).
final class PosGroupsControllerProvider
    extends $AsyncNotifierProvider<PosGroupsController, List<PosGroup>> {
  /// Controller for managing POS groups for the current branch.
  ///
  /// Provides CRUD operations on groups and group items.
  /// Groups are loaded with their items expanded (products).
  PosGroupsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'posGroupsControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$posGroupsControllerHash();

  @$internal
  @override
  PosGroupsController create() => PosGroupsController();
}

String _$posGroupsControllerHash() =>
    r'e4e2c7839382de363e17253eae2c9bda633d0b81';

/// Controller for managing POS groups for the current branch.
///
/// Provides CRUD operations on groups and group items.
/// Groups are loaded with their items expanded (products).

abstract class _$PosGroupsController extends $AsyncNotifier<List<PosGroup>> {
  FutureOr<List<PosGroup>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<PosGroup>>, List<PosGroup>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<PosGroup>>, List<PosGroup>>,
        AsyncValue<List<PosGroup>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
