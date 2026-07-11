// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'inventory_report.dart';

class InventoryReportMapper extends ClassMapperBase<InventoryReport> {
  InventoryReportMapper._();

  static InventoryReportMapper? _instance;
  static InventoryReportMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InventoryReportMapper._());
      LowStockItemMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'InventoryReport';

  static int _$totalProducts(InventoryReport v) => v.totalProducts;
  static const Field<InventoryReport, int> _f$totalProducts = Field(
    'totalProducts',
    _$totalProducts,
  );
  static int _$inStockCount(InventoryReport v) => v.inStockCount;
  static const Field<InventoryReport, int> _f$inStockCount = Field(
    'inStockCount',
    _$inStockCount,
  );
  static int _$lowStockCount(InventoryReport v) => v.lowStockCount;
  static const Field<InventoryReport, int> _f$lowStockCount = Field(
    'lowStockCount',
    _$lowStockCount,
  );
  static int _$outOfStockCount(InventoryReport v) => v.outOfStockCount;
  static const Field<InventoryReport, int> _f$outOfStockCount = Field(
    'outOfStockCount',
    _$outOfStockCount,
  );
  static int _$expiredCount(InventoryReport v) => v.expiredCount;
  static const Field<InventoryReport, int> _f$expiredCount = Field(
    'expiredCount',
    _$expiredCount,
  );
  static int _$nearExpirationCount(InventoryReport v) => v.nearExpirationCount;
  static const Field<InventoryReport, int> _f$nearExpirationCount = Field(
    'nearExpirationCount',
    _$nearExpirationCount,
  );
  static num _$totalInventoryValue(InventoryReport v) => v.totalInventoryValue;
  static const Field<InventoryReport, num> _f$totalInventoryValue = Field(
    'totalInventoryValue',
    _$totalInventoryValue,
  );
  static Map<String, int> _$productsByCategory(InventoryReport v) =>
      v.productsByCategory;
  static const Field<InventoryReport, Map<String, int>> _f$productsByCategory =
      Field('productsByCategory', _$productsByCategory);
  static Map<String, int> _$stockStatusBreakdown(InventoryReport v) =>
      v.stockStatusBreakdown;
  static const Field<InventoryReport, Map<String, int>>
  _f$stockStatusBreakdown = Field(
    'stockStatusBreakdown',
    _$stockStatusBreakdown,
  );
  static List<LowStockItem> _$lowStockItems(InventoryReport v) =>
      v.lowStockItems;
  static const Field<InventoryReport, List<LowStockItem>> _f$lowStockItems =
      Field('lowStockItems', _$lowStockItems);

  @override
  final MappableFields<InventoryReport> fields = const {
    #totalProducts: _f$totalProducts,
    #inStockCount: _f$inStockCount,
    #lowStockCount: _f$lowStockCount,
    #outOfStockCount: _f$outOfStockCount,
    #expiredCount: _f$expiredCount,
    #nearExpirationCount: _f$nearExpirationCount,
    #totalInventoryValue: _f$totalInventoryValue,
    #productsByCategory: _f$productsByCategory,
    #stockStatusBreakdown: _f$stockStatusBreakdown,
    #lowStockItems: _f$lowStockItems,
  };

  static InventoryReport _instantiate(DecodingData data) {
    return InventoryReport(
      totalProducts: data.dec(_f$totalProducts),
      inStockCount: data.dec(_f$inStockCount),
      lowStockCount: data.dec(_f$lowStockCount),
      outOfStockCount: data.dec(_f$outOfStockCount),
      expiredCount: data.dec(_f$expiredCount),
      nearExpirationCount: data.dec(_f$nearExpirationCount),
      totalInventoryValue: data.dec(_f$totalInventoryValue),
      productsByCategory: data.dec(_f$productsByCategory),
      stockStatusBreakdown: data.dec(_f$stockStatusBreakdown),
      lowStockItems: data.dec(_f$lowStockItems),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static InventoryReport fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<InventoryReport>(map);
  }

  static InventoryReport fromJson(String json) {
    return ensureInitialized().decodeJson<InventoryReport>(json);
  }
}

mixin InventoryReportMappable {
  String toJson() {
    return InventoryReportMapper.ensureInitialized()
        .encodeJson<InventoryReport>(this as InventoryReport);
  }

  Map<String, dynamic> toMap() {
    return InventoryReportMapper.ensureInitialized().encodeMap<InventoryReport>(
      this as InventoryReport,
    );
  }

  InventoryReportCopyWith<InventoryReport, InventoryReport, InventoryReport>
  get copyWith =>
      _InventoryReportCopyWithImpl<InventoryReport, InventoryReport>(
        this as InventoryReport,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return InventoryReportMapper.ensureInitialized().stringifyValue(
      this as InventoryReport,
    );
  }

  @override
  bool operator ==(Object other) {
    return InventoryReportMapper.ensureInitialized().equalsValue(
      this as InventoryReport,
      other,
    );
  }

  @override
  int get hashCode {
    return InventoryReportMapper.ensureInitialized().hashValue(
      this as InventoryReport,
    );
  }
}

