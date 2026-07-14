// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'printer_config_dto.dart';

class PrinterConfigDtoMapper extends ClassMapperBase<PrinterConfigDto> {
  PrinterConfigDtoMapper._();

  static PrinterConfigDtoMapper? _instance;
  static PrinterConfigDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PrinterConfigDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PrinterConfigDto';

  static String _$id(PrinterConfigDto v) => v.id;
  static const Field<PrinterConfigDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(PrinterConfigDto v) => v.collectionId;
  static const Field<PrinterConfigDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(PrinterConfigDto v) => v.collectionName;
  static const Field<PrinterConfigDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(PrinterConfigDto v) => v.name;
  static const Field<PrinterConfigDto, String> _f$name = Field('name', _$name);
  static String _$connectionType(PrinterConfigDto v) => v.connectionType;
  static const Field<PrinterConfigDto, String> _f$connectionType = Field(
    'connectionType',
    _$connectionType,
  );
  static String? _$address(PrinterConfigDto v) => v.address;
  static const Field<PrinterConfigDto, String> _f$address = Field(
    'address',
    _$address,
    opt: true,
  );
  static int _$port(PrinterConfigDto v) => v.port;
  static const Field<PrinterConfigDto, int> _f$port = Field(
    'port',
    _$port,
    opt: true,
    def: 9100,
  );
  static String _$paperWidth(PrinterConfigDto v) => v.paperWidth;
  static const Field<PrinterConfigDto, String> _f$paperWidth = Field(
    'paperWidth',
    _$paperWidth,
    opt: true,
    def: 'mm80',
  );
  static bool _$isDefault(PrinterConfigDto v) => v.isDefault;
  static const Field<PrinterConfigDto, bool> _f$isDefault = Field(
    'isDefault',
    _$isDefault,
    opt: true,
    def: false,
  );
  static bool _$isEnabled(PrinterConfigDto v) => v.isEnabled;
  static const Field<PrinterConfigDto, bool> _f$isEnabled = Field(
    'isEnabled',
    _$isEnabled,
    opt: true,
    def: true,
  );
  static String? _$branch(PrinterConfigDto v) => v.branch;
  static const Field<PrinterConfigDto, String> _f$branch = Field(
    'branch',
    _$branch,
    opt: true,
  );
  static bool _$isDeleted(PrinterConfigDto v) => v.isDeleted;
  static const Field<PrinterConfigDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(PrinterConfigDto v) => v.created;
  static const Field<PrinterConfigDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(PrinterConfigDto v) => v.updated;
  static const Field<PrinterConfigDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<PrinterConfigDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #connectionType: _f$connectionType,
    #address: _f$address,
    #port: _f$port,
    #paperWidth: _f$paperWidth,
    #isDefault: _f$isDefault,
    #isEnabled: _f$isEnabled,
    #branch: _f$branch,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static PrinterConfigDto _instantiate(DecodingData data) {
    return PrinterConfigDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      name: data.dec(_f$name),
      connectionType: data.dec(_f$connectionType),
      address: data.dec(_f$address),
      port: data.dec(_f$port),
      paperWidth: data.dec(_f$paperWidth),
      isDefault: data.dec(_f$isDefault),
      isEnabled: data.dec(_f$isEnabled),
      branch: data.dec(_f$branch),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PrinterConfigDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PrinterConfigDto>(map);
  }

  static PrinterConfigDto fromJson(String json) {
    return ensureInitialized().decodeJson<PrinterConfigDto>(json);
  }
}

mixin PrinterConfigDtoMappable {
  String toJson() {
    return PrinterConfigDtoMapper.ensureInitialized()
        .encodeJson<PrinterConfigDto>(this as PrinterConfigDto);
  }

  Map<String, dynamic> toMap() {
    return PrinterConfigDtoMapper.ensureInitialized()
        .encodeMap<PrinterConfigDto>(this as PrinterConfigDto);
  }

  PrinterConfigDtoCopyWith<PrinterConfigDto, PrinterConfigDto, PrinterConfigDto>
  get copyWith =>
      _PrinterConfigDtoCopyWithImpl<PrinterConfigDto, PrinterConfigDto>(
        this as PrinterConfigDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PrinterConfigDtoMapper.ensureInitialized().stringifyValue(
      this as PrinterConfigDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return PrinterConfigDtoMapper.ensureInitialized().equalsValue(
      this as PrinterConfigDto,
      other,
    );
  }

  @override
  int get hashCode {
    return PrinterConfigDtoMapper.ensureInitialized().hashValue(
      this as PrinterConfigDto,
    );
  }
}

extension PrinterConfigDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PrinterConfigDto, $Out> {
  PrinterConfigDtoCopyWith<$R, PrinterConfigDto, $Out>
  get $asPrinterConfigDto =>
      $base.as((v, t, t2) => _PrinterConfigDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PrinterConfigDtoCopyWith<$R, $In extends PrinterConfigDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? connectionType,
    String? address,
    int? port,
    String? paperWidth,
    bool? isDefault,
    bool? isEnabled,
    String? branch,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  PrinterConfigDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _PrinterConfigDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PrinterConfigDto, $Out>
    implements PrinterConfigDtoCopyWith<$R, PrinterConfigDto, $Out> {
  _PrinterConfigDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PrinterConfigDto> $mapper =
      PrinterConfigDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? connectionType,
    Object? address = $none,
    int? port,
    String? paperWidth,
    bool? isDefault,
    bool? isEnabled,
    Object? branch = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (name != null) #name: name,
      if (connectionType != null) #connectionType: connectionType,
      if (address != $none) #address: address,
      if (port != null) #port: port,
      if (paperWidth != null) #paperWidth: paperWidth,
      if (isDefault != null) #isDefault: isDefault,
      if (isEnabled != null) #isEnabled: isEnabled,
      if (branch != $none) #branch: branch,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  PrinterConfigDto $make(CopyWithData data) => PrinterConfigDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    name: data.get(#name, or: $value.name),
    connectionType: data.get(#connectionType, or: $value.connectionType),
    address: data.get(#address, or: $value.address),
    port: data.get(#port, or: $value.port),
    paperWidth: data.get(#paperWidth, or: $value.paperWidth),
    isDefault: data.get(#isDefault, or: $value.isDefault),
    isEnabled: data.get(#isEnabled, or: $value.isEnabled),
    branch: data.get(#branch, or: $value.branch),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  PrinterConfigDtoCopyWith<$R2, PrinterConfigDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PrinterConfigDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

