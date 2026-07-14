// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_sales_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for fetching a specific member's sales history.

@ProviderFor(memberSales)
final memberSalesProvider = MemberSalesFamily._();

/// Provider for fetching a specific member's sales history.

final class MemberSalesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Sale>>,
          List<Sale>,
          FutureOr<List<Sale>>
        >
    with $FutureModifier<List<Sale>>, $FutureProvider<List<Sale>> {
  /// Provider for fetching a specific member's sales history.
  MemberSalesProvider._({
    required MemberSalesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'memberSalesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberSalesHash();

  @override
  String toString() {
    return r'memberSalesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Sale>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Sale>> create(Ref ref) {
    final argument = this.argument as String;
    return memberSales(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberSalesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberSalesHash() => r'21bdb9168e7eaf16a058d47aa4155d31836c7827';

/// Provider for fetching a specific member's sales history.

final class MemberSalesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Sale>>, String> {
  MemberSalesFamily._()
    : super(
        retry: null,
        name: r'memberSalesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for fetching a specific member's sales history.

  MemberSalesProvider call(String memberId) =>
      MemberSalesProvider._(argument: memberId, from: this);

  @override
  String toString() => r'memberSalesProvider';
}
