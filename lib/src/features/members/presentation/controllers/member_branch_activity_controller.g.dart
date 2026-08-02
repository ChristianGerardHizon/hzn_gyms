// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_branch_activity_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads active branch access for the given member IDs.

@ProviderFor(memberBranchActivityForIds)
final memberBranchActivityForIdsProvider = MemberBranchActivityForIdsFamily._();

/// Loads active branch access for the given member IDs.

final class MemberBranchActivityForIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<MemberBranchActivityState>,
          MemberBranchActivityState,
          FutureOr<MemberBranchActivityState>
        >
    with
        $FutureModifier<MemberBranchActivityState>,
        $FutureProvider<MemberBranchActivityState> {
  /// Loads active branch access for the given member IDs.
  MemberBranchActivityForIdsProvider._({
    required MemberBranchActivityForIdsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'memberBranchActivityForIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberBranchActivityForIdsHash();

  @override
  String toString() {
    return r'memberBranchActivityForIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MemberBranchActivityState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MemberBranchActivityState> create(Ref ref) {
    final argument = this.argument as String;
    return memberBranchActivityForIds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberBranchActivityForIdsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberBranchActivityForIdsHash() =>
    r'e8c95a01d9742162e520ecf9f7a813ac3703a87a';

/// Loads active branch access for the given member IDs.

final class MemberBranchActivityForIdsFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<MemberBranchActivityState>, String> {
  MemberBranchActivityForIdsFamily._()
    : super(
        retry: null,
        name: r'memberBranchActivityForIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads active branch access for the given member IDs.

  MemberBranchActivityForIdsProvider call(String memberIdsKey) =>
      MemberBranchActivityForIdsProvider._(argument: memberIdsKey, from: this);

  @override
  String toString() => r'memberBranchActivityForIdsProvider';
}

/// Loads active branch access for all members on the current paginated page.

@ProviderFor(memberBranchActivityMap)
final memberBranchActivityMapProvider = MemberBranchActivityMapProvider._();

/// Loads active branch access for all members on the current paginated page.

final class MemberBranchActivityMapProvider
    extends
        $FunctionalProvider<
          AsyncValue<MemberBranchActivityState>,
          MemberBranchActivityState,
          FutureOr<MemberBranchActivityState>
        >
    with
        $FutureModifier<MemberBranchActivityState>,
        $FutureProvider<MemberBranchActivityState> {
  /// Loads active branch access for all members on the current paginated page.
  MemberBranchActivityMapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberBranchActivityMapProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberBranchActivityMapHash();

  @$internal
  @override
  $FutureProviderElement<MemberBranchActivityState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MemberBranchActivityState> create(Ref ref) {
    return memberBranchActivityMap(ref);
  }
}

String _$memberBranchActivityMapHash() =>
    r'82f035f853d66b84604e32c6d0dd1cba089d6141';
