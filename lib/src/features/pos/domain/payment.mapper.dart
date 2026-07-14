// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'payment.dart';

class PaymentMapper extends ClassMapperBase<Payment> {
  PaymentMapper._();

  static PaymentMapper? _instance;
  static PaymentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PaymentMapper._());
      PaymentMethodMapper.ensureInitialized();
      PaymentTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Payment';

  static String _$id(Payment v) => v.id;
  static const Field<Payment, String> _f$id = Field('id', _$id);
  static String _$saleId(Payment v) => v.saleId;
  static const Field<Payment, String> _f$saleId = Field('saleId', _$saleId);
  static num _$amount(Payment v) => v.amount;
  static const Field<Payment, num> _f$amount = Field('amount', _$amount);
  static PaymentMethod _$paymentMethod(Payment v) => v.paymentMethod;
  static const Field<Payment, PaymentMethod> _f$paymentMethod = Field(
    'paymentMethod',
    _$paymentMethod,
  );
  static PaymentType _$type(Payment v) => v.type;
  static const Field<Payment, PaymentType> _f$type = Field('type', _$type);
  static String? _$paymentRef(Payment v) => v.paymentRef;
  static const Field<Payment, String> _f$paymentRef = Field(
    'paymentRef',
    _$paymentRef,
    opt: true,
  );
  static String? _$paymentProofUrl(Payment v) => v.paymentProofUrl;
  static const Field<Payment, String> _f$paymentProofUrl = Field(
    'paymentProofUrl',
    _$paymentProofUrl,
    opt: true,
  );
  static String? _$notes(Payment v) => v.notes;
  static const Field<Payment, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static DateTime? _$created(Payment v) => v.created;
  static const Field<Payment, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(Payment v) => v.updated;
  static const Field<Payment, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<Payment> fields = const {
    #id: _f$id,
    #saleId: _f$saleId,
    #amount: _f$amount,
    #paymentMethod: _f$paymentMethod,
    #type: _f$type,
    #paymentRef: _f$paymentRef,
    #paymentProofUrl: _f$paymentProofUrl,
    #notes: _f$notes,
    #created: _f$created,
    #updated: _f$updated,
  };

  static Payment _instantiate(DecodingData data) {
    return Payment(
      id: data.dec(_f$id),
      saleId: data.dec(_f$saleId),
      amount: data.dec(_f$amount),
      paymentMethod: data.dec(_f$paymentMethod),
      type: data.dec(_f$type),
      paymentRef: data.dec(_f$paymentRef),
      paymentProofUrl: data.dec(_f$paymentProofUrl),
      notes: data.dec(_f$notes),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Payment fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Payment>(map);
  }

  static Payment fromJson(String json) {
    return ensureInitialized().decodeJson<Payment>(json);
  }
}

mixin PaymentMappable {
  String toJson() {
    return PaymentMapper.ensureInitialized().encodeJson<Payment>(
      this as Payment,
    );
  }

  Map<String, dynamic> toMap() {
    return PaymentMapper.ensureInitialized().encodeMap<Payment>(
      this as Payment,
    );
  }

  PaymentCopyWith<Payment, Payment, Payment> get copyWith =>
      _PaymentCopyWithImpl<Payment, Payment>(
        this as Payment,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PaymentMapper.ensureInitialized().stringifyValue(this as Payment);
  }

  @override
  bool operator ==(Object other) {
    return PaymentMapper.ensureInitialized().equalsValue(
      this as Payment,
      other,
    );
  }

  @override
  int get hashCode {
    return PaymentMapper.ensureInitialized().hashValue(this as Payment);
  }
}

extension PaymentValueCopy<$R, $Out> on ObjectCopyWith<$R, Payment, $Out> {
  PaymentCopyWith<$R, Payment, $Out> get $asPayment =>
      $base.as((v, t, t2) => _PaymentCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PaymentCopyWith<$R, $In extends Payment, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? saleId,
    num? amount,
    PaymentMethod? paymentMethod,
    PaymentType? type,
    String? paymentRef,
    String? paymentProofUrl,
    String? notes,
    DateTime? created,
    DateTime? updated,
  });
  PaymentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PaymentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Payment, $Out>
    implements PaymentCopyWith<$R, Payment, $Out> {
  _PaymentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Payment> $mapper =
      PaymentMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? saleId,
    num? amount,
    PaymentMethod? paymentMethod,
    PaymentType? type,
    Object? paymentRef = $none,
    Object? paymentProofUrl = $none,
    Object? notes = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (saleId != null) #saleId: saleId,
      if (amount != null) #amount: amount,
      if (paymentMethod != null) #paymentMethod: paymentMethod,
      if (type != null) #type: type,
      if (paymentRef != $none) #paymentRef: paymentRef,
      if (paymentProofUrl != $none) #paymentProofUrl: paymentProofUrl,
      if (notes != $none) #notes: notes,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  Payment $make(CopyWithData data) => Payment(
    id: data.get(#id, or: $value.id),
    saleId: data.get(#saleId, or: $value.saleId),
    amount: data.get(#amount, or: $value.amount),
    paymentMethod: data.get(#paymentMethod, or: $value.paymentMethod),
    type: data.get(#type, or: $value.type),
    paymentRef: data.get(#paymentRef, or: $value.paymentRef),
    paymentProofUrl: data.get(#paymentProofUrl, or: $value.paymentProofUrl),
    notes: data.get(#notes, or: $value.notes),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  PaymentCopyWith<$R2, Payment, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _PaymentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

