// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'sales_report.dart';

class SalesReportMapper extends ClassMapperBase<SalesReport> {
  SalesReportMapper._();

  static SalesReportMapper? _instance;
  static SalesReportMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SalesReportMapper._());
      PeriodBucketMapper.ensureInitialized();
      ProductSalesSummaryMapper.ensureInitialized();
      StaffSalesSummaryMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'SalesReport';

  static num _$totalRevenue(SalesReport v) => v.totalRevenue;
  static const Field<SalesReport, num> _f$totalRevenue = Field(
    'totalRevenue',
    _$totalRevenue,
  );
  static int _$transactionCount(SalesReport v) => v.transactionCount;
  static const Field<SalesReport, int> _f$transactionCount = Field(
    'transactionCount',
    _$transactionCount,
  );
  static num _$averageTransactionValue(SalesReport v) =>
      v.averageTransactionValue;
  static const Field<SalesReport, num> _f$averageTransactionValue = Field(
    'averageTransactionValue',
    _$averageTransactionValue,
  );
  static List<PeriodBucket> _$revenueTrend(SalesReport v) => v.revenueTrend;
  static const Field<SalesReport, List<PeriodBucket>> _f$revenueTrend = Field(
    'revenueTrend',
    _$revenueTrend,
  );
  static Map<String, num> _$revenueByPaymentMethod(SalesReport v) =>
      v.revenueByPaymentMethod;
  static const Field<SalesReport, Map<String, num>> _f$revenueByPaymentMethod =
      Field('revenueByPaymentMethod', _$revenueByPaymentMethod);
  static List<ProductSalesSummary> _$topSellingProducts(SalesReport v) =>
      v.topSellingProducts;
  static const Field<SalesReport, List<ProductSalesSummary>>
  _f$topSellingProducts = Field('topSellingProducts', _$topSellingProducts);
  static Map<String, num> _$revenueByItemType(SalesReport v) =>
      v.revenueByItemType;
  static const Field<SalesReport, Map<String, num>> _f$revenueByItemType =
      Field('revenueByItemType', _$revenueByItemType, opt: true, def: const {});
  static int _$unpaidSalesCount(SalesReport v) => v.unpaidSalesCount;
  static const Field<SalesReport, int> _f$unpaidSalesCount = Field(
    'unpaidSalesCount',
    _$unpaidSalesCount,
    opt: true,
    def: 0,
  );
  static num _$unpaidBalance(SalesReport v) => v.unpaidBalance;
  static const Field<SalesReport, num> _f$unpaidBalance = Field(
    'unpaidBalance',
    _$unpaidBalance,
    opt: true,
    def: 0,
  );
  static List<StaffSalesSummary> _$staffPerformance(SalesReport v) =>
      v.staffPerformance;
  static const Field<SalesReport, List<StaffSalesSummary>> _f$staffPerformance =
      Field('staffPerformance', _$staffPerformance, opt: true, def: const []);

  @override
  final MappableFields<SalesReport> fields = const {
    #totalRevenue: _f$totalRevenue,
    #transactionCount: _f$transactionCount,
    #averageTransactionValue: _f$averageTransactionValue,
    #revenueTrend: _f$revenueTrend,
    #revenueByPaymentMethod: _f$revenueByPaymentMethod,
    #topSellingProducts: _f$topSellingProducts,
    #revenueByItemType: _f$revenueByItemType,
    #unpaidSalesCount: _f$unpaidSalesCount,
    #unpaidBalance: _f$unpaidBalance,
    #staffPerformance: _f$staffPerformance,
  };

  static SalesReport _instantiate(DecodingData data) {
    return SalesReport(
      totalRevenue: data.dec(_f$totalRevenue),
      transactionCount: data.dec(_f$transactionCount),
      averageTransactionValue: data.dec(_f$averageTransactionValue),
      revenueTrend: data.dec(_f$revenueTrend),
      revenueByPaymentMethod: data.dec(_f$revenueByPaymentMethod),
      topSellingProducts: data.dec(_f$topSellingProducts),
      revenueByItemType: data.dec(_f$revenueByItemType),
      unpaidSalesCount: data.dec(_f$unpaidSalesCount),
      unpaidBalance: data.dec(_f$unpaidBalance),
      staffPerformance: data.dec(_f$staffPerformance),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SalesReport fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SalesReport>(map);
  }

  static SalesReport fromJson(String json) {
    return ensureInitialized().decodeJson<SalesReport>(json);
  }
}

