// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'inventory_alert.dart';

class InventoryAlertMapper extends ClassMapperBase<InventoryAlert> {
  InventoryAlertMapper._();

  static InventoryAlertMapper? _instance;
  static InventoryAlertMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InventoryAlertMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'InventoryAlert';

  static String _$productId(InventoryAlert v) => v.productId;
  static const Field<InventoryAlert, String> _f$productId = Field(
    'productId',
    _$productId,
  );
  static String _$productName(InventoryAlert v) => v.productName;
  static const Field<InventoryAlert, String> _f$productName = Field(
    'productName',
    _$productName,
  );
  static InventoryAlertType _$alertType(InventoryAlert v) => v.alertType;
  static const Field<InventoryAlert, InventoryAlertType> _f$alertType = Field(
    'alertType',
    _$alertType,
  );
  static bool _$isLotTracked(InventoryAlert v) => v.isLotTracked;
  static const Field<InventoryAlert, bool> _f$isLotTracked = Field(
    'isLotTracked',
    _$isLotTracked,
  );
  static String? _$lotId(InventoryAlert v) => v.lotId;
  static const Field<InventoryAlert, String> _f$lotId = Field(
    'lotId',
    _$lotId,
    opt: true,
  );
  static String? _$lotNumber(InventoryAlert v) => v.lotNumber;
  static const Field<InventoryAlert, String> _f$lotNumber = Field(
    'lotNumber',
    _$lotNumber,
    opt: true,
  );
  static num? _$currentQuantity(InventoryAlert v) => v.currentQuantity;
  static const Field<InventoryAlert, num> _f$currentQuantity = Field(
    'currentQuantity',
    _$currentQuantity,
    opt: true,
  );
  static num? _$threshold(InventoryAlert v) => v.threshold;
  static const Field<InventoryAlert, num> _f$threshold = Field(
    'threshold',
    _$threshold,
    opt: true,
  );
  static DateTime? _$expirationDate(InventoryAlert v) => v.expirationDate;
  static const Field<InventoryAlert, DateTime> _f$expirationDate = Field(
    'expirationDate',
    _$expirationDate,
    opt: true,
  );
  static int? _$daysUntilExpiration(InventoryAlert v) => v.daysUntilExpiration;
  static const Field<InventoryAlert, int> _f$daysUntilExpiration = Field(
    'daysUntilExpiration',
    _$daysUntilExpiration,
    opt: true,
  );

  @override
  final MappableFields<InventoryAlert> fields = const {
    #productId: _f$productId,
    #productName: _f$productName,
    #alertType: _f$alertType,
    #isLotTracked: _f$isLotTracked,
    #lotId: _f$lotId,
    #lotNumber: _f$lotNumber,
    #currentQuantity: _f$currentQuantity,
    #threshold: _f$threshold,
    #expirationDate: _f$expirationDate,
    #daysUntilExpiration: _f$daysUntilExpiration,
  };

