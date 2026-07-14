// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rfid_listener_status.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Exposes RFID listener on/off state for the Check-In app bar toggle.

@ProviderFor(RfidListenerStatusController)
final rfidListenerStatusControllerProvider =
    RfidListenerStatusControllerProvider._();

/// Exposes RFID listener on/off state for the Check-In app bar toggle.
final class RfidListenerStatusControllerProvider
    extends
        $NotifierProvider<RfidListenerStatusController, RfidListenerStatus> {
  /// Exposes RFID listener on/off state for the Check-In app bar toggle.
  RfidListenerStatusControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rfidListenerStatusControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rfidListenerStatusControllerHash();

  @$internal
  @override
  RfidListenerStatusController create() => RfidListenerStatusController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RfidListenerStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RfidListenerStatus>(value),
    );
  }
}

String _$rfidListenerStatusControllerHash() =>
    r'f17638a6e8ff5cb67480b7a9813f1799e36d7266';

/// Exposes RFID listener on/off state for the Check-In app bar toggle.

abstract class _$RfidListenerStatusController
    extends $Notifier<RfidListenerStatus> {
  RfidListenerStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RfidListenerStatus, RfidListenerStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RfidListenerStatus, RfidListenerStatus>,
              RfidListenerStatus,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
