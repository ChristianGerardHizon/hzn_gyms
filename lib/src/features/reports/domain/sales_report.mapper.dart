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
      DailyRevenueMapper.ensureInitialized();
      ProductSalesSummaryMapper.ensureInitialized();
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
  static List<DailyRevenue> _$revenueByDay(SalesReport v) => v.revenueByDay;
  static const Field<SalesReport, List<DailyRevenue>> _f$revenueByDay = Field(
    'revenueByDay',
    _$revenueByDay,
  );
  static Map<String, num> _$revenueByPaymentMethod(SalesReport v) =>
      v.revenueByPaymentMethod;
  static const Field<SalesReport, Map<String, num>> _f$revenueByPaymentMethod =
      Field('revenueByPaymentMethod', _$revenueByPaymentMethod);
  static List<ProductSalesSummary> _$topSellingProducts(SalesReport v) =>
      v.topSellingProducts;
  static const Field<SalesReport, List<ProductSalesSummary>>
  _f$topSellingProducts = Field('topSellingProducts', _$topSellingProducts);

  @override
  final MappableFields<SalesReport> fields = const {
    #totalRevenue: _f$totalRevenue,
    #transactionCount: _f$transactionCount,
    #averageTransactionValue: _f$averageTransactionValue,
    #revenueByDay: _f$revenueByDay,
    #revenueByPaymentMethod: _f$revenueByPaymentMethod,
    #topSellingProducts: _f$topSellingProducts,
  };

  static SalesReport _instantiate(DecodingData data) {
    return SalesReport(
      totalRevenue: data.dec(_f$totalRevenue),
      transactionCount: data.dec(_f$transactionCount),
      averageTransactionValue: data.dec(_f$averageTransactionValue),
      revenueByDay: data.dec(_f$revenueByDay),
      revenueByPaymentMethod: data.dec(_f$revenueByPaymentMethod),
      topSellingProducts: data.dec(_f$topSellingProducts),
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
    DailyRevenue,
    DailyRevenueCopyWith<$R, DailyRevenue, DailyRevenue>
  >
  get revenueByDay;
  MapCopyWith<$R, String, num, ObjectCopyWith<$R, num, num>>
  get revenueByPaymentMethod;
  ListCopyWith<
    $R,
    ProductSalesSummary,
    ProductSalesSummaryCopyWith<$R, ProductSalesSummary, ProductSalesSummary>
  >
  get topSellingProducts;
  $R call({
    num? totalRevenue,
    int? transactionCount,
    num? averageTransactionValue,
    List<DailyRevenue>? revenueByDay,
    Map<String, num>? revenueByPaymentMethod,
    List<ProductSalesSummary>? topSellingProducts,
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
    DailyRevenue,
    DailyRevenueCopyWith<$R, DailyRevenue, DailyRevenue>
  >
  get revenueByDay => ListCopyWith(
    $value.revenueByDay,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(revenueByDay: v),
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
  $R call({
    num? totalRevenue,
    int? transactionCount,
    num? averageTransactionValue,
    List<DailyRevenue>? revenueByDay,
    Map<String, num>? revenueByPaymentMethod,
    List<ProductSalesSummary>? topSellingProducts,
  }) => $apply(
    FieldCopyWithData({
      if (totalRevenue != null) #totalRevenue: totalRevenue,
      if (transactionCount != null) #transactionCount: transactionCount,
      if (averageTransactionValue != null)
        #averageTransactionValue: averageTransactionValue,
      if (revenueByDay != null) #revenueByDay: revenueByDay,
      if (revenueByPaymentMethod != null)
        #revenueByPaymentMethod: revenueByPaymentMethod,
      if (topSellingProducts != null) #topSellingProducts: topSellingProducts,
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
    revenueByDay: data.get(#revenueByDay, or: $value.revenueByDay),
    revenueByPaymentMethod: data.get(
      #revenueByPaymentMethod,
      or: $value.revenueByPaymentMethod,
    ),
    topSellingProducts: data.get(
      #topSellingProducts,
      or: $value.topSellingProducts,
    ),
  );

  @override
  SalesReportCopyWith<$R2, SalesReport, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SalesReportCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DailyRevenueMapper extends ClassMapperBase<DailyRevenue> {
  DailyRevenueMapper._();

  static DailyRevenueMapper? _instance;
  static DailyRevenueMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DailyRevenueMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DailyRevenue';

  static DateTime _$date(DailyRevenue v) => v.date;
  static const Field<DailyRevenue, DateTime> _f$date = Field('date', _$date);
  static num _$amount(DailyRevenue v) => v.amount;
  static const Field<DailyRevenue, num> _f$amount = Field('amount', _$amount);

  @override
  final MappableFields<DailyRevenue> fields = const {
    #date: _f$date,
    #amount: _f$amount,
  };

  static DailyRevenue _instantiate(DecodingData data) {
    return DailyRevenue(date: data.dec(_f$date), amount: data.dec(_f$amount));
  }

  @override
  final Function instantiate = _instantiate;

  static DailyRevenue fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DailyRevenue>(map);
  }

  static DailyRevenue fromJson(String json) {
    return ensureInitialized().decodeJson<DailyRevenue>(json);
  }
}

mixin DailyRevenueMappable {
  String toJson() {
    return DailyRevenueMapper.ensureInitialized().encodeJson<DailyRevenue>(
      this as DailyRevenue,
    );
  }

  Map<String, dynamic> toMap() {
    return DailyRevenueMapper.ensureInitialized().encodeMap<DailyRevenue>(
      this as DailyRevenue,
    );
  }

  DailyRevenueCopyWith<DailyRevenue, DailyRevenue, DailyRevenue> get copyWith =>
      _DailyRevenueCopyWithImpl<DailyRevenue, DailyRevenue>(
        this as DailyRevenue,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DailyRevenueMapper.ensureInitialized().stringifyValue(
      this as DailyRevenue,
    );
  }

  @override
  bool operator ==(Object other) {
    return DailyRevenueMapper.ensureInitialized().equalsValue(
      this as DailyRevenue,
      other,
    );
  }

  @override
  int get hashCode {
    return DailyRevenueMapper.ensureInitialized().hashValue(
      this as DailyRevenue,
    );
  }
}

extension DailyRevenueValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DailyRevenue, $Out> {
  DailyRevenueCopyWith<$R, DailyRevenue, $Out> get $asDailyRevenue =>
      $base.as((v, t, t2) => _DailyRevenueCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DailyRevenueCopyWith<$R, $In extends DailyRevenue, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({DateTime? date, num? amount});
  DailyRevenueCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DailyRevenueCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DailyRevenue, $Out>
    implements DailyRevenueCopyWith<$R, DailyRevenue, $Out> {
  _DailyRevenueCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DailyRevenue> $mapper =
      DailyRevenueMapper.ensureInitialized();
  @override
  $R call({DateTime? date, num? amount}) => $apply(
    FieldCopyWithData({
      if (date != null) #date: date,
      if (amount != null) #amount: amount,
    }),
  );
  @override
  DailyRevenue $make(CopyWithData data) => DailyRevenue(
    date: data.get(#date, or: $value.date),
    amount: data.get(#amount, or: $value.amount),
  );

  @override
  DailyRevenueCopyWith<$R2, DailyRevenue, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DailyRevenueCopyWithImpl<$R2, $Out2>($value, $cast, t);
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