extension InventoryReportValueCopy<$R, $Out>
    on ObjectCopyWith<$R, InventoryReport, $Out> {
  InventoryReportCopyWith<$R, InventoryReport, $Out> get $asInventoryReport =>
      $base.as((v, t, t2) => _InventoryReportCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class InventoryReportCopyWith<$R, $In extends InventoryReport, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, int, ObjectCopyWith<$R, int, int>>
  get productsByCategory;
  MapCopyWith<$R, String, int, ObjectCopyWith<$R, int, int>>
  get stockStatusBreakdown;
  ListCopyWith<
    $R,
    LowStockItem,
    LowStockItemCopyWith<$R, LowStockItem, LowStockItem>
  >
  get lowStockItems;
  $R call({
    int? totalProducts,
    int? inStockCount,
    int? lowStockCount,
    int? outOfStockCount,
    int? expiredCount,
    int? nearExpirationCount,
    num? totalInventoryValue,
    Map<String, int>? productsByCategory,
    Map<String, int>? stockStatusBreakdown,
    List<LowStockItem>? lowStockItems,
  });
  InventoryReportCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _InventoryReportCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, InventoryReport, $Out>
    implements InventoryReportCopyWith<$R, InventoryReport, $Out> {
  _InventoryReportCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<InventoryReport> $mapper =
      InventoryReportMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, int, ObjectCopyWith<$R, int, int>>
  get productsByCategory => MapCopyWith(
    $value.productsByCategory,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(productsByCategory: v),
  );
  @override
  MapCopyWith<$R, String, int, ObjectCopyWith<$R, int, int>>
  get stockStatusBreakdown => MapCopyWith(
    $value.stockStatusBreakdown,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(stockStatusBreakdown: v),
  );
  @override
  ListCopyWith<
    $R,
    LowStockItem,
    LowStockItemCopyWith<$R, LowStockItem, LowStockItem>
  >
  get lowStockItems => ListCopyWith(
    $value.lowStockItems,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(lowStockItems: v),
  );
  @override
  $R call({
    int? totalProducts,
    int? inStockCount,
    int? lowStockCount,
    int? outOfStockCount,
    int? expiredCount,
    int? nearExpirationCount,
    num? totalInventoryValue,
    Map<String, int>? productsByCategory,
    Map<String, int>? stockStatusBreakdown,
    List<LowStockItem>? lowStockItems,
  }) => $apply(
    FieldCopyWithData({
      if (totalProducts != null) #totalProducts: totalProducts,
      if (inStockCount != null) #inStockCount: inStockCount,
      if (lowStockCount != null) #lowStockCount: lowStockCount,
      if (outOfStockCount != null) #outOfStockCount: outOfStockCount,
      if (expiredCount != null) #expiredCount: expiredCount,
      if (nearExpirationCount != null)
        #nearExpirationCount: nearExpirationCount,
      if (totalInventoryValue != null)
        #totalInventoryValue: totalInventoryValue,
      if (productsByCategory != null) #productsByCategory: productsByCategory,
      if (stockStatusBreakdown != null)
        #stockStatusBreakdown: stockStatusBreakdown,
      if (lowStockItems != null) #lowStockItems: lowStockItems,
    }),
  );
  @override
  InventoryReport $make(CopyWithData data) => InventoryReport(
    totalProducts: data.get(#totalProducts, or: $value.totalProducts),
    inStockCount: data.get(#inStockCount, or: $value.inStockCount),
    lowStockCount: data.get(#lowStockCount, or: $value.lowStockCount),
    outOfStockCount: data.get(#outOfStockCount, or: $value.outOfStockCount),
    expiredCount: data.get(#expiredCount, or: $value.expiredCount),
    nearExpirationCount: data.get(
      #nearExpirationCount,
      or: $value.nearExpirationCount,
    ),
    totalInventoryValue: data.get(
      #totalInventoryValue,
      or: $value.totalInventoryValue,
    ),
    productsByCategory: data.get(
      #productsByCategory,
      or: $value.productsByCategory,
    ),
    stockStatusBreakdown: data.get(
      #stockStatusBreakdown,
      or: $value.stockStatusBreakdown,
    ),
    lowStockItems: data.get(#lowStockItems, or: $value.lowStockItems),
  );

  @override
  InventoryReportCopyWith<$R2, InventoryReport, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _InventoryReportCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class LowStockItemMapper extends ClassMapperBase<LowStockItem> {
  LowStockItemMapper._();

  static LowStockItemMapper? _instance;
  static LowStockItemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LowStockItemMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'LowStockItem';

  static String _$productName(LowStockItem v) => v.productName;
  static const Field<LowStockItem, String> _f$productName = Field(
    'productName',
    _$productName,
  );
  static String _$categoryName(LowStockItem v) => v.categoryName;
  static const Field<LowStockItem, String> _f$categoryName = Field(
    'categoryName',
    _$categoryName,
  );
  static num _$currentStock(LowStockItem v) => v.currentStock;
  static const Field<LowStockItem, num> _f$currentStock = Field(
    'currentStock',
    _$currentStock,
  );
  static num _$threshold(LowStockItem v) => v.threshold;
  static const Field<LowStockItem, num> _f$threshold = Field(
    'threshold',
    _$threshold,
  );
  static DateTime? _$expirationDate(LowStockItem v) => v.expirationDate;
  static const Field<LowStockItem, DateTime> _f$expirationDate = Field(
    'expirationDate',
    _$expirationDate,
  );

  @override
  final MappableFields<LowStockItem> fields = const {
    #productName: _f$productName,
    #categoryName: _f$categoryName,
    #currentStock: _f$currentStock,
    #threshold: _f$threshold,
    #expirationDate: _f$expirationDate,
  };

  static LowStockItem _instantiate(DecodingData data) {
    return LowStockItem(
      productName: data.dec(_f$productName),
      categoryName: data.dec(_f$categoryName),
      currentStock: data.dec(_f$currentStock),
      threshold: data.dec(_f$threshold),
      expirationDate: data.dec(_f$expirationDate),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static LowStockItem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LowStockItem>(map);
  }

  static LowStockItem fromJson(String json) {
    return ensureInitialized().decodeJson<LowStockItem>(json);
  }
}

mixin LowStockItemMappable {
  String toJson() {
    return LowStockItemMapper.ensureInitialized().encodeJson<LowStockItem>(
      this as LowStockItem,
    );
  }

  Map<String, dynamic> toMap() {
    return LowStockItemMapper.ensureInitialized().encodeMap<LowStockItem>(
      this as LowStockItem,
    );
  }

  LowStockItemCopyWith<LowStockItem, LowStockItem, LowStockItem> get copyWith =>
      _LowStockItemCopyWithImpl<LowStockItem, LowStockItem>(
        this as LowStockItem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return LowStockItemMapper.ensureInitialized().stringifyValue(
      this as LowStockItem,
    );
  }

  @override
  bool operator ==(Object other) {
    return LowStockItemMapper.ensureInitialized().equalsValue(
      this as LowStockItem,
      other,
    );
  }

  @override
  int get hashCode {
    return LowStockItemMapper.ensureInitialized().hashValue(
      this as LowStockItem,
    );
  }
}

extension LowStockItemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LowStockItem, $Out> {
  LowStockItemCopyWith<$R, LowStockItem, $Out> get $asLowStockItem =>
      $base.as((v, t, t2) => _LowStockItemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LowStockItemCopyWith<$R, $In extends LowStockItem, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? productName,
    String? categoryName,
    num? currentStock,
    num? threshold,
    DateTime? expirationDate,
  });
  LowStockItemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _LowStockItemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LowStockItem, $Out>
    implements LowStockItemCopyWith<$R, LowStockItem, $Out> {
  _LowStockItemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LowStockItem> $mapper =
      LowStockItemMapper.ensureInitialized();
  @override
  $R call({
    String? productName,
    String? categoryName,
    num? currentStock,
    num? threshold,
    Object? expirationDate = $none,
  }) => $apply(
    FieldCopyWithData({
      if (productName != null) #productName: productName,
      if (categoryName != null) #categoryName: categoryName,
      if (currentStock != null) #currentStock: currentStock,
      if (threshold != null) #threshold: threshold,
      if (expirationDate != $none) #expirationDate: expirationDate,
    }),
  );
  @override
  LowStockItem $make(CopyWithData data) => LowStockItem(
    productName: data.get(#productName, or: $value.productName),
    categoryName: data.get(#categoryName, or: $value.categoryName),
    currentStock: data.get(#currentStock, or: $value.currentStock),
    threshold: data.get(#threshold, or: $value.threshold),
    expirationDate: data.get(#expirationDate, or: $value.expirationDate),
  );

  @override
  LowStockItemCopyWith<$R2, LowStockItem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LowStockItemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

