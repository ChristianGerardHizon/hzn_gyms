// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to fetch a single branch by ID.

@ProviderFor(branch)
final branchProvider = BranchFamily._();

/// Provider to fetch a single branch by ID.

final class BranchProvider
    extends $FunctionalProvider<AsyncValue<Branch?>, Branch?, FutureOr<Branch?>>
    with $FutureModifier<Branch?>, $FutureProvider<Branch?> {
  /// Provider to fetch a single branch by ID.
  BranchProvider._({
    required BranchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'branchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$branchHash();

  @override
  String toString() {
    return r'branchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Branch?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Branch?> create(Ref ref) {
    final argument = this.argument as String;
    return branch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BranchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$branchHash() => r'3adc9eab54590cf04cd78670c6ba0ef6b3057159';

/// Provider to fetch a single branch by ID.

final class BranchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Branch?>, String> {
  BranchFamily._()
    : super(
        retry: null,
        name: r'branchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to fetch a single branch by ID.

  BranchProvider call(String id) => BranchProvider._(argument: id, from: this);

  @override
  String toString() => r'branchProvider';
}
