// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'pos_group_item_dto.dart';

class PosGroupItemDtoMapper extends ClassMapperBase<PosGroupItemDto> {
  PosGroupItemDtoMapper._();

  static PosGroupItemDtoMapper? _instance;
  static PosGroupItemDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PosGroupItemDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PosGroupItemDto';

  static String _$id(PosGroupItemDto v) => v.id;
  static const Field<PosGroupItemDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(PosGroupItemDto v) => v.collectionId;
  static const Field<PosGroupItemDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(PosGroupItemDto v) => v.collectionName;
  static const Field<PosGroupItemDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$group(PosGroupItemDto v) => v.group;
  static const Field<PosGroupItemDto, String> _f$group = Field(
    'group',
    _$group,
  );
  static String? _$product(PosGroupItemDto v) => v.product;
  static const Field<PosGroupItemDto, String> _f$product = Field(
    'product',
    _$product,
    opt: true,
  );
  static int _$sortOrder(PosGroupItemDto v) => v.sortOrder;
  static const Field<PosGroupItemDto, int> _f$sortOrder = Field(
    'sortOrder',
    _$sortOrder,
    opt: true,
    def: 0,
  );
  static String? _$created(PosGroupItemDto v) => v.created;
  static const Field<PosGroupItemDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(PosGroupItemDto v) => v.updated;
  static const Field<PosGroupItemDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<PosGroupItemDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #group: _f$group,
    #product: _f$product,
    #sortOrder: _f$sortOrder,
    #created: _f$created,
    #updated: _f$updated,
  };

  static PosGroupItemDto _instantiate(DecodingData data) {
    return PosGroupItemDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      group: data.dec(_f$group),
      product: data.dec(_f$product),
      sortOrder: data.dec(_f$sortOrder),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PosGroupItemDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PosGroupItemDto>(map);
  }

  static PosGroupItemDto fromJson(String json) {
    return ensureInitialized().decodeJson<PosGroupItemDto>(json);
  }
}

mixin PosGroupItemDtoMappable {
  String toJson() {
    return PosGroupItemDtoMapper.ensureInitialized()
        .encodeJson<PosGroupItemDto>(this as PosGroupItemDto);
  }

  Map<String, dynamic> toMap() {
    return PosGroupItemDtoMapper.ensureInitialized().encodeMap<PosGroupItemDto>(
      this as PosGroupItemDto,
    );
  }

  PosGroupItemDtoCopyWith<PosGroupItemDto, PosGroupItemDto, PosGroupItemDto>
  get copyWith =>
      _PosGroupItemDtoCopyWithImpl<PosGroupItemDto, PosGroupItemDto>(
        this as PosGroupItemDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PosGroupItemDtoMapper.ensureInitialized().stringifyValue(
      this as PosGroupItemDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return PosGroupItemDtoMapper.ensureInitialized().equalsValue(
      this as PosGroupItemDto,
      other,
    );
  }

  @override
  int get hashCode {
    return PosGroupItemDtoMapper.ensureInitialized().hashValue(
      this as PosGroupItemDto,
    );
  }
}

extension PosGroupItemDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PosGroupItemDto, $Out> {
  PosGroupItemDtoCopyWith<$R, PosGroupItemDto, $Out> get $asPosGroupItemDto =>
      $base.as((v, t, t2) => _PosGroupItemDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PosGroupItemDtoCopyWith<$R, $In extends PosGroupItemDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? group,
    String? product,
    int? sortOrder,
    String? created,
    String? updated,
  });
  PosGroupItemDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _PosGroupItemDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PosGroupItemDto, $Out>
    implements PosGroupItemDtoCopyWith<$R, PosGroupItemDto, $Out> {
  _PosGroupItemDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PosGroupItemDto> $mapper =
      PosGroupItemDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? group,
    Object? product = $none,
    int? sortOrder,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (group != null) #group: group,
      if (product != $none) #product: product,
      if (sortOrder != null) #sortOrder: sortOrder,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  PosGroupItemDto $make(CopyWithData data) => PosGroupItemDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    group: data.get(#group, or: $value.group),
    product: data.get(#product, or: $value.product),
    sortOrder: data.get(#sortOrder, or: $value.sortOrder),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  PosGroupItemDtoCopyWith<$R2, PosGroupItemDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PosGroupItemDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

