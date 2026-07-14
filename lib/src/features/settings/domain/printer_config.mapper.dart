// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'printer_config.dart';

class PrinterConfigMapper extends ClassMapperBase<PrinterConfig> {
  PrinterConfigMapper._();

  static PrinterConfigMapper? _instance;
  static PrinterConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PrinterConfigMapper._());
      PrinterConnectionTypeMapper.ensureInitialized();
      PrinterPaperWidthMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PrinterConfig';

  static String _$id(PrinterConfig v) => v.id;
  static const Field<PrinterConfig, String> _f$id = Field('id', _$id);
  static String _$name(PrinterConfig v) => v.name;
  static const Field<PrinterConfig, String> _f$name = Field('name', _$name);
  static PrinterConnectionType _$connectionType(PrinterConfig v) =>
      v.connectionType;
  static const Field<PrinterConfig, PrinterConnectionType> _f$connectionType =
      Field('connectionType', _$connectionType);
  static String? _$address(PrinterConfig v) => v.address;
  static const Field<PrinterConfig, String> _f$address = Field(
    'address',
    _$address,
    opt: true,
  );
  static int _$port(PrinterConfig v) => v.port;
  static const Field<PrinterConfig, int> _f$port = Field(
    'port',
    _$port,
    opt: true,
    def: 9100,
  );
  static PrinterPaperWidth _$paperWidth(PrinterConfig v) => v.paperWidth;
  static const Field<PrinterConfig, PrinterPaperWidth> _f$paperWidth = Field(
    'paperWidth',
    _$paperWidth,
    opt: true,
    def: PrinterPaperWidth.mm80,
  );
  static bool _$isDefault(PrinterConfig v) => v.isDefault;
  static const Field<PrinterConfig, bool> _f$isDefault = Field(
    'isDefault',
    _$isDefault,
    opt: true,
    def: false,
  );
  static bool _$isEnabled(PrinterConfig v) => v.isEnabled;
  static const Field<PrinterConfig, bool> _f$isEnabled = Field(
    'isEnabled',
    _$isEnabled,
    opt: true,
    def: true,
  );
  static String? _$branchId(PrinterConfig v) => v.branchId;
  static const Field<PrinterConfig, String> _f$branchId = Field(
    'branchId',
    _$branchId,
    opt: true,
  );
  static bool _$isDeleted(PrinterConfig v) => v.isDeleted;
  static const Field<PrinterConfig, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(PrinterConfig v) => v.created;
  static const Field<PrinterConfig, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(PrinterConfig v) => v.updated;
  static const Field<PrinterConfig, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<PrinterConfig> fields = const {
    #id: _f$id,
    #name: _f$name,
    #connectionType: _f$connectionType,
    #address: _f$address,
    #port: _f$port,
    #paperWidth: _f$paperWidth,
    #isDefault: _f$isDefault,
    #isEnabled: _f$isEnabled,
    #branchId: _f$branchId,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static PrinterConfig _instantiate(DecodingData data) {
    return PrinterConfig(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      connectionType: data.dec(_f$connectionType),
      address: data.dec(_f$address),
      port: data.dec(_f$port),
      paperWidth: data.dec(_f$paperWidth),
      isDefault: data.dec(_f$isDefault),
      isEnabled: data.dec(_f$isEnabled),
      branchId: data.dec(_f$branchId),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PrinterConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PrinterConfig>(map);
  }

  static PrinterConfig fromJson(String json) {
    return ensureInitialized().decodeJson<PrinterConfig>(json);
  }
}

mixin PrinterConfigMappable {
  String toJson() {
    return PrinterConfigMapper.ensureInitialized().encodeJson<PrinterConfig>(
      this as PrinterConfig,
    );
  }

  Map<String, dynamic> toMap() {
    return PrinterConfigMapper.ensureInitialized().encodeMap<PrinterConfig>(
      this as PrinterConfig,
    );
  }

  PrinterConfigCopyWith<PrinterConfig, PrinterConfig, PrinterConfig>
  get copyWith => _PrinterConfigCopyWithImpl<PrinterConfig, PrinterConfig>(
    this as PrinterConfig,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return PrinterConfigMapper.ensureInitialized().stringifyValue(
      this as PrinterConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return PrinterConfigMapper.ensureInitialized().equalsValue(
      this as PrinterConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return PrinterConfigMapper.ensureInitialized().hashValue(
      this as PrinterConfig,
    );
  }
}

extension PrinterConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PrinterConfig, $Out> {
  PrinterConfigCopyWith<$R, PrinterConfig, $Out> get $asPrinterConfig =>
      $base.as((v, t, t2) => _PrinterConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PrinterConfigCopyWith<$R, $In extends PrinterConfig, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    PrinterConnectionType? connectionType,
    String? address,
    int? port,
    PrinterPaperWidth? paperWidth,
    bool? isDefault,
    bool? isEnabled,
    String? branchId,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  PrinterConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PrinterConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PrinterConfig, $Out>
    implements PrinterConfigCopyWith<$R, PrinterConfig, $Out> {
  _PrinterConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PrinterConfig> $mapper =
      PrinterConfigMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    PrinterConnectionType? connectionType,
    Object? address = $none,
    int? port,
    PrinterPaperWidth? paperWidth,
    bool? isDefault,
    bool? isEnabled,
    Object? branchId = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (connectionType != null) #connectionType: connectionType,
      if (address != $none) #address: address,
      if (port != null) #port: port,
      if (paperWidth != null) #paperWidth: paperWidth,
      if (isDefault != null) #isDefault: isDefault,
      if (isEnabled != null) #isEnabled: isEnabled,
      if (branchId != $none) #branchId: branchId,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  PrinterConfig $make(CopyWithData data) => PrinterConfig(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    connectionType: data.get(#connectionType, or: $value.connectionType),
    address: data.get(#address, or: $value.address),
    port: data.get(#port, or: $value.port),
    paperWidth: data.get(#paperWidth, or: $value.paperWidth),
    isDefault: data.get(#isDefault, or: $value.isDefault),
    isEnabled: data.get(#isEnabled, or: $value.isEnabled),
    branchId: data.get(#branchId, or: $value.branchId),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  PrinterConfigCopyWith<$R2, PrinterConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PrinterConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