  static InventoryAlert _instantiate(DecodingData data) {
    return InventoryAlert(
      productId: data.dec(_f$productId),
      productName: data.dec(_f$productName),
      alertType: data.dec(_f$alertType),
      isLotTracked: data.dec(_f$isLotTracked),
      lotId: data.dec(_f$lotId),
      lotNumber: data.dec(_f$lotNumber),
      currentQuantity: data.dec(_f$currentQuantity),
      threshold: data.dec(_f$threshold),
      expirationDate: data.dec(_f$expirationDate),
      daysUntilExpiration: data.dec(_f$daysUntilExpiration),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static InventoryAlert fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<InventoryAlert>(map);
  }

  static InventoryAlert fromJson(String json) {
    return ensureInitialized().decodeJson<InventoryAlert>(json);
  }
}

mixin InventoryAlertMappable {
  String toJson() {
    return InventoryAlertMapper.ensureInitialized().encodeJson<InventoryAlert>(
      this as InventoryAlert,
    );
  }

  Map<String, dynamic> toMap() {
    return InventoryAlertMapper.ensureInitialized().encodeMap<InventoryAlert>(
      this as InventoryAlert,
    );
  }

  InventoryAlertCopyWith<InventoryAlert, InventoryAlert, InventoryAlert>
  get copyWith => _InventoryAlertCopyWithImpl<InventoryAlert, InventoryAlert>(
    this as InventoryAlert,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return InventoryAlertMapper.ensureInitialized().stringifyValue(
      this as InventoryAlert,
    );
  }

  @override
  bool operator ==(Object other) {
    return InventoryAlertMapper.ensureInitialized().equalsValue(
      this as InventoryAlert,
      other,
    );
  }

  @override
  int get hashCode {
    return InventoryAlertMapper.ensureInitialized().hashValue(
      this as InventoryAlert,
    );
  }
}

extension InventoryAlertValueCopy<$R, $Out>
    on ObjectCopyWith<$R, InventoryAlert, $Out> {
  InventoryAlertCopyWith<$R, InventoryAlert, $Out> get $asInventoryAlert =>
      $base.as((v, t, t2) => _InventoryAlertCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class InventoryAlertCopyWith<$R, $In extends InventoryAlert, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? productId,
    String? productName,
    InventoryAlertType? alertType,
    bool? isLotTracked,
    String? lotId,
    String? lotNumber,
    num? currentQuantity,
    num? threshold,
    DateTime? expirationDate,
    int? daysUntilExpiration,
  });
  InventoryAlertCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _InventoryAlertCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, InventoryAlert, $Out>
    implements InventoryAlertCopyWith<$R, InventoryAlert, $Out> {
  _InventoryAlertCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<InventoryAlert> $mapper =
      InventoryAlertMapper.ensureInitialized();
  @override
  $R call({
    String? productId,
    String? productName,
    InventoryAlertType? alertType,
    bool? isLotTracked,
    Object? lotId = $none,
    Object? lotNumber = $none,
    Object? currentQuantity = $none,
    Object? threshold = $none,
    Object? expirationDate = $none,
    Object? daysUntilExpiration = $none,
  }) => $apply(
    FieldCopyWithData({
      if (productId != null) #productId: productId,
      if (productName != null) #productName: productName,
      if (alertType != null) #alertType: alertType,
      if (isLotTracked != null) #isLotTracked: isLotTracked,
      if (lotId != $none) #lotId: lotId,
      if (lotNumber != $none) #lotNumber: lotNumber,
      if (currentQuantity != $none) #currentQuantity: currentQuantity,
      if (threshold != $none) #threshold: threshold,
      if (expirationDate != $none) #expirationDate: expirationDate,
      if (daysUntilExpiration != $none)
        #daysUntilExpiration: daysUntilExpiration,
    }),
  );
  @override
  InventoryAlert $make(CopyWithData data) => InventoryAlert(
    productId: data.get(#productId, or: $value.productId),
    productName: data.get(#productName, or: $value.productName),
    alertType: data.get(#alertType, or: $value.alertType),
    isLotTracked: data.get(#isLotTracked, or: $value.isLotTracked),
    lotId: data.get(#lotId, or: $value.lotId),
    lotNumber: data.get(#lotNumber, or: $value.lotNumber),
    currentQuantity: data.get(#currentQuantity, or: $value.currentQuantity),
    threshold: data.get(#threshold, or: $value.threshold),
    expirationDate: data.get(#expirationDate, or: $value.expirationDate),
    daysUntilExpiration: data.get(
      #daysUntilExpiration,
      or: $value.daysUntilExpiration,
    ),
  );

  @override
  InventoryAlertCopyWith<$R2, InventoryAlert, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _InventoryAlertCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class InventoryAlertsSummaryMapper
    extends ClassMapperBase<InventoryAlertsSummary> {
  InventoryAlertsSummaryMapper._();

  static InventoryAlertsSummaryMapper? _instance;
  static InventoryAlertsSummaryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InventoryAlertsSummaryMapper._());
      InventoryAlertMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'InventoryAlertsSummary';

  static List<InventoryAlert> _$lowStockAlerts(InventoryAlertsSummary v) =>
      v.lowStockAlerts;
  static const Field<InventoryAlertsSummary, List<InventoryAlert>>
  _f$lowStockAlerts = Field(
    'lowStockAlerts',
    _$lowStockAlerts,
    opt: true,
    def: const [],
  );
  static List<InventoryAlert> _$nearExpirationAlerts(
    InventoryAlertsSummary v,
  ) => v.nearExpirationAlerts;
  static const Field<InventoryAlertsSummary, List<InventoryAlert>>
  _f$nearExpirationAlerts = Field(
    'nearExpirationAlerts',
    _$nearExpirationAlerts,
    opt: true,
    def: const [],
  );
  static List<InventoryAlert> _$expiredAlerts(InventoryAlertsSummary v) =>
      v.expiredAlerts;
  static const Field<InventoryAlertsSummary, List<InventoryAlert>>
  _f$expiredAlerts = Field(
    'expiredAlerts',
    _$expiredAlerts,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<InventoryAlertsSummary> fields = const {
    #lowStockAlerts: _f$lowStockAlerts,
    #nearExpirationAlerts: _f$nearExpirationAlerts,
    #expiredAlerts: _f$expiredAlerts,
  };

  static InventoryAlertsSummary _instantiate(DecodingData data) {
    return InventoryAlertsSummary(
      lowStockAlerts: data.dec(_f$lowStockAlerts),
      nearExpirationAlerts: data.dec(_f$nearExpirationAlerts),
      expiredAlerts: data.dec(_f$expiredAlerts),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static InventoryAlertsSummary fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<InventoryAlertsSummary>(map);
  }

  static InventoryAlertsSummary fromJson(String json) {
    return ensureInitialized().decodeJson<InventoryAlertsSummary>(json);
  }
}

mixin InventoryAlertsSummaryMappable {
  String toJson() {
    return InventoryAlertsSummaryMapper.ensureInitialized()
        .encodeJson<InventoryAlertsSummary>(this as InventoryAlertsSummary);
  }

  Map<String, dynamic> toMap() {
    return InventoryAlertsSummaryMapper.ensureInitialized()
        .encodeMap<InventoryAlertsSummary>(this as InventoryAlertsSummary);
  }

  InventoryAlertsSummaryCopyWith<
    InventoryAlertsSummary,
    InventoryAlertsSummary,
    InventoryAlertsSummary
  >
  get copyWith =>
      _InventoryAlertsSummaryCopyWithImpl<
        InventoryAlertsSummary,
        InventoryAlertsSummary
      >(this as InventoryAlertsSummary, $identity, $identity);
  @override
  String toString() {
    return InventoryAlertsSummaryMapper.ensureInitialized().stringifyValue(
      this as InventoryAlertsSummary,
    );
  }

  @override
  bool operator ==(Object other) {
    return InventoryAlertsSummaryMapper.ensureInitialized().equalsValue(
      this as InventoryAlertsSummary,
      other,
    );
  }

  @override
  int get hashCode {
    return InventoryAlertsSummaryMapper.ensureInitialized().hashValue(
      this as InventoryAlertsSummary,
    );
  }
}

extension InventoryAlertsSummaryValueCopy<$R, $Out>
    on ObjectCopyWith<$R, InventoryAlertsSummary, $Out> {
  InventoryAlertsSummaryCopyWith<$R, InventoryAlertsSummary, $Out>
  get $asInventoryAlertsSummary => $base.as(
    (v, t, t2) => _InventoryAlertsSummaryCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class InventoryAlertsSummaryCopyWith<
  $R,
  $In extends InventoryAlertsSummary,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    InventoryAlert,
    InventoryAlertCopyWith<$R, InventoryAlert, InventoryAlert>
  >
  get lowStockAlerts;
  ListCopyWith<
    $R,
    InventoryAlert,
    InventoryAlertCopyWith<$R, InventoryAlert, InventoryAlert>
  >
  get nearExpirationAlerts;
  ListCopyWith<
    $R,
    InventoryAlert,
    InventoryAlertCopyWith<$R, InventoryAlert, InventoryAlert>
  >
  get expiredAlerts;
  $R call({
    List<InventoryAlert>? lowStockAlerts,
    List<InventoryAlert>? nearExpirationAlerts,
    List<InventoryAlert>? expiredAlerts,
  });
  InventoryAlertsSummaryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _InventoryAlertsSummaryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, InventoryAlertsSummary, $Out>
    implements
        InventoryAlertsSummaryCopyWith<$R, InventoryAlertsSummary, $Out> {
  _InventoryAlertsSummaryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<InventoryAlertsSummary> $mapper =
      InventoryAlertsSummaryMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    InventoryAlert,
    InventoryAlertCopyWith<$R, InventoryAlert, InventoryAlert>
  >
  get lowStockAlerts => ListCopyWith(
    $value.lowStockAlerts,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(lowStockAlerts: v),
  );
  @override
  ListCopyWith<
    $R,
    InventoryAlert,
    InventoryAlertCopyWith<$R, InventoryAlert, InventoryAlert>
  >
  get nearExpirationAlerts => ListCopyWith(
    $value.nearExpirationAlerts,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(nearExpirationAlerts: v),
  );
  @override
  ListCopyWith<
    $R,
    InventoryAlert,
    InventoryAlertCopyWith<$R, InventoryAlert, InventoryAlert>
  >
  get expiredAlerts => ListCopyWith(
    $value.expiredAlerts,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(expiredAlerts: v),
  );
  @override
  $R call({
    List<InventoryAlert>? lowStockAlerts,
    List<InventoryAlert>? nearExpirationAlerts,
    List<InventoryAlert>? expiredAlerts,
  }) => $apply(
    FieldCopyWithData({
      if (lowStockAlerts != null) #lowStockAlerts: lowStockAlerts,
      if (nearExpirationAlerts != null)
        #nearExpirationAlerts: nearExpirationAlerts,
      if (expiredAlerts != null) #expiredAlerts: expiredAlerts,
    }),
  );
  @override
  InventoryAlertsSummary $make(CopyWithData data) => InventoryAlertsSummary(
    lowStockAlerts: data.get(#lowStockAlerts, or: $value.lowStockAlerts),
    nearExpirationAlerts: data.get(
      #nearExpirationAlerts,
      or: $value.nearExpirationAlerts,
    ),
    expiredAlerts: data.get(#expiredAlerts, or: $value.expiredAlerts),
  );

  @override
  InventoryAlertsSummaryCopyWith<$R2, InventoryAlertsSummary, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _InventoryAlertsSummaryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