mixin SalesReportMappable {
  String toJson() {
    return SalesReportMapper.ensureInitialized().encodeJson<SalesReport>(
      this as SalesReport,
    );
  }

  Map<String, dynamic> toMap() {
    return SalesReportMapper.ensureInitialized().encodeMap<SalesReport>(
      this as SalesReport,
    );
  }

  SalesReportCopyWith<SalesReport, SalesReport, SalesReport> get copyWith =>
      _SalesReportCopyWithImpl<SalesReport, SalesReport>(
        this as SalesReport,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SalesReportMapper.ensureInitialized().stringifyValue(
      this as SalesReport,
    );
  }

  @override
  bool operator ==(Object other) {
    return SalesReportMapper.ensureInitialized().equalsValue(
      this as SalesReport,
      other,
    );
  }

  @override
  int get hashCode {
    return SalesReportMapper.ensureInitialized().hashValue(this as SalesReport);
  }
}

extension SalesReportValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SalesReport, $Out> {
  SalesReportCopyWith<$R, SalesReport, $Out> get $asSalesReport =>
      $base.as((v, t, t2) => _SalesReportCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SalesReportCopyWith<$R, $In extends SalesReport, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    PeriodBucket,
    PeriodBucketCopyWith<$R, PeriodBucket, PeriodBucket>
  >
  get revenueTrend;
  MapCopyWith<$R, String, num, ObjectCopyWith<$R, num, num>>
  get revenueByPaymentMethod;
  ListCopyWith<
    $R,
    ProductSalesSummary,
    ProductSalesSummaryCopyWith<$R, ProductSalesSummary, ProductSalesSummary>
  >
  get topSellingProducts;
  MapCopyWith<$R, String, num, ObjectCopyWith<$R, num, num>>
  get revenueByItemType;
  ListCopyWith<
    $R,
    StaffSalesSummary,
    StaffSalesSummaryCopyWith<$R, StaffSalesSummary, StaffSalesSummary>
  >
  get staffPerformance;
  $R call({
    num? totalRevenue,
    int? transactionCount,
    num? averageTransactionValue,
    List<PeriodBucket>? revenueTrend,
    Map<String, num>? revenueByPaymentMethod,
    List<ProductSalesSummary>? topSellingProducts,
    Map<String, num>? revenueByItemType,
    int? unpaidSalesCount,
    num? unpaidBalance,
    List<StaffSalesSummary>? staffPerformance,
  });
  SalesReportCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _SalesReportCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SalesReport, $Out>
    implements SalesReportCopyWith<$R, SalesReport, $Out> {
  _SalesReportCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SalesReport> $mapper =
      SalesReportMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    PeriodBucket,
    PeriodBucketCopyWith<$R, PeriodBucket, PeriodBucket>
  >
  get revenueTrend => ListCopyWith(
    $value.revenueTrend,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(revenueTrend: v),
  );
  @override
  MapCopyWith<$R, String, num, ObjectCopyWith<$R, num, num>>
  get revenueByPaymentMethod => MapCopyWith(
    $value.revenueByPaymentMethod,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(revenueByPaymentMethod: v),
  );
  @override
  ListCopyWith<
    $R,
    ProductSalesSummary,
    ProductSalesSummaryCopyWith<$R, ProductSalesSummary, ProductSalesSummary>
  >
  get topSellingProducts => ListCopyWith(
    $value.topSellingProducts,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(topSellingProducts: v),
  );
  @override
  MapCopyWith<$R, String, num, ObjectCopyWith<$R, num, num>>
  get revenueByItemType => MapCopyWith(
    $value.revenueByItemType,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(revenueByItemType: v),
  );
  @override
  ListCopyWith<
    $R,
    StaffSalesSummary,
    StaffSalesSummaryCopyWith<$R, StaffSalesSummary, StaffSalesSummary>
  >
  get staffPerformance => ListCopyWith(
    $value.staffPerformance,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(staffPerformance: v),
  );
  @override
  $R call({
    num? totalRevenue,
    int? transactionCount,
    num? averageTransactionValue,
    List<PeriodBucket>? revenueTrend,
    Map<String, num>? revenueByPaymentMethod,
    List<ProductSalesSummary>? topSellingProducts,
    Map<String, num>? revenueByItemType,
    int? unpaidSalesCount,
    num? unpaidBalance,
    List<StaffSalesSummary>? staffPerformance,
  }) => $apply(
    FieldCopyWithData({
      if (totalRevenue != null) #totalRevenue: totalRevenue,
      if (transactionCount != null) #transactionCount: transactionCount,
      if (averageTransactionValue != null)
        #averageTransactionValue: averageTransactionValue,
      if (revenueTrend != null) #revenueTrend: revenueTrend,
      if (revenueByPaymentMethod != null)
        #revenueByPaymentMethod: revenueByPaymentMethod,
      if (topSellingProducts != null) #topSellingProducts: topSellingProducts,
      if (revenueByItemType != null) #revenueByItemType: revenueByItemType,
      if (unpaidSalesCount != null) #unpaidSalesCount: unpaidSalesCount,
      if (unpaidBalance != null) #unpaidBalance: unpaidBalance,
      if (staffPerformance != null) #staffPerformance: staffPerformance,
    }),
  );
  @override
  SalesReport $make(CopyWithData data) => SalesReport(
    totalRevenue: data.get(#totalRevenue, or: $value.totalRevenue),
    transactionCount: data.get(#transactionCount, or: $value.transactionCount),
    averageTransactionValue: data.get(
      #averageTransactionValue,
      or: $value.averageTransactionValue,
    ),
    revenueTrend: data.get(#revenueTrend, or: $value.revenueTrend),
    revenueByPaymentMethod: data.get(
      #revenueByPaymentMethod,
      or: $value.revenueByPaymentMethod,
    ),
    topSellingProducts: data.get(
      #topSellingProducts,
      or: $value.topSellingProducts,
    ),
    revenueByItemType: data.get(
      #revenueByItemType,
      or: $value.revenueByItemType,
    ),
    unpaidSalesCount: data.get(#unpaidSalesCount, or: $value.unpaidSalesCount),
    unpaidBalance: data.get(#unpaidBalance, or: $value.unpaidBalance),
    staffPerformance: data.get(#staffPerformance, or: $value.staffPerformance),
  );

  @override
  SalesReportCopyWith<$R2, SalesReport, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SalesReportCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ProductSalesSummaryMapper extends ClassMapperBase<ProductSalesSummary> {
  ProductSalesSummaryMapper._();

  static ProductSalesSummaryMapper? _instance;
  static ProductSalesSummaryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProductSalesSummaryMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ProductSalesSummary';

  static String _$productName(ProductSalesSummary v) => v.productName;
  static const Field<ProductSalesSummary, String> _f$productName = Field(
    'productName',
    _$productName,
  );
  static num _$quantity(ProductSalesSummary v) => v.quantity;
  static const Field<ProductSalesSummary, num> _f$quantity = Field(
    'quantity',
    _$quantity,
  );
  static num _$revenue(ProductSalesSummary v) => v.revenue;
  static const Field<ProductSalesSummary, num> _f$revenue = Field(
    'revenue',
    _$revenue,
  );

  @override
  final MappableFields<ProductSalesSummary> fields = const {
    #productName: _f$productName,
    #quantity: _f$quantity,
    #revenue: _f$revenue,
  };

  static ProductSalesSummary _instantiate(DecodingData data) {
    return ProductSalesSummary(
      productName: data.dec(_f$productName),
      quantity: data.dec(_f$quantity),
      revenue: data.dec(_f$revenue),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ProductSalesSummary fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ProductSalesSummary>(map);
  }

  static ProductSalesSummary fromJson(String json) {
    return ensureInitialized().decodeJson<ProductSalesSummary>(json);
  }
}

mixin ProductSalesSummaryMappable {
  String toJson() {
    return ProductSalesSummaryMapper.ensureInitialized()
        .encodeJson<ProductSalesSummary>(this as ProductSalesSummary);
  }

  Map<String, dynamic> toMap() {
    return ProductSalesSummaryMapper.ensureInitialized()
        .encodeMap<ProductSalesSummary>(this as ProductSalesSummary);
  }

  ProductSalesSummaryCopyWith<
    ProductSalesSummary,
    ProductSalesSummary,
    ProductSalesSummary
  >
  get copyWith =>
      _ProductSalesSummaryCopyWithImpl<
        ProductSalesSummary,
        ProductSalesSummary
      >(this as ProductSalesSummary, $identity, $identity);
  @override
  String toString() {
    return ProductSalesSummaryMapper.ensureInitialized().stringifyValue(
      this as ProductSalesSummary,
    );
  }

  @override
  bool operator ==(Object other) {
    return ProductSalesSummaryMapper.ensureInitialized().equalsValue(
      this as ProductSalesSummary,
      other,
    );
  }

  @override
  int get hashCode {
    return ProductSalesSummaryMapper.ensureInitialized().hashValue(
      this as ProductSalesSummary,
    );
  }
}

extension ProductSalesSummaryValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ProductSalesSummary, $Out> {
  ProductSalesSummaryCopyWith<$R, ProductSalesSummary, $Out>
  get $asProductSalesSummary => $base.as(
    (v, t, t2) => _ProductSalesSummaryCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ProductSalesSummaryCopyWith<
  $R,
  $In extends ProductSalesSummary,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? productName, num? quantity, num? revenue});
  ProductSalesSummaryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ProductSalesSummaryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ProductSalesSummary, $Out>
    implements ProductSalesSummaryCopyWith<$R, ProductSalesSummary, $Out> {
  _ProductSalesSummaryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ProductSalesSummary> $mapper =
      ProductSalesSummaryMapper.ensureInitialized();
  @override
  $R call({String? productName, num? quantity, num? revenue}) => $apply(
    FieldCopyWithData({
      if (productName != null) #productName: productName,
      if (quantity != null) #quantity: quantity,
      if (revenue != null) #revenue: revenue,
    }),
  );
  @override
  ProductSalesSummary $make(CopyWithData data) => ProductSalesSummary(
    productName: data.get(#productName, or: $value.productName),
    quantity: data.get(#quantity, or: $value.quantity),
    revenue: data.get(#revenue, or: $value.revenue),
  );

  @override
  ProductSalesSummaryCopyWith<$R2, ProductSalesSummary, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ProductSalesSummaryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class StaffSalesSummaryMapper extends ClassMapperBase<StaffSalesSummary> {
  StaffSalesSummaryMapper._();

  static StaffSalesSummaryMapper? _instance;
  static StaffSalesSummaryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = StaffSalesSummaryMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'StaffSalesSummary';

  static String _$staffId(StaffSalesSummary v) => v.staffId;
  static const Field<StaffSalesSummary, String> _f$staffId = Field(
    'staffId',
    _$staffId,
  );
  static String _$staffName(StaffSalesSummary v) => v.staffName;
  static const Field<StaffSalesSummary, String> _f$staffName = Field(
    'staffName',
    _$staffName,
  );
  static int _$transactionCount(StaffSalesSummary v) => v.transactionCount;
  static const Field<StaffSalesSummary, int> _f$transactionCount = Field(
    'transactionCount',
    _$transactionCount,
  );
  static num _$revenue(StaffSalesSummary v) => v.revenue;
  static const Field<StaffSalesSummary, num> _f$revenue = Field(
    'revenue',
    _$revenue,
  );

  @override
  final MappableFields<StaffSalesSummary> fields = const {
    #staffId: _f$staffId,
    #staffName: _f$staffName,
    #transactionCount: _f$transactionCount,
    #revenue: _f$revenue,
  };

  static StaffSalesSummary _instantiate(DecodingData data) {
    return StaffSalesSummary(
      staffId: data.dec(_f$staffId),
      staffName: data.dec(_f$staffName),
      transactionCount: data.dec(_f$transactionCount),
      revenue: data.dec(_f$revenue),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static StaffSalesSummary fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StaffSalesSummary>(map);
  }

  static StaffSalesSummary fromJson(String json) {
    return ensureInitialized().decodeJson<StaffSalesSummary>(json);
  }
}

mixin StaffSalesSummaryMappable {
  String toJson() {
    return StaffSalesSummaryMapper.ensureInitialized()
        .encodeJson<StaffSalesSummary>(this as StaffSalesSummary);
  }

  Map<String, dynamic> toMap() {
    return StaffSalesSummaryMapper.ensureInitialized()
        .encodeMap<StaffSalesSummary>(this as StaffSalesSummary);
  }

  StaffSalesSummaryCopyWith<
    StaffSalesSummary,
    StaffSalesSummary,
    StaffSalesSummary
  >
  get copyWith =>
      _StaffSalesSummaryCopyWithImpl<StaffSalesSummary, StaffSalesSummary>(
        this as StaffSalesSummary,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return StaffSalesSummaryMapper.ensureInitialized().stringifyValue(
      this as StaffSalesSummary,
    );
  }

  @override
  bool operator ==(Object other) {
    return StaffSalesSummaryMapper.ensureInitialized().equalsValue(
      this as StaffSalesSummary,
      other,
    );
  }

  @override
  int get hashCode {
    return StaffSalesSummaryMapper.ensureInitialized().hashValue(
      this as StaffSalesSummary,
    );
  }
}

extension StaffSalesSummaryValueCopy<$R, $Out>
    on ObjectCopyWith<$R, StaffSalesSummary, $Out> {
  StaffSalesSummaryCopyWith<$R, StaffSalesSummary, $Out>
  get $asStaffSalesSummary => $base.as(
    (v, t, t2) => _StaffSalesSummaryCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class StaffSalesSummaryCopyWith<
  $R,
  $In extends StaffSalesSummary,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? staffId,
    String? staffName,
    int? transactionCount,
    num? revenue,
  });
  StaffSalesSummaryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _StaffSalesSummaryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, StaffSalesSummary, $Out>
    implements StaffSalesSummaryCopyWith<$R, StaffSalesSummary, $Out> {
  _StaffSalesSummaryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<StaffSalesSummary> $mapper =
      StaffSalesSummaryMapper.ensureInitialized();
  @override
  $R call({
    String? staffId,
    String? staffName,
    int? transactionCount,
    num? revenue,
  }) => $apply(
    FieldCopyWithData({
      if (staffId != null) #staffId: staffId,
      if (staffName != null) #staffName: staffName,
      if (transactionCount != null) #transactionCount: transactionCount,
      if (revenue != null) #revenue: revenue,
    }),
  );
  @override
  StaffSalesSummary $make(CopyWithData data) => StaffSalesSummary(
    staffId: data.get(#staffId, or: $value.staffId),
    staffName: data.get(#staffName, or: $value.staffName),
    transactionCount: data.get(#transactionCount, or: $value.transactionCount),
    revenue: data.get(#revenue, or: $value.revenue),
  );

  @override
  StaffSalesSummaryCopyWith<$R2, StaffSalesSummary, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _StaffSalesSummaryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

