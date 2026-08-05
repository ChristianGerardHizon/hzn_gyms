/// Toggleable status groups for the sales list / search fields dialog.
const saleStatusFilterOptions = [
  'paid',
  'voided',
  'awaitingPayment',
];

/// Default: all status groups enabled (no status filter applied).
const defaultSaleStatusFilters = {
  'paid',
  'voided',
  'awaitingPayment',
};

/// PocketBase `status` values represented by a filter option.
///
/// - [paid] includes legacy `completed`
/// - [awaitingPayment] includes unpaid `pending` (no payment yet)
List<String> saleStatusesForFilterOption(String option) {
  return switch (option) {
    'paid' => const ['paid', 'completed'],
    'voided' => const ['voided'],
    'awaitingPayment' => const ['awaitingPayment', 'pending'],
    _ => [option],
  };
}

/// Builds a PocketBase status filter, or `null` when none should be applied.
///
/// When every default option is selected, returns `null` so edge statuses are
/// not accidentally hidden. Otherwise ORs the expanded status values.
String? buildSaleStatusFilter(Set<String> selectedOptions) {
  if (selectedOptions.isEmpty) return null;

  final coversDefaults = defaultSaleStatusFilters.every(selectedOptions.contains) &&
      selectedOptions.every(defaultSaleStatusFilters.contains);
  if (coversDefaults) return null;

  final statuses = <String>[];
  for (final option in saleStatusFilterOptions) {
    if (!selectedOptions.contains(option)) continue;
    for (final status in saleStatusesForFilterOption(option)) {
      if (!statuses.contains(status)) statuses.add(status);
    }
  }
  if (statuses.isEmpty) return null;

  if (statuses.length == 1) {
    return 'status = "${statuses.first}"';
  }
  return '(${statuses.map((s) => 'status = "$s"').join(' || ')})';
}

/// Combines optional PocketBase filter fragments with `&&`.
String? combineSaleListFilters(Iterable<String?> parts) {
  final nonEmpty = parts
      .whereType<String>()
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();
  if (nonEmpty.isEmpty) return null;
  return nonEmpty.join(' && ');
}
