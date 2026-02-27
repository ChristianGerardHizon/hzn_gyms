// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'sale_dto.dart';

class SaleDtoMapper extends ClassMapperBase<SaleDto> {
  SaleDtoMapper._();

  static SaleDtoMapper? _instance;
  static SaleDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SaleDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'SaleDto';

  static String _$id(SaleDto v) => v.id;
  static const Field<SaleDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(SaleDto v) => v.collectionId;
  static const Field<SaleDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(SaleDto v) => v.collectionName;
  static const Field<SaleDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$receiptNumber(SaleDto v) => v.receiptNumber;
  static const Field<SaleDto, String> _f$receiptNumber = Field(
    'receiptNumber',
    _$receiptNumber,
  );
  static String _$branch(SaleDto v) => v.branch;
  static const Field<SaleDto, String> _f$branch = Field('branch', _$branch);
  static String _$cashier(SaleDto v) => v.cashier;
  static const Field<SaleDto, String> _f$cashier = Field('cashier', _$cashier);
  static num _$totalAmount(SaleDto v) => v.totalAmount;
  static const Field<SaleDto, num> _f$totalAmount = Field(
    'totalAmount',
    _$totalAmount,
  );
  static String _$status(SaleDto v) => v.status;
  static const Field<SaleDto, String> _f$status = Field('status', _$status);
  static bool _$isPaid(SaleDto v) => v.isPaid;
  static const Field<SaleDto, bool> _f$isPaid = Field(
    'isPaid',
    _$isPaid,
    opt: true,
    def: false,
  );
  static String? _$customer(SaleDto v) => v.customer;
  static const Field<SaleDto, String> _f$customer = Field(
    'customer',
    _$customer,
    opt: true,
  );
  static String? _$customerName(SaleDto v) => v.customerName;
  static const Field<SaleDto, String> _f$customerName = Field(
    'customerName',
    _$customerName,
    opt: true,
  );
  static String? _$notes(SaleDto v) => v.notes;
  static const Field<SaleDto, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static String? _$voidedBy(SaleDto v) => v.voidedBy;
  static const Field<SaleDto, String> _f$voidedBy = Field(
    'voidedBy',
    _$voidedBy,
    opt: true,
  );
  static String? _$created(SaleDto v) => v.created;
  static const Field<SaleDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(SaleDto v) => v.updated;
  static const Field<SaleDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<SaleDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #receiptNumber: _f$receiptNumber,
    #branch: _f$branch,
    #cashier: _f$cashier,
    #totalAmount: _f$totalAmount,
    #status: _f$status,
    #isPaid: _f$isPaid,
    #customer: _f$customer,
    #customerName: _f$customerName,
    #notes: _f$notes,
    #voidedBy: _f$voidedBy,
    #created: _f$created,
    #updated: _f$updated,
  };

  static SaleDto _instantiate(DecodingData data) {
    return SaleDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      receiptNumber: data.dec(_f$receiptNumber),
      branch: data.dec(_f$branch),
      cashier: data.dec(_f$cashier),
      totalAmount: data.dec(_f$totalAmount),
      status: data.dec(_f$status),
      isPaid: data.dec(_f$isPaid),
      customer: data.dec(_f$customer),
      customerName: data.dec(_f$customerName),
      notes: data.dec(_f$notes),
      voidedBy: data.dec(_f$voidedBy),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SaleDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SaleDto>(map);
  }

  static SaleDto fromJson(String json) {
    return ensureInitialized().decodeJson<SaleDto>(json);
  }
}

mixin SaleDtoMappable {
  String toJson() {
    return SaleDtoMapper.ensureInitialized().encodeJson<SaleDto>(
      this as SaleDto,
    );
  }

  Map<String, dynamic> toMap() {
    return SaleDtoMapper.ensureInitialized().encodeMap<SaleDto>(
      this as SaleDto,
    );
  }

  SaleDtoCopyWith<SaleDto, SaleDto, SaleDto> get copyWith =>
      _SaleDtoCopyWithImpl<SaleDto, SaleDto>(
        this as SaleDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SaleDtoMapper.ensureInitialized().stringifyValue(this as SaleDto);
  }

  @override
  bool operator ==(Object other) {
    return SaleDtoMapper.ensureInitialized().equalsValue(
      this as SaleDto,
      other,
    );
  }

  @override
  int get hashCode {
    return SaleDtoMapper.ensureInitialized().hashValue(this as SaleDto);
  }
}

extension SaleDtoValueCopy<$R, $Out> on ObjectCopyWith<$R, SaleDto, $Out> {
  SaleDtoCopyWith<$R, SaleDto, $Out> get $asSaleDto =>
      $base.as((v, t, t2) => _SaleDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SaleDtoCopyWith<$R, $In extends SaleDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? receiptNumber,
    String? branch,
    String? cashier,
    num? totalAmount,
    String? status,
    bool? isPaid,
    String? customer,
    String? customerName,
    String? notes,
    String? voidedBy,
    String? created,
    String? updated,
  });
  SaleDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _SaleDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SaleDto, $Out>
    implements SaleDtoCopyWith<$R, SaleDto, $Out> {
  _SaleDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SaleDto> $mapper =
      SaleDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? receiptNumber,
    String? branch,
    String? cashier,
    num? totalAmount,
    String? status,
    bool? isPaid,
    Object? customer = $none,
    Object? customerName = $none,
    Object? notes = $none,
    Object? voidedBy = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (receiptNumber != null) #receiptNumber: receiptNumber,
      if (branch != null) #branch: branch,
      if (cashier != null) #cashier: cashier,
      if (totalAmount != null) #totalAmount: totalAmount,
      if (status != null) #status: status,
      if (isPaid != null) #isPaid: isPaid,
      if (customer != $none) #customer: customer,
      if (customerName != $none) #customerName: customerName,
      if (notes != $none) #notes: notes,
      if (voidedBy != $none) #voidedBy: voidedBy,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  SaleDto $make(CopyWithData data) => SaleDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    receiptNumber: data.get(#receiptNumber, or: $value.receiptNumber),
    branch: data.get(#branch, or: $value.branch),
    cashier: data.get(#cashier, or: $value.cashier),
    totalAmount: data.get(#totalAmount, or: $value.totalAmount),
    status: data.get(#status, or: $value.status),
    isPaid: data.get(#isPaid, or: $value.isPaid),
    customer: data.get(#customer, or: $value.customer),
    customerName: data.get(#customerName, or: $value.customerName),
    notes: data.get(#notes, or: $value.notes),
    voidedBy: data.get(#voidedBy, or: $value.voidedBy),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  SaleDtoCopyWith<$R2, SaleDto, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _SaleDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

