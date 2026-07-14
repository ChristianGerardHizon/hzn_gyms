// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'pos_group.dart';

class PosGroupMapper extends ClassMapperBase<PosGroup> {
  PosGroupMapper._();

  static PosGroupMapper? _instance;
  static PosGroupMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PosGroupMapper._());
      PosGroupItemMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PosGroup';

  static String _$id(PosGroup v) => v.id;
  static const Field<PosGroup, String> _f$id = Field(
    'id',
    _$id,
    opt: true,
    def: '',
  );
  static String _$name(PosGroup v) => v.name;
  static const Field<PosGroup, String> _f$name = Field('name', _$name);
  static String _$branchId(PosGroup v) => v.branchId;
  static const Field<PosGroup, String> _f$branchId = Field(
    'branchId',
    _$branchId,
  );
  static int _$sortOrder(PosGroup v) => v.sortOrder;
  static const Field<PosGroup, int> _f$sortOrder = Field(
    'sortOrder',
    _$sortOrder,
    opt: true,
    def: 0,
  );
  static bool _$isDeleted(PosGroup v) => v.isDeleted;
  static const Field<PosGroup, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static List<PosGroupItem> _$items(PosGroup v) => v.items;
  static const Field<PosGroup, List<PosGroupItem>> _f$items = Field(
    'items',
    _$items,
    opt: true,
    def: const [],
  );
  static DateTime? _$created(PosGroup v) => v.created;
  static const Field<PosGroup, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(PosGroup v) => v.updated;
  static const Field<PosGroup, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<PosGroup> fields = const {
    #id: _f$id,
    #name: _f$name,
    #branchId: _f$branchId,
    #sortOrder: _f$sortOrder,
    #isDeleted: _f$isDeleted,
    #items: _f$items,
    #created: _f$created,
    #updated: _f$updated,
  };

  static PosGroup _instantiate(DecodingData data) {
    return PosGroup(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      branchId: data.dec(_f$branchId),
      sortOrder: data.dec(_f$sortOrder),
      isDeleted: data.dec(_f$isDeleted),
      items: data.dec(_f$items),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PosGroup fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PosGroup>(map);
  }

  static PosGroup fromJson(String json) {
    return ensureInitialized().decodeJson<PosGroup>(json);
  }
}

mixin PosGroupMappable {
  String toJson() {
    return PosGroupMapper.ensureInitialized().encodeJson<PosGroup>(
      this as PosGroup,
    );
  }

  Map<String, dynamic> toMap() {
    return PosGroupMapper.ensureInitialized().encodeMap<PosGroup>(
      this as PosGroup,
    );
  }

  PosGroupCopyWith<PosGroup, PosGroup, PosGroup> get copyWith =>
      _PosGroupCopyWithImpl<PosGroup, PosGroup>(
        this as PosGroup,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PosGroupMapper.ensureInitialized().stringifyValue(this as PosGroup);
  }

  @override
  bool operator ==(Object other) {
    return PosGroupMapper.ensureInitialized().equalsValue(
      this as PosGroup,
      other,
    );
  }

  @override
  int get hashCode {
    return PosGroupMapper.ensureInitialized().hashValue(this as PosGroup);
  }
}

extension PosGroupValueCopy<$R, $Out> on ObjectCopyWith<$R, PosGroup, $Out> {
  PosGroupCopyWith<$R, PosGroup, $Out> get $asPosGroup =>
      $base.as((v, t, t2) => _PosGroupCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PosGroupCopyWith<$R, $In extends PosGroup, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    PosGroupItem,
    PosGroupItemCopyWith<$R, PosGroupItem, PosGroupItem>
  >
  get items;
  $R call({
    String? id,
    String? name,
    String? branchId,
    int? sortOrder,
    bool? isDeleted,
    List<PosGroupItem>? items,
    DateTime? created,
    DateTime? updated,
  });
  PosGroupCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PosGroupCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PosGroup, $Out>
    implements PosGroupCopyWith<$R, PosGroup, $Out> {
  _PosGroupCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PosGroup> $mapper =
      PosGroupMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    PosGroupItem,
    PosGroupItemCopyWith<$R, PosGroupItem, PosGroupItem>
  >
  get items => ListCopyWith(
    $value.items,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(items: v),
  );
  @override
  $R call({
    String? id,
    String? name,
    String? branchId,
    int? sortOrder,
    bool? isDeleted,
    List<PosGroupItem>? items,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (branchId != null) #branchId: branchId,
      if (sortOrder != null) #sortOrder: sortOrder,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (items != null) #items: items,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  PosGroup $make(CopyWithData data) => PosGroup(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    branchId: data.get(#branchId, or: $value.branchId),
    sortOrder: data.get(#sortOrder, or: $value.sortOrder),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    items: data.get(#items, or: $value.items),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  PosGroupCopyWith<$R2, PosGroup, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PosGroupCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

