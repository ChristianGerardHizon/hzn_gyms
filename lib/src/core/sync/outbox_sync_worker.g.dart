// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_sync_worker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drains the outbox queue when online and auth allows writes.

@ProviderFor(OutboxSyncWorker)
final outboxSyncWorkerProvider = OutboxSyncWorkerProvider._();

/// Drains the outbox queue when online and auth allows writes.
final class OutboxSyncWorkerProvider
    extends $AsyncNotifierProvider<OutboxSyncWorker, void> {
  /// Drains the outbox queue when online and auth allows writes.
  OutboxSyncWorkerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outboxSyncWorkerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outboxSyncWorkerHash();

  @$internal
  @override
  OutboxSyncWorker create() => OutboxSyncWorker();
}

String _$outboxSyncWorkerHash() => r'cd3c72aef46305a5ce15ff7b3f9918db52d1b831';

/// Drains the outbox queue when online and auth allows writes.

abstract class _$OutboxSyncWorker extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for pending outbox count stream.

@ProviderFor(outboxPendingCount)
final outboxPendingCountProvider = OutboxPendingCountProvider._();

/// Provider for pending outbox count stream.

final class OutboxPendingCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Provider for pending outbox count stream.
  OutboxPendingCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outboxPendingCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outboxPendingCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return outboxPendingCount(ref);
  }
}

String _$outboxPendingCountHash() =>
    r'f7645d7366b41cc30de0322195906ce540f03f1b';

/// Provider for pending/failed outbox entries list.

@ProviderFor(outboxPendingEntries)
final outboxPendingEntriesProvider = OutboxPendingEntriesProvider._();

/// Provider for pending/failed outbox entries list.

final class OutboxPendingEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OutboxPendingItem>>,
          List<OutboxPendingItem>,
          FutureOr<List<OutboxPendingItem>>
        >
    with
        $FutureModifier<List<OutboxPendingItem>>,
        $FutureProvider<List<OutboxPendingItem>> {
  /// Provider for pending/failed outbox entries list.
  OutboxPendingEntriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outboxPendingEntriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outboxPendingEntriesHash();

  @$internal
  @override
  $FutureProviderElement<List<OutboxPendingItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OutboxPendingItem>> create(Ref ref) {
    return outboxPendingEntries(ref);
  }
}

String _$outboxPendingEntriesHash() =>
    r'37e28b4f1e8c4e321df00851ac012f1f1611e4a2';
