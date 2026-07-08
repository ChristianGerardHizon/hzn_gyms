// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'payment_dto.dart';

class PaymentDtoMapper extends ClassMapperBase<PaymentDto> {
  PaymentDtoMapper._();

  static PaymentDtoMapper? _instance;
  static PaymentDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PaymentDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PaymentDto';

  static String _$id(PaymentDto v) => v.id;
  static const Field<PaymentDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(PaymentDto v) => v.collectionId;
  static const Field<PaymentDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(PaymentDto v) => v.collectionName;
  static const Field<PaymentDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$sale(PaymentDto v) => v.sale;
  static const Field<PaymentDto, String> _f$sale = Field('sale', _$sale);
  static num _$amount(PaymentDto v) => v.amount;
  static const Field<PaymentDto, num> _f$amount = Field('amount', _$amount);
  static String _$paymentMethod(PaymentDto v) => v.paymentMethod;
  static const Field<PaymentDto, String> _f$paymentMethod = Field(
    'paymentMethod',
    _$paymentMethod,
  );
  static String _$type(PaymentDto v) => v.type;
  static const Field<PaymentDto, String> _f$type = Field('type', _$type);
  static String? _$paymentRef(PaymentDto v) => v.paymentRef;
  static const Field<PaymentDto, String> _f$paymentRef = Field(
    'paymentRef',
    _$paymentRef,
    opt: true,
  );
  static String? _$paymentProof(PaymentDto v) => v.paymentProof;
  static const Field<PaymentDto, String> _f$paymentProof = Field(
    'paymentProof',
    _$paymentProof,
    opt: true,
  );
  static String? _$notes(PaymentDto v) => v.notes;
  static const Field<PaymentDto, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static String? _$created(PaymentDto v) => v.created;
  static const Field<PaymentDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(PaymentDto v) => v.updated;
  static const Field<PaymentDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<PaymentDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #sale: _f$sale,
    #amount: _f$amount,
    #paymentMethod: _f$paymentMethod,
    #type: _f$type,
    #paymentRef: _f$paymentRef,
    #paymentProof: _f$paymentProof,
    #notes: _f$notes,
    #created: _f$created,
    #updated: _f$updated,
  };

  static PaymentDto _instantiate(DecodingData data) {
    return PaymentDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      sale: data.dec(_f$sale),
      amount: data.dec(_f$amount),
      paymentMethod: data.dec(_f$paymentMethod),
      type: data.dec(_f$type),
      paymentRef: data.dec(_f$paymentRef),
      paymentProof: data.dec(_f$paymentProof),
      notes: data.dec(_f$notes),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PaymentDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PaymentDto>(map);
  }

  static PaymentDto fromJson(String json) {
    return ensureInitialized().decodeJson<PaymentDto>(json);
  }
}

mixin PaymentDtoMappable {
  String toJson() {
    return PaymentDtoMapper.ensureInitialized().encodeJson<PaymentDto>(
      this as PaymentDto,
    );
  }

  Map<String, dynamic> toMap() {
    return PaymentDtoMapper.ensureInitialized().encodeMap<PaymentDto>(
      this as PaymentDto,
    );
  }

  PaymentDtoCopyWith<PaymentDto, PaymentDto, PaymentDto> get copyWith =>
      _PaymentDtoCopyWithImpl<PaymentDto, PaymentDto>(
        this as PaymentDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PaymentDtoMapper.ensureInitialized().stringifyValue(
      this as PaymentDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return PaymentDtoMapper.ensureInitialized().equalsValue(
      this as PaymentDto,
      other,
    );
  }

  @override
  int get hashCode {
    return PaymentDtoMapper.ensureInitialized().hashValue(this as PaymentDto);
  }
}

extension PaymentDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PaymentDto, $Out> {
  PaymentDtoCopyWith<$R, PaymentDto, $Out> get $asPaymentDto =>
      $base.as((v, t, t2) => _PaymentDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PaymentDtoCopyWith<$R, $In extends PaymentDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? sale,
    num? amount,
    String? paymentMethod,
    String? type,
    String? paymentRef,
    String? paymentProof,
    String? notes,
    String? created,
    String? updated,
  });
  PaymentDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PaymentDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PaymentDto, $Out>
    implements PaymentDtoCopyWith<$R, PaymentDto, $Out> {
  _PaymentDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PaymentDto> $mapper =
      PaymentDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? sale,
    num? amount,
    String? paymentMethod,
    String? type,
    Object? paymentRef = $none,
    Object? paymentProof = $none,
    Object? notes = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (sale != null) #sale: sale,
      if (amount != null) #amount: amount,
      if (paymentMethod != null) #paymentMethod: paymentMethod,
      if (type != null) #type: type,
      if (paymentRef != $none) #paymentRef: paymentRef,
      if (paymentProof != $none) #paymentProof: paymentProof,
      if (notes != $none) #notes: notes,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  PaymentDto $make(CopyWithData data) => PaymentDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    sale: data.get(#sale, or: $value.sale),
    amount: data.get(#amount, or: $value.amount),
    paymentMethod: data.get(#paymentMethod, or: $value.paymentMethod),
    type: data.get(#type, or: $value.type),
    paymentRef: data.get(#paymentRef, or: $value.paymentRef),
    paymentProof: data.get(#paymentProof, or: $value.paymentProof),
    notes: data.get(#notes, or: $value.notes),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  PaymentDtoCopyWith<$R2, PaymentDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PaymentDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

