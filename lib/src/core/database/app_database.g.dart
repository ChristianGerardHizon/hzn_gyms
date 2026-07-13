// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MembersTable extends Members with TableInfo<$MembersTable, MemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoFileMeta = const VerificationMeta(
    'photoFile',
  );
  @override
  late final GeneratedColumn<String> photoFile = GeneratedColumn<String>(
    'photo_file',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mobileNumberMeta = const VerificationMeta(
    'mobileNumber',
  );
  @override
  late final GeneratedColumn<String> mobileNumber = GeneratedColumn<String>(
    'mobile_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
    'date_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedByMeta = const VerificationMeta(
    'addedBy',
  );
  @override
  late final GeneratedColumn<String> addedBy = GeneratedColumn<String>(
    'added_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rfidCardIdMeta = const VerificationMeta(
    'rfidCardId',
  );
  @override
  late final GeneratedColumn<String> rfidCardId = GeneratedColumn<String>(
    'rfid_card_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emergencyContactMeta = const VerificationMeta(
    'emergencyContact',
  );
  @override
  late final GeneratedColumn<String> emergencyContact = GeneratedColumn<String>(
    'emergency_contact',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _branchMeta = const VerificationMeta('branch');
  @override
  late final GeneratedColumn<String> branch = GeneratedColumn<String>(
    'branch',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdMeta = const VerificationMeta(
    'created',
  );
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
    'created',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedMeta = const VerificationMeta(
    'updated',
  );
  @override
  late final GeneratedColumn<DateTime> updated = GeneratedColumn<DateTime>(
    'updated',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _localPhotoPathMeta = const VerificationMeta(
    'localPhotoPath',
  );
  @override
  late final GeneratedColumn<String> localPhotoPath = GeneratedColumn<String>(
    'local_photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    photoFile,
    mobileNumber,
    dateOfBirth,
    address,
    sex,
    remarks,
    addedBy,
    rfidCardId,
    email,
    emergencyContact,
    branch,
    created,
    updated,
    syncedAt,
    syncStatus,
    localPhotoPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('photo_file')) {
      context.handle(
        _photoFileMeta,
        photoFile.isAcceptableOrUnknown(data['photo_file']!, _photoFileMeta),
      );
    }
    if (data.containsKey('mobile_number')) {
      context.handle(
        _mobileNumberMeta,
        mobileNumber.isAcceptableOrUnknown(
          data['mobile_number']!,
          _mobileNumberMeta,
        ),
      );
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('added_by')) {
      context.handle(
        _addedByMeta,
        addedBy.isAcceptableOrUnknown(data['added_by']!, _addedByMeta),
      );
    }
    if (data.containsKey('rfid_card_id')) {
      context.handle(
        _rfidCardIdMeta,
        rfidCardId.isAcceptableOrUnknown(
          data['rfid_card_id']!,
          _rfidCardIdMeta,
        ),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('emergency_contact')) {
      context.handle(
        _emergencyContactMeta,
        emergencyContact.isAcceptableOrUnknown(
          data['emergency_contact']!,
          _emergencyContactMeta,
        ),
      );
    }
    if (data.containsKey('branch')) {
      context.handle(
        _branchMeta,
        branch.isAcceptableOrUnknown(data['branch']!, _branchMeta),
      );
    }
    if (data.containsKey('created')) {
      context.handle(
        _createdMeta,
        created.isAcceptableOrUnknown(data['created']!, _createdMeta),
      );
    }
    if (data.containsKey('updated')) {
      context.handle(
        _updatedMeta,
        updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('local_photo_path')) {
      context.handle(
        _localPhotoPathMeta,
        localPhotoPath.isAcceptableOrUnknown(
          data['local_photo_path']!,
          _localPhotoPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemberRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      photoFile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_file'],
      ),
      mobileNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_number'],
      ),
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_of_birth'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      ),
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      addedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}added_by'],
      ),
      rfidCardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rfid_card_id'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      emergencyContact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emergency_contact'],
      ),
      branch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch'],
      ),
      created: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created'],
      ),
      updated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      localPhotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_photo_path'],
      ),
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class MemberRow extends DataClass implements Insertable<MemberRow> {
  final String id;
  final String name;
  final String? photoFile;
  final String? mobileNumber;
  final DateTime? dateOfBirth;
  final String? address;
  final String? sex;
  final String? remarks;
  final String? addedBy;
  final String? rfidCardId;
  final String? email;
  final String? emergencyContact;
  final String? branch;
  final DateTime? created;
  final DateTime? updated;
  final DateTime syncedAt;
  final String syncStatus;
  final String? localPhotoPath;
  const MemberRow({
    required this.id,
    required this.name,
    this.photoFile,
    this.mobileNumber,
    this.dateOfBirth,
    this.address,
    this.sex,
    this.remarks,
    this.addedBy,
    this.rfidCardId,
    this.email,
    this.emergencyContact,
    this.branch,
    this.created,
    this.updated,
    required this.syncedAt,
    required this.syncStatus,
    this.localPhotoPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || photoFile != null) {
      map['photo_file'] = Variable<String>(photoFile);
    }
    if (!nullToAbsent || mobileNumber != null) {
      map['mobile_number'] = Variable<String>(mobileNumber);
    }
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>(sex);
    }
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || addedBy != null) {
      map['added_by'] = Variable<String>(addedBy);
    }
    if (!nullToAbsent || rfidCardId != null) {
      map['rfid_card_id'] = Variable<String>(rfidCardId);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || emergencyContact != null) {
      map['emergency_contact'] = Variable<String>(emergencyContact);
    }
    if (!nullToAbsent || branch != null) {
      map['branch'] = Variable<String>(branch);
    }
    if (!nullToAbsent || created != null) {
      map['created'] = Variable<DateTime>(created);
    }
    if (!nullToAbsent || updated != null) {
      map['updated'] = Variable<DateTime>(updated);
    }
    map['synced_at'] = Variable<DateTime>(syncedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || localPhotoPath != null) {
      map['local_photo_path'] = Variable<String>(localPhotoPath);
    }
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      name: Value(name),
      photoFile: photoFile == null && nullToAbsent
          ? const Value.absent()
          : Value(photoFile),
      mobileNumber: mobileNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(mobileNumber),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      addedBy: addedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(addedBy),
      rfidCardId: rfidCardId == null && nullToAbsent
          ? const Value.absent()
          : Value(rfidCardId),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      emergencyContact: emergencyContact == null && nullToAbsent
          ? const Value.absent()
          : Value(emergencyContact),
      branch: branch == null && nullToAbsent
          ? const Value.absent()
          : Value(branch),
      created: created == null && nullToAbsent
          ? const Value.absent()
          : Value(created),
      updated: updated == null && nullToAbsent
          ? const Value.absent()
          : Value(updated),
      syncedAt: Value(syncedAt),
      syncStatus: Value(syncStatus),
      localPhotoPath: localPhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPhotoPath),
    );
  }

  factory MemberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemberRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      photoFile: serializer.fromJson<String?>(json['photoFile']),
      mobileNumber: serializer.fromJson<String?>(json['mobileNumber']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      address: serializer.fromJson<String?>(json['address']),
      sex: serializer.fromJson<String?>(json['sex']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      addedBy: serializer.fromJson<String?>(json['addedBy']),
      rfidCardId: serializer.fromJson<String?>(json['rfidCardId']),
      email: serializer.fromJson<String?>(json['email']),
      emergencyContact: serializer.fromJson<String?>(json['emergencyContact']),
      branch: serializer.fromJson<String?>(json['branch']),
      created: serializer.fromJson<DateTime?>(json['created']),
      updated: serializer.fromJson<DateTime?>(json['updated']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localPhotoPath: serializer.fromJson<String?>(json['localPhotoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'photoFile': serializer.toJson<String?>(photoFile),
      'mobileNumber': serializer.toJson<String?>(mobileNumber),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'address': serializer.toJson<String?>(address),
      'sex': serializer.toJson<String?>(sex),
      'remarks': serializer.toJson<String?>(remarks),
      'addedBy': serializer.toJson<String?>(addedBy),
      'rfidCardId': serializer.toJson<String?>(rfidCardId),
      'email': serializer.toJson<String?>(email),
      'emergencyContact': serializer.toJson<String?>(emergencyContact),
      'branch': serializer.toJson<String?>(branch),
      'created': serializer.toJson<DateTime?>(created),
      'updated': serializer.toJson<DateTime?>(updated),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localPhotoPath': serializer.toJson<String?>(localPhotoPath),
    };
  }

  MemberRow copyWith({
    String? id,
    String? name,
    Value<String?> photoFile = const Value.absent(),
    Value<String?> mobileNumber = const Value.absent(),
    Value<DateTime?> dateOfBirth = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> sex = const Value.absent(),
    Value<String?> remarks = const Value.absent(),
    Value<String?> addedBy = const Value.absent(),
    Value<String?> rfidCardId = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> emergencyContact = const Value.absent(),
    Value<String?> branch = const Value.absent(),
    Value<DateTime?> created = const Value.absent(),
    Value<DateTime?> updated = const Value.absent(),
    DateTime? syncedAt,
    String? syncStatus,
    Value<String?> localPhotoPath = const Value.absent(),
  }) => MemberRow(
    id: id ?? this.id,
    name: name ?? this.name,
    photoFile: photoFile.present ? photoFile.value : this.photoFile,
    mobileNumber: mobileNumber.present ? mobileNumber.value : this.mobileNumber,
    dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
    address: address.present ? address.value : this.address,
    sex: sex.present ? sex.value : this.sex,
    remarks: remarks.present ? remarks.value : this.remarks,
    addedBy: addedBy.present ? addedBy.value : this.addedBy,
    rfidCardId: rfidCardId.present ? rfidCardId.value : this.rfidCardId,
    email: email.present ? email.value : this.email,
    emergencyContact: emergencyContact.present
        ? emergencyContact.value
        : this.emergencyContact,
    branch: branch.present ? branch.value : this.branch,
    created: created.present ? created.value : this.created,
    updated: updated.present ? updated.value : this.updated,
    syncedAt: syncedAt ?? this.syncedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    localPhotoPath: localPhotoPath.present
        ? localPhotoPath.value
        : this.localPhotoPath,
  );
  MemberRow copyWithCompanion(MembersCompanion data) {
    return MemberRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      photoFile: data.photoFile.present ? data.photoFile.value : this.photoFile,
      mobileNumber: data.mobileNumber.present
          ? data.mobileNumber.value
          : this.mobileNumber,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      address: data.address.present ? data.address.value : this.address,
      sex: data.sex.present ? data.sex.value : this.sex,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      addedBy: data.addedBy.present ? data.addedBy.value : this.addedBy,
      rfidCardId: data.rfidCardId.present
          ? data.rfidCardId.value
          : this.rfidCardId,
      email: data.email.present ? data.email.value : this.email,
      emergencyContact: data.emergencyContact.present
          ? data.emergencyContact.value
          : this.emergencyContact,
      branch: data.branch.present ? data.branch.value : this.branch,
      created: data.created.present ? data.created.value : this.created,
      updated: data.updated.present ? data.updated.value : this.updated,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      localPhotoPath: data.localPhotoPath.present
          ? data.localPhotoPath.value
          : this.localPhotoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemberRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('photoFile: $photoFile, ')
          ..write('mobileNumber: $mobileNumber, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('address: $address, ')
          ..write('sex: $sex, ')
          ..write('remarks: $remarks, ')
          ..write('addedBy: $addedBy, ')
          ..write('rfidCardId: $rfidCardId, ')
          ..write('email: $email, ')
          ..write('emergencyContact: $emergencyContact, ')
          ..write('branch: $branch, ')
          ..write('created: $created, ')
          ..write('updated: $updated, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localPhotoPath: $localPhotoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    photoFile,
    mobileNumber,
    dateOfBirth,
    address,
    sex,
    remarks,
    addedBy,
    rfidCardId,
    email,
    emergencyContact,
    branch,
    created,
    updated,
    syncedAt,
    syncStatus,
    localPhotoPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemberRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.photoFile == this.photoFile &&
          other.mobileNumber == this.mobileNumber &&
          other.dateOfBirth == this.dateOfBirth &&
          other.address == this.address &&
          other.sex == this.sex &&
          other.remarks == this.remarks &&
          other.addedBy == this.addedBy &&
          other.rfidCardId == this.rfidCardId &&
          other.email == this.email &&
          other.emergencyContact == this.emergencyContact &&
          other.branch == this.branch &&
          other.created == this.created &&
          other.updated == this.updated &&
          other.syncedAt == this.syncedAt &&
          other.syncStatus == this.syncStatus &&
          other.localPhotoPath == this.localPhotoPath);
}

class MembersCompanion extends UpdateCompanion<MemberRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> photoFile;
  final Value<String?> mobileNumber;
  final Value<DateTime?> dateOfBirth;
  final Value<String?> address;
  final Value<String?> sex;
  final Value<String?> remarks;
  final Value<String?> addedBy;
  final Value<String?> rfidCardId;
  final Value<String?> email;
  final Value<String?> emergencyContact;
  final Value<String?> branch;
  final Value<DateTime?> created;
  final Value<DateTime?> updated;
  final Value<DateTime> syncedAt;
  final Value<String> syncStatus;
  final Value<String?> localPhotoPath;
  final Value<int> rowid;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.photoFile = const Value.absent(),
    this.mobileNumber = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.address = const Value.absent(),
    this.sex = const Value.absent(),
    this.remarks = const Value.absent(),
    this.addedBy = const Value.absent(),
    this.rfidCardId = const Value.absent(),
    this.email = const Value.absent(),
    this.emergencyContact = const Value.absent(),
    this.branch = const Value.absent(),
    this.created = const Value.absent(),
    this.updated = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localPhotoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembersCompanion.insert({
    required String id,
    required String name,
    this.photoFile = const Value.absent(),
    this.mobileNumber = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.address = const Value.absent(),
    this.sex = const Value.absent(),
    this.remarks = const Value.absent(),
    this.addedBy = const Value.absent(),
    this.rfidCardId = const Value.absent(),
    this.email = const Value.absent(),
    this.emergencyContact = const Value.absent(),
    this.branch = const Value.absent(),
    this.created = const Value.absent(),
    this.updated = const Value.absent(),
    required DateTime syncedAt,
    this.syncStatus = const Value.absent(),
    this.localPhotoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       syncedAt = Value(syncedAt);
  static Insertable<MemberRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? photoFile,
    Expression<String>? mobileNumber,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? address,
    Expression<String>? sex,
    Expression<String>? remarks,
    Expression<String>? addedBy,
    Expression<String>? rfidCardId,
    Expression<String>? email,
    Expression<String>? emergencyContact,
    Expression<String>? branch,
    Expression<DateTime>? created,
    Expression<DateTime>? updated,
    Expression<DateTime>? syncedAt,
    Expression<String>? syncStatus,
    Expression<String>? localPhotoPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (photoFile != null) 'photo_file': photoFile,
      if (mobileNumber != null) 'mobile_number': mobileNumber,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (address != null) 'address': address,
      if (sex != null) 'sex': sex,
      if (remarks != null) 'remarks': remarks,
      if (addedBy != null) 'added_by': addedBy,
      if (rfidCardId != null) 'rfid_card_id': rfidCardId,
      if (email != null) 'email': email,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
      if (branch != null) 'branch': branch,
      if (created != null) 'created': created,
      if (updated != null) 'updated': updated,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localPhotoPath != null) 'local_photo_path': localPhotoPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? photoFile,
    Value<String?>? mobileNumber,
    Value<DateTime?>? dateOfBirth,
    Value<String?>? address,
    Value<String?>? sex,
    Value<String?>? remarks,
    Value<String?>? addedBy,
    Value<String?>? rfidCardId,
    Value<String?>? email,
    Value<String?>? emergencyContact,
    Value<String?>? branch,
    Value<DateTime?>? created,
    Value<DateTime?>? updated,
    Value<DateTime>? syncedAt,
    Value<String>? syncStatus,
    Value<String?>? localPhotoPath,
    Value<int>? rowid,
  }) {
    return MembersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      photoFile: photoFile ?? this.photoFile,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      sex: sex ?? this.sex,
      remarks: remarks ?? this.remarks,
      addedBy: addedBy ?? this.addedBy,
      rfidCardId: rfidCardId ?? this.rfidCardId,
      email: email ?? this.email,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      branch: branch ?? this.branch,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      syncedAt: syncedAt ?? this.syncedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      localPhotoPath: localPhotoPath ?? this.localPhotoPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (photoFile.present) {
      map['photo_file'] = Variable<String>(photoFile.value);
    }
    if (mobileNumber.present) {
      map['mobile_number'] = Variable<String>(mobileNumber.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (addedBy.present) {
      map['added_by'] = Variable<String>(addedBy.value);
    }
    if (rfidCardId.present) {
      map['rfid_card_id'] = Variable<String>(rfidCardId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (emergencyContact.present) {
      map['emergency_contact'] = Variable<String>(emergencyContact.value);
    }
    if (branch.present) {
      map['branch'] = Variable<String>(branch.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (updated.present) {
      map['updated'] = Variable<DateTime>(updated.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localPhotoPath.present) {
      map['local_photo_path'] = Variable<String>(localPhotoPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('photoFile: $photoFile, ')
          ..write('mobileNumber: $mobileNumber, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('address: $address, ')
          ..write('sex: $sex, ')
          ..write('remarks: $remarks, ')
          ..write('addedBy: $addedBy, ')
          ..write('rfidCardId: $rfidCardId, ')
          ..write('email: $email, ')
          ..write('emergencyContact: $emergencyContact, ')
          ..write('branch: $branch, ')
          ..write('created: $created, ')
          ..write('updated: $updated, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localPhotoPath: $localPhotoPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxEntriesTable extends OutboxEntries
    with TableInfo<$OutboxEntriesTable, OutboxEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientRecordIdMeta = const VerificationMeta(
    'clientRecordId',
  );
  @override
  late final GeneratedColumn<String> clientRecordId = GeneratedColumn<String>(
    'client_record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dependsOnIdMeta = const VerificationMeta(
    'dependsOnId',
  );
  @override
  late final GeneratedColumn<String> dependsOnId = GeneratedColumn<String>(
    'depends_on_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    operation,
    payload,
    clientRecordId,
    dependsOnId,
    status,
    createdAt,
    attempts,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('client_record_id')) {
      context.handle(
        _clientRecordIdMeta,
        clientRecordId.isAcceptableOrUnknown(
          data['client_record_id']!,
          _clientRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientRecordIdMeta);
    }
    if (data.containsKey('depends_on_id')) {
      context.handle(
        _dependsOnIdMeta,
        dependsOnId.isAcceptableOrUnknown(
          data['depends_on_id']!,
          _dependsOnIdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      clientRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_record_id'],
      )!,
      dependsOnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}depends_on_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $OutboxEntriesTable createAlias(String alias) {
    return $OutboxEntriesTable(attachedDatabase, alias);
  }
}

class OutboxEntryRow extends DataClass implements Insertable<OutboxEntryRow> {
  final String id;
  final String entityType;
  final String operation;
  final String payload;
  final String clientRecordId;
  final String? dependsOnId;
  final String status;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;
  const OutboxEntryRow({
    required this.id,
    required this.entityType,
    required this.operation,
    required this.payload,
    required this.clientRecordId,
    this.dependsOnId,
    required this.status,
    required this.createdAt,
    required this.attempts,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['client_record_id'] = Variable<String>(clientRecordId);
    if (!nullToAbsent || dependsOnId != null) {
      map['depends_on_id'] = Variable<String>(dependsOnId);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  OutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return OutboxEntriesCompanion(
      id: Value(id),
      entityType: Value(entityType),
      operation: Value(operation),
      payload: Value(payload),
      clientRecordId: Value(clientRecordId),
      dependsOnId: dependsOnId == null && nullToAbsent
          ? const Value.absent()
          : Value(dependsOnId),
      status: Value(status),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory OutboxEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntryRow(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      clientRecordId: serializer.fromJson<String>(json['clientRecordId']),
      dependsOnId: serializer.fromJson<String?>(json['dependsOnId']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'clientRecordId': serializer.toJson<String>(clientRecordId),
      'dependsOnId': serializer.toJson<String?>(dependsOnId),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  OutboxEntryRow copyWith({
    String? id,
    String? entityType,
    String? operation,
    String? payload,
    String? clientRecordId,
    Value<String?> dependsOnId = const Value.absent(),
    String? status,
    DateTime? createdAt,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
  }) => OutboxEntryRow(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    clientRecordId: clientRecordId ?? this.clientRecordId,
    dependsOnId: dependsOnId.present ? dependsOnId.value : this.dependsOnId,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  OutboxEntryRow copyWithCompanion(OutboxEntriesCompanion data) {
    return OutboxEntryRow(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      clientRecordId: data.clientRecordId.present
          ? data.clientRecordId.value
          : this.clientRecordId,
      dependsOnId: data.dependsOnId.present
          ? data.dependsOnId.value
          : this.dependsOnId,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntryRow(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('clientRecordId: $clientRecordId, ')
          ..write('dependsOnId: $dependsOnId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    operation,
    payload,
    clientRecordId,
    dependsOnId,
    status,
    createdAt,
    attempts,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntryRow &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.clientRecordId == this.clientRecordId &&
          other.dependsOnId == this.dependsOnId &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class OutboxEntriesCompanion extends UpdateCompanion<OutboxEntryRow> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> operation;
  final Value<String> payload;
  final Value<String> clientRecordId;
  final Value<String?> dependsOnId;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<int> rowid;
  const OutboxEntriesCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.clientRecordId = const Value.absent(),
    this.dependsOnId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxEntriesCompanion.insert({
    required String id,
    required String entityType,
    required String operation,
    required String payload,
    required String clientRecordId,
    this.dependsOnId = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       operation = Value(operation),
       payload = Value(payload),
       clientRecordId = Value(clientRecordId),
       createdAt = Value(createdAt);
  static Insertable<OutboxEntryRow> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<String>? clientRecordId,
    Expression<String>? dependsOnId,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (clientRecordId != null) 'client_record_id': clientRecordId,
      if (dependsOnId != null) 'depends_on_id': dependsOnId,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? operation,
    Value<String>? payload,
    Value<String>? clientRecordId,
    Value<String?>? dependsOnId,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return OutboxEntriesCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      clientRecordId: clientRecordId ?? this.clientRecordId,
      dependsOnId: dependsOnId ?? this.dependsOnId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (clientRecordId.present) {
      map['client_record_id'] = Variable<String>(clientRecordId.value);
    }
    if (dependsOnId.present) {
      map['depends_on_id'] = Variable<String>(dependsOnId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntriesCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('clientRecordId: $clientRecordId, ')
          ..write('dependsOnId: $dependsOnId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxAttachmentsTable extends OutboxAttachments
    with TableInfo<$OutboxAttachmentsTable, OutboxAttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _outboxIdMeta = const VerificationMeta(
    'outboxId',
  );
  @override
  late final GeneratedColumn<String> outboxId = GeneratedColumn<String>(
    'outbox_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filenameMeta = const VerificationMeta(
    'filename',
  );
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
    'filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<Uint8List> bytes = GeneratedColumn<Uint8List>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [outboxId, filename, bytes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxAttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('outbox_id')) {
      context.handle(
        _outboxIdMeta,
        outboxId.isAcceptableOrUnknown(data['outbox_id']!, _outboxIdMeta),
      );
    } else if (isInserting) {
      context.missing(_outboxIdMeta);
    }
    if (data.containsKey('filename')) {
      context.handle(
        _filenameMeta,
        filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta),
      );
    } else if (isInserting) {
      context.missing(_filenameMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {outboxId};
  @override
  OutboxAttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxAttachmentRow(
      outboxId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outbox_id'],
      )!,
      filename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filename'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}bytes'],
      )!,
    );
  }

  @override
  $OutboxAttachmentsTable createAlias(String alias) {
    return $OutboxAttachmentsTable(attachedDatabase, alias);
  }
}

class OutboxAttachmentRow extends DataClass
    implements Insertable<OutboxAttachmentRow> {
  final String outboxId;
  final String filename;
  final Uint8List bytes;
  const OutboxAttachmentRow({
    required this.outboxId,
    required this.filename,
    required this.bytes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['outbox_id'] = Variable<String>(outboxId);
    map['filename'] = Variable<String>(filename);
    map['bytes'] = Variable<Uint8List>(bytes);
    return map;
  }

  OutboxAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return OutboxAttachmentsCompanion(
      outboxId: Value(outboxId),
      filename: Value(filename),
      bytes: Value(bytes),
    );
  }

  factory OutboxAttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxAttachmentRow(
      outboxId: serializer.fromJson<String>(json['outboxId']),
      filename: serializer.fromJson<String>(json['filename']),
      bytes: serializer.fromJson<Uint8List>(json['bytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'outboxId': serializer.toJson<String>(outboxId),
      'filename': serializer.toJson<String>(filename),
      'bytes': serializer.toJson<Uint8List>(bytes),
    };
  }

  OutboxAttachmentRow copyWith({
    String? outboxId,
    String? filename,
    Uint8List? bytes,
  }) => OutboxAttachmentRow(
    outboxId: outboxId ?? this.outboxId,
    filename: filename ?? this.filename,
    bytes: bytes ?? this.bytes,
  );
  OutboxAttachmentRow copyWithCompanion(OutboxAttachmentsCompanion data) {
    return OutboxAttachmentRow(
      outboxId: data.outboxId.present ? data.outboxId.value : this.outboxId,
      filename: data.filename.present ? data.filename.value : this.filename,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxAttachmentRow(')
          ..write('outboxId: $outboxId, ')
          ..write('filename: $filename, ')
          ..write('bytes: $bytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(outboxId, filename, $driftBlobEquality.hash(bytes));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxAttachmentRow &&
          other.outboxId == this.outboxId &&
          other.filename == this.filename &&
          $driftBlobEquality.equals(other.bytes, this.bytes));
}

class OutboxAttachmentsCompanion extends UpdateCompanion<OutboxAttachmentRow> {
  final Value<String> outboxId;
  final Value<String> filename;
  final Value<Uint8List> bytes;
  final Value<int> rowid;
  const OutboxAttachmentsCompanion({
    this.outboxId = const Value.absent(),
    this.filename = const Value.absent(),
    this.bytes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxAttachmentsCompanion.insert({
    required String outboxId,
    required String filename,
    required Uint8List bytes,
    this.rowid = const Value.absent(),
  }) : outboxId = Value(outboxId),
       filename = Value(filename),
       bytes = Value(bytes);
  static Insertable<OutboxAttachmentRow> custom({
    Expression<String>? outboxId,
    Expression<String>? filename,
    Expression<Uint8List>? bytes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (outboxId != null) 'outbox_id': outboxId,
      if (filename != null) 'filename': filename,
      if (bytes != null) 'bytes': bytes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxAttachmentsCompanion copyWith({
    Value<String>? outboxId,
    Value<String>? filename,
    Value<Uint8List>? bytes,
    Value<int>? rowid,
  }) {
    return OutboxAttachmentsCompanion(
      outboxId: outboxId ?? this.outboxId,
      filename: filename ?? this.filename,
      bytes: bytes ?? this.bytes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (outboxId.present) {
      map['outbox_id'] = Variable<String>(outboxId.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<Uint8List>(bytes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxAttachmentsCompanion(')
          ..write('outboxId: $outboxId, ')
          ..write('filename: $filename, ')
          ..write('bytes: $bytes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingMemberMembershipsTable extends PendingMemberMemberships
    with TableInfo<$PendingMemberMembershipsTable, PendingMemberMembershipRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingMemberMembershipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _membershipIdMeta = const VerificationMeta(
    'membershipId',
  );
  @override
  late final GeneratedColumn<String> membershipId = GeneratedColumn<String>(
    'membership_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planNameMeta = const VerificationMeta(
    'planName',
  );
  @override
  late final GeneratedColumn<String> planName = GeneratedColumn<String>(
    'plan_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    memberId,
    membershipId,
    planName,
    startDate,
    endDate,
    status,
    saleId,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_member_memberships';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingMemberMembershipRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('membership_id')) {
      context.handle(
        _membershipIdMeta,
        membershipId.isAcceptableOrUnknown(
          data['membership_id']!,
          _membershipIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_membershipIdMeta);
    }
    if (data.containsKey('plan_name')) {
      context.handle(
        _planNameMeta,
        planName.isAcceptableOrUnknown(data['plan_name']!, _planNameMeta),
      );
    } else if (isInserting) {
      context.missing(_planNameMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingMemberMembershipRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingMemberMembershipRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      membershipId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}membership_id'],
      )!,
      planName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_name'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PendingMemberMembershipsTable createAlias(String alias) {
    return $PendingMemberMembershipsTable(attachedDatabase, alias);
  }
}

class PendingMemberMembershipRow extends DataClass
    implements Insertable<PendingMemberMembershipRow> {
  final String id;
  final String memberId;
  final String membershipId;
  final String planName;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String? saleId;
  final String syncStatus;
  final DateTime createdAt;
  const PendingMemberMembershipRow({
    required this.id,
    required this.memberId,
    required this.membershipId,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.saleId,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['member_id'] = Variable<String>(memberId);
    map['membership_id'] = Variable<String>(membershipId);
    map['plan_name'] = Variable<String>(planName);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || saleId != null) {
      map['sale_id'] = Variable<String>(saleId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingMemberMembershipsCompanion toCompanion(bool nullToAbsent) {
    return PendingMemberMembershipsCompanion(
      id: Value(id),
      memberId: Value(memberId),
      membershipId: Value(membershipId),
      planName: Value(planName),
      startDate: Value(startDate),
      endDate: Value(endDate),
      status: Value(status),
      saleId: saleId == null && nullToAbsent
          ? const Value.absent()
          : Value(saleId),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory PendingMemberMembershipRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingMemberMembershipRow(
      id: serializer.fromJson<String>(json['id']),
      memberId: serializer.fromJson<String>(json['memberId']),
      membershipId: serializer.fromJson<String>(json['membershipId']),
      planName: serializer.fromJson<String>(json['planName']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      status: serializer.fromJson<String>(json['status']),
      saleId: serializer.fromJson<String?>(json['saleId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memberId': serializer.toJson<String>(memberId),
      'membershipId': serializer.toJson<String>(membershipId),
      'planName': serializer.toJson<String>(planName),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'status': serializer.toJson<String>(status),
      'saleId': serializer.toJson<String?>(saleId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingMemberMembershipRow copyWith({
    String? id,
    String? memberId,
    String? membershipId,
    String? planName,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    Value<String?> saleId = const Value.absent(),
    String? syncStatus,
    DateTime? createdAt,
  }) => PendingMemberMembershipRow(
    id: id ?? this.id,
    memberId: memberId ?? this.memberId,
    membershipId: membershipId ?? this.membershipId,
    planName: planName ?? this.planName,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    status: status ?? this.status,
    saleId: saleId.present ? saleId.value : this.saleId,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  PendingMemberMembershipRow copyWithCompanion(
    PendingMemberMembershipsCompanion data,
  ) {
    return PendingMemberMembershipRow(
      id: data.id.present ? data.id.value : this.id,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      membershipId: data.membershipId.present
          ? data.membershipId.value
          : this.membershipId,
      planName: data.planName.present ? data.planName.value : this.planName,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      status: data.status.present ? data.status.value : this.status,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingMemberMembershipRow(')
          ..write('id: $id, ')
          ..write('memberId: $memberId, ')
          ..write('membershipId: $membershipId, ')
          ..write('planName: $planName, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('saleId: $saleId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    memberId,
    membershipId,
    planName,
    startDate,
    endDate,
    status,
    saleId,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingMemberMembershipRow &&
          other.id == this.id &&
          other.memberId == this.memberId &&
          other.membershipId == this.membershipId &&
          other.planName == this.planName &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.status == this.status &&
          other.saleId == this.saleId &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class PendingMemberMembershipsCompanion
    extends UpdateCompanion<PendingMemberMembershipRow> {
  final Value<String> id;
  final Value<String> memberId;
  final Value<String> membershipId;
  final Value<String> planName;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> status;
  final Value<String?> saleId;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PendingMemberMembershipsCompanion({
    this.id = const Value.absent(),
    this.memberId = const Value.absent(),
    this.membershipId = const Value.absent(),
    this.planName = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.saleId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingMemberMembershipsCompanion.insert({
    required String id,
    required String memberId,
    required String membershipId,
    required String planName,
    required DateTime startDate,
    required DateTime endDate,
    required String status,
    this.saleId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       memberId = Value(memberId),
       membershipId = Value(membershipId),
       planName = Value(planName),
       startDate = Value(startDate),
       endDate = Value(endDate),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<PendingMemberMembershipRow> custom({
    Expression<String>? id,
    Expression<String>? memberId,
    Expression<String>? membershipId,
    Expression<String>? planName,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? status,
    Expression<String>? saleId,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memberId != null) 'member_id': memberId,
      if (membershipId != null) 'membership_id': membershipId,
      if (planName != null) 'plan_name': planName,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
      if (saleId != null) 'sale_id': saleId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingMemberMembershipsCompanion copyWith({
    Value<String>? id,
    Value<String>? memberId,
    Value<String>? membershipId,
    Value<String>? planName,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<String>? status,
    Value<String?>? saleId,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PendingMemberMembershipsCompanion(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      membershipId: membershipId ?? this.membershipId,
      planName: planName ?? this.planName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      saleId: saleId ?? this.saleId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (membershipId.present) {
      map['membership_id'] = Variable<String>(membershipId.value);
    }
    if (planName.present) {
      map['plan_name'] = Variable<String>(planName.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingMemberMembershipsCompanion(')
          ..write('id: $id, ')
          ..write('memberId: $memberId, ')
          ..write('membershipId: $membershipId, ')
          ..write('planName: $planName, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('saleId: $saleId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembershipPlansTable extends MembershipPlans
    with TableInfo<$MembershipPlansTable, MembershipPlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembershipPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationDaysMeta = const VerificationMeta(
    'durationDays',
  );
  @override
  late final GeneratedColumn<int> durationDays = GeneratedColumn<int>(
    'duration_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _branchIdMeta = const VerificationMeta(
    'branchId',
  );
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
    'branch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _validBranchesJsonMeta = const VerificationMeta(
    'validBranchesJson',
  );
  @override
  late final GeneratedColumn<String> validBranchesJson =
      GeneratedColumn<String>(
        'valid_branches_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    durationDays,
    price,
    branchId,
    validBranchesJson,
    isActive,
    isFavorite,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'membership_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<MembershipPlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('duration_days')) {
      context.handle(
        _durationDaysMeta,
        durationDays.isAcceptableOrUnknown(
          data['duration_days']!,
          _durationDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationDaysMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(
        _branchIdMeta,
        branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('valid_branches_json')) {
      context.handle(
        _validBranchesJsonMeta,
        validBranchesJson.isAcceptableOrUnknown(
          data['valid_branches_json']!,
          _validBranchesJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MembershipPlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MembershipPlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      durationDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_days'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      branchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_id'],
      )!,
      validBranchesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valid_branches_json'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $MembershipPlansTable createAlias(String alias) {
    return $MembershipPlansTable(attachedDatabase, alias);
  }
}

class MembershipPlanRow extends DataClass
    implements Insertable<MembershipPlanRow> {
  final String id;
  final String name;
  final String? description;
  final int durationDays;
  final double price;
  final String branchId;

  /// JSON-encoded list of branch IDs. Empty list (`[]`) means all branches.
  final String validBranchesJson;
  final bool isActive;
  final bool isFavorite;
  final DateTime syncedAt;
  const MembershipPlanRow({
    required this.id,
    required this.name,
    this.description,
    required this.durationDays,
    required this.price,
    required this.branchId,
    required this.validBranchesJson,
    required this.isActive,
    required this.isFavorite,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['duration_days'] = Variable<int>(durationDays);
    map['price'] = Variable<double>(price);
    map['branch_id'] = Variable<String>(branchId);
    map['valid_branches_json'] = Variable<String>(validBranchesJson);
    map['is_active'] = Variable<bool>(isActive);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  MembershipPlansCompanion toCompanion(bool nullToAbsent) {
    return MembershipPlansCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      durationDays: Value(durationDays),
      price: Value(price),
      branchId: Value(branchId),
      validBranchesJson: Value(validBranchesJson),
      isActive: Value(isActive),
      isFavorite: Value(isFavorite),
      syncedAt: Value(syncedAt),
    );
  }

  factory MembershipPlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MembershipPlanRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      durationDays: serializer.fromJson<int>(json['durationDays']),
      price: serializer.fromJson<double>(json['price']),
      branchId: serializer.fromJson<String>(json['branchId']),
      validBranchesJson: serializer.fromJson<String>(json['validBranchesJson']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'durationDays': serializer.toJson<int>(durationDays),
      'price': serializer.toJson<double>(price),
      'branchId': serializer.toJson<String>(branchId),
      'validBranchesJson': serializer.toJson<String>(validBranchesJson),
      'isActive': serializer.toJson<bool>(isActive),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  MembershipPlanRow copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    int? durationDays,
    double? price,
    String? branchId,
    String? validBranchesJson,
    bool? isActive,
    bool? isFavorite,
    DateTime? syncedAt,
  }) => MembershipPlanRow(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    durationDays: durationDays ?? this.durationDays,
    price: price ?? this.price,
    branchId: branchId ?? this.branchId,
    validBranchesJson: validBranchesJson ?? this.validBranchesJson,
    isActive: isActive ?? this.isActive,
    isFavorite: isFavorite ?? this.isFavorite,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  MembershipPlanRow copyWithCompanion(MembershipPlansCompanion data) {
    return MembershipPlanRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      durationDays: data.durationDays.present
          ? data.durationDays.value
          : this.durationDays,
      price: data.price.present ? data.price.value : this.price,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      validBranchesJson: data.validBranchesJson.present
          ? data.validBranchesJson.value
          : this.validBranchesJson,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MembershipPlanRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('durationDays: $durationDays, ')
          ..write('price: $price, ')
          ..write('branchId: $branchId, ')
          ..write('validBranchesJson: $validBranchesJson, ')
          ..write('isActive: $isActive, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    durationDays,
    price,
    branchId,
    validBranchesJson,
    isActive,
    isFavorite,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MembershipPlanRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.durationDays == this.durationDays &&
          other.price == this.price &&
          other.branchId == this.branchId &&
          other.validBranchesJson == this.validBranchesJson &&
          other.isActive == this.isActive &&
          other.isFavorite == this.isFavorite &&
          other.syncedAt == this.syncedAt);
}

class MembershipPlansCompanion extends UpdateCompanion<MembershipPlanRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> durationDays;
  final Value<double> price;
  final Value<String> branchId;
  final Value<String> validBranchesJson;
  final Value<bool> isActive;
  final Value<bool> isFavorite;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const MembershipPlansCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.durationDays = const Value.absent(),
    this.price = const Value.absent(),
    this.branchId = const Value.absent(),
    this.validBranchesJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembershipPlansCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required int durationDays,
    required double price,
    required String branchId,
    this.validBranchesJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isFavorite = const Value.absent(),
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       durationDays = Value(durationDays),
       price = Value(price),
       branchId = Value(branchId),
       syncedAt = Value(syncedAt);
  static Insertable<MembershipPlanRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? durationDays,
    Expression<double>? price,
    Expression<String>? branchId,
    Expression<String>? validBranchesJson,
    Expression<bool>? isActive,
    Expression<bool>? isFavorite,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (durationDays != null) 'duration_days': durationDays,
      if (price != null) 'price': price,
      if (branchId != null) 'branch_id': branchId,
      if (validBranchesJson != null) 'valid_branches_json': validBranchesJson,
      if (isActive != null) 'is_active': isActive,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembershipPlansCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<int>? durationDays,
    Value<double>? price,
    Value<String>? branchId,
    Value<String>? validBranchesJson,
    Value<bool>? isActive,
    Value<bool>? isFavorite,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return MembershipPlansCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      durationDays: durationDays ?? this.durationDays,
      price: price ?? this.price,
      branchId: branchId ?? this.branchId,
      validBranchesJson: validBranchesJson ?? this.validBranchesJson,
      isActive: isActive ?? this.isActive,
      isFavorite: isFavorite ?? this.isFavorite,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (durationDays.present) {
      map['duration_days'] = Variable<int>(durationDays.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (validBranchesJson.present) {
      map['valid_branches_json'] = Variable<String>(validBranchesJson.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembershipPlansCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('durationDays: $durationDays, ')
          ..write('price: $price, ')
          ..write('branchId: $branchId, ')
          ..write('validBranchesJson: $validBranchesJson, ')
          ..write('isActive: $isActive, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembershipAddOnsCacheTable extends MembershipAddOnsCache
    with TableInfo<$MembershipAddOnsCacheTable, MembershipAddOnRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembershipAddOnsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _membershipIdMeta = const VerificationMeta(
    'membershipId',
  );
  @override
  late final GeneratedColumn<String> membershipId = GeneratedColumn<String>(
    'membership_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    membershipId,
    name,
    description,
    price,
    isActive,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'membership_add_ons_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<MembershipAddOnRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('membership_id')) {
      context.handle(
        _membershipIdMeta,
        membershipId.isAcceptableOrUnknown(
          data['membership_id']!,
          _membershipIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_membershipIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MembershipAddOnRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MembershipAddOnRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      membershipId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}membership_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $MembershipAddOnsCacheTable createAlias(String alias) {
    return $MembershipAddOnsCacheTable(attachedDatabase, alias);
  }
}

class MembershipAddOnRow extends DataClass
    implements Insertable<MembershipAddOnRow> {
  final String id;
  final String membershipId;
  final String name;
  final String? description;
  final double price;
  final bool isActive;
  final DateTime syncedAt;
  const MembershipAddOnRow({
    required this.id,
    required this.membershipId,
    required this.name,
    this.description,
    required this.price,
    required this.isActive,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['membership_id'] = Variable<String>(membershipId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['price'] = Variable<double>(price);
    map['is_active'] = Variable<bool>(isActive);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  MembershipAddOnsCacheCompanion toCompanion(bool nullToAbsent) {
    return MembershipAddOnsCacheCompanion(
      id: Value(id),
      membershipId: Value(membershipId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      price: Value(price),
      isActive: Value(isActive),
      syncedAt: Value(syncedAt),
    );
  }

  factory MembershipAddOnRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MembershipAddOnRow(
      id: serializer.fromJson<String>(json['id']),
      membershipId: serializer.fromJson<String>(json['membershipId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      price: serializer.fromJson<double>(json['price']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'membershipId': serializer.toJson<String>(membershipId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'price': serializer.toJson<double>(price),
      'isActive': serializer.toJson<bool>(isActive),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  MembershipAddOnRow copyWith({
    String? id,
    String? membershipId,
    String? name,
    Value<String?> description = const Value.absent(),
    double? price,
    bool? isActive,
    DateTime? syncedAt,
  }) => MembershipAddOnRow(
    id: id ?? this.id,
    membershipId: membershipId ?? this.membershipId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    price: price ?? this.price,
    isActive: isActive ?? this.isActive,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  MembershipAddOnRow copyWithCompanion(MembershipAddOnsCacheCompanion data) {
    return MembershipAddOnRow(
      id: data.id.present ? data.id.value : this.id,
      membershipId: data.membershipId.present
          ? data.membershipId.value
          : this.membershipId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      price: data.price.present ? data.price.value : this.price,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MembershipAddOnRow(')
          ..write('id: $id, ')
          ..write('membershipId: $membershipId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('isActive: $isActive, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    membershipId,
    name,
    description,
    price,
    isActive,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MembershipAddOnRow &&
          other.id == this.id &&
          other.membershipId == this.membershipId &&
          other.name == this.name &&
          other.description == this.description &&
          other.price == this.price &&
          other.isActive == this.isActive &&
          other.syncedAt == this.syncedAt);
}

class MembershipAddOnsCacheCompanion
    extends UpdateCompanion<MembershipAddOnRow> {
  final Value<String> id;
  final Value<String> membershipId;
  final Value<String> name;
  final Value<String?> description;
  final Value<double> price;
  final Value<bool> isActive;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const MembershipAddOnsCacheCompanion({
    this.id = const Value.absent(),
    this.membershipId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembershipAddOnsCacheCompanion.insert({
    required String id,
    required String membershipId,
    required String name,
    this.description = const Value.absent(),
    required double price,
    this.isActive = const Value.absent(),
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       membershipId = Value(membershipId),
       name = Value(name),
       price = Value(price),
       syncedAt = Value(syncedAt);
  static Insertable<MembershipAddOnRow> custom({
    Expression<String>? id,
    Expression<String>? membershipId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? price,
    Expression<bool>? isActive,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (membershipId != null) 'membership_id': membershipId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (isActive != null) 'is_active': isActive,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembershipAddOnsCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? membershipId,
    Value<String>? name,
    Value<String?>? description,
    Value<double>? price,
    Value<bool>? isActive,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return MembershipAddOnsCacheCompanion(
      id: id ?? this.id,
      membershipId: membershipId ?? this.membershipId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (membershipId.present) {
      map['membership_id'] = Variable<String>(membershipId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembershipAddOnsCacheCompanion(')
          ..write('id: $id, ')
          ..write('membershipId: $membershipId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('isActive: $isActive, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppPreferencesTable extends AppPreferences
    with TableInfo<$AppPreferencesTable, AppPreferenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppPreferenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppPreferenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppPreferenceRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppPreferencesTable createAlias(String alias) {
    return $AppPreferencesTable(attachedDatabase, alias);
  }
}

class AppPreferenceRow extends DataClass
    implements Insertable<AppPreferenceRow> {
  final String key;
  final String value;
  const AppPreferenceRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppPreferencesCompanion toCompanion(bool nullToAbsent) {
    return AppPreferencesCompanion(key: Value(key), value: Value(value));
  }

  factory AppPreferenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppPreferenceRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppPreferenceRow copyWith({String? key, String? value}) =>
      AppPreferenceRow(key: key ?? this.key, value: value ?? this.value);
  AppPreferenceRow copyWithCompanion(AppPreferencesCompanion data) {
    return AppPreferenceRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferenceRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppPreferenceRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppPreferencesCompanion extends UpdateCompanion<AppPreferenceRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppPreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppPreferencesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppPreferenceRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppPreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppPreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MembersTable members = $MembersTable(this);
  late final $OutboxEntriesTable outboxEntries = $OutboxEntriesTable(this);
  late final $OutboxAttachmentsTable outboxAttachments =
      $OutboxAttachmentsTable(this);
  late final $PendingMemberMembershipsTable pendingMemberMemberships =
      $PendingMemberMembershipsTable(this);
  late final $MembershipPlansTable membershipPlans = $MembershipPlansTable(
    this,
  );
  late final $MembershipAddOnsCacheTable membershipAddOnsCache =
      $MembershipAddOnsCacheTable(this);
  late final $AppPreferencesTable appPreferences = $AppPreferencesTable(this);
  late final MembersDao membersDao = MembersDao(this as AppDatabase);
  late final OutboxDao outboxDao = OutboxDao(this as AppDatabase);
  late final PendingMemberMembershipsDao pendingMemberMembershipsDao =
      PendingMemberMembershipsDao(this as AppDatabase);
  late final MembershipCacheDao membershipCacheDao = MembershipCacheDao(
    this as AppDatabase,
  );
  late final AppPreferencesDao appPreferencesDao = AppPreferencesDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    members,
    outboxEntries,
    outboxAttachments,
    pendingMemberMemberships,
    membershipPlans,
    membershipAddOnsCache,
    appPreferences,
  ];
}

typedef $$MembersTableCreateCompanionBuilder =
    MembersCompanion Function({
      required String id,
      required String name,
      Value<String?> photoFile,
      Value<String?> mobileNumber,
      Value<DateTime?> dateOfBirth,
      Value<String?> address,
      Value<String?> sex,
      Value<String?> remarks,
      Value<String?> addedBy,
      Value<String?> rfidCardId,
      Value<String?> email,
      Value<String?> emergencyContact,
      Value<String?> branch,
      Value<DateTime?> created,
      Value<DateTime?> updated,
      required DateTime syncedAt,
      Value<String> syncStatus,
      Value<String?> localPhotoPath,
      Value<int> rowid,
    });
typedef $$MembersTableUpdateCompanionBuilder =
    MembersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> photoFile,
      Value<String?> mobileNumber,
      Value<DateTime?> dateOfBirth,
      Value<String?> address,
      Value<String?> sex,
      Value<String?> remarks,
      Value<String?> addedBy,
      Value<String?> rfidCardId,
      Value<String?> email,
      Value<String?> emergencyContact,
      Value<String?> branch,
      Value<DateTime?> created,
      Value<DateTime?> updated,
      Value<DateTime> syncedAt,
      Value<String> syncStatus,
      Value<String?> localPhotoPath,
      Value<int> rowid,
    });

class $$MembersTableFilterComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoFile => $composableBuilder(
    column: $table.photoFile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addedBy => $composableBuilder(
    column: $table.addedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rfidCardId => $composableBuilder(
    column: $table.rfidCardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branch => $composableBuilder(
    column: $table.branch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPhotoPath => $composableBuilder(
    column: $table.localPhotoPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoFile => $composableBuilder(
    column: $table.photoFile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addedBy => $composableBuilder(
    column: $table.addedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rfidCardId => $composableBuilder(
    column: $table.rfidCardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branch => $composableBuilder(
    column: $table.branch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPhotoPath => $composableBuilder(
    column: $table.localPhotoPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get photoFile =>
      $composableBuilder(column: $table.photoFile, builder: (column) => column);

  GeneratedColumn<String> get mobileNumber => $composableBuilder(
    column: $table.mobileNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get addedBy =>
      $composableBuilder(column: $table.addedBy, builder: (column) => column);

  GeneratedColumn<String> get rfidCardId => $composableBuilder(
    column: $table.rfidCardId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => column,
  );

  GeneratedColumn<String> get branch =>
      $composableBuilder(column: $table.branch, builder: (column) => column);

  GeneratedColumn<DateTime> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);

  GeneratedColumn<DateTime> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPhotoPath => $composableBuilder(
    column: $table.localPhotoPath,
    builder: (column) => column,
  );
}

class $$MembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MembersTable,
          MemberRow,
          $$MembersTableFilterComposer,
          $$MembersTableOrderingComposer,
          $$MembersTableAnnotationComposer,
          $$MembersTableCreateCompanionBuilder,
          $$MembersTableUpdateCompanionBuilder,
          (MemberRow, BaseReferences<_$AppDatabase, $MembersTable, MemberRow>),
          MemberRow,
          PrefetchHooks Function()
        > {
  $$MembersTableTableManager(_$AppDatabase db, $MembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> photoFile = const Value.absent(),
                Value<String?> mobileNumber = const Value.absent(),
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> addedBy = const Value.absent(),
                Value<String?> rfidCardId = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> emergencyContact = const Value.absent(),
                Value<String?> branch = const Value.absent(),
                Value<DateTime?> created = const Value.absent(),
                Value<DateTime?> updated = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> localPhotoPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion(
                id: id,
                name: name,
                photoFile: photoFile,
                mobileNumber: mobileNumber,
                dateOfBirth: dateOfBirth,
                address: address,
                sex: sex,
                remarks: remarks,
                addedBy: addedBy,
                rfidCardId: rfidCardId,
                email: email,
                emergencyContact: emergencyContact,
                branch: branch,
                created: created,
                updated: updated,
                syncedAt: syncedAt,
                syncStatus: syncStatus,
                localPhotoPath: localPhotoPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> photoFile = const Value.absent(),
                Value<String?> mobileNumber = const Value.absent(),
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<String?> addedBy = const Value.absent(),
                Value<String?> rfidCardId = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> emergencyContact = const Value.absent(),
                Value<String?> branch = const Value.absent(),
                Value<DateTime?> created = const Value.absent(),
                Value<DateTime?> updated = const Value.absent(),
                required DateTime syncedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<String?> localPhotoPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembersCompanion.insert(
                id: id,
                name: name,
                photoFile: photoFile,
                mobileNumber: mobileNumber,
                dateOfBirth: dateOfBirth,
                address: address,
                sex: sex,
                remarks: remarks,
                addedBy: addedBy,
                rfidCardId: rfidCardId,
                email: email,
                emergencyContact: emergencyContact,
                branch: branch,
                created: created,
                updated: updated,
                syncedAt: syncedAt,
                syncStatus: syncStatus,
                localPhotoPath: localPhotoPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MembersTable,
      MemberRow,
      $$MembersTableFilterComposer,
      $$MembersTableOrderingComposer,
      $$MembersTableAnnotationComposer,
      $$MembersTableCreateCompanionBuilder,
      $$MembersTableUpdateCompanionBuilder,
      (MemberRow, BaseReferences<_$AppDatabase, $MembersTable, MemberRow>),
      MemberRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxEntriesTableCreateCompanionBuilder =
    OutboxEntriesCompanion Function({
      required String id,
      required String entityType,
      required String operation,
      required String payload,
      required String clientRecordId,
      Value<String?> dependsOnId,
      Value<String> status,
      required DateTime createdAt,
      Value<int> attempts,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$OutboxEntriesTableUpdateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> operation,
      Value<String> payload,
      Value<String> clientRecordId,
      Value<String?> dependsOnId,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> attempts,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$OutboxEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientRecordId => $composableBuilder(
    column: $table.clientRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dependsOnId => $composableBuilder(
    column: $table.dependsOnId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientRecordId => $composableBuilder(
    column: $table.clientRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dependsOnId => $composableBuilder(
    column: $table.dependsOnId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get clientRecordId => $composableBuilder(
    column: $table.clientRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dependsOnId => $composableBuilder(
    column: $table.dependsOnId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$OutboxEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxEntriesTable,
          OutboxEntryRow,
          $$OutboxEntriesTableFilterComposer,
          $$OutboxEntriesTableOrderingComposer,
          $$OutboxEntriesTableAnnotationComposer,
          $$OutboxEntriesTableCreateCompanionBuilder,
          $$OutboxEntriesTableUpdateCompanionBuilder,
          (
            OutboxEntryRow,
            BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntryRow>,
          ),
          OutboxEntryRow,
          PrefetchHooks Function()
        > {
  $$OutboxEntriesTableTableManager(_$AppDatabase db, $OutboxEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> clientRecordId = const Value.absent(),
                Value<String?> dependsOnId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxEntriesCompanion(
                id: id,
                entityType: entityType,
                operation: operation,
                payload: payload,
                clientRecordId: clientRecordId,
                dependsOnId: dependsOnId,
                status: status,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String operation,
                required String payload,
                required String clientRecordId,
                Value<String?> dependsOnId = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxEntriesCompanion.insert(
                id: id,
                entityType: entityType,
                operation: operation,
                payload: payload,
                clientRecordId: clientRecordId,
                dependsOnId: dependsOnId,
                status: status,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxEntriesTable,
      OutboxEntryRow,
      $$OutboxEntriesTableFilterComposer,
      $$OutboxEntriesTableOrderingComposer,
      $$OutboxEntriesTableAnnotationComposer,
      $$OutboxEntriesTableCreateCompanionBuilder,
      $$OutboxEntriesTableUpdateCompanionBuilder,
      (
        OutboxEntryRow,
        BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntryRow>,
      ),
      OutboxEntryRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxAttachmentsTableCreateCompanionBuilder =
    OutboxAttachmentsCompanion Function({
      required String outboxId,
      required String filename,
      required Uint8List bytes,
      Value<int> rowid,
    });
typedef $$OutboxAttachmentsTableUpdateCompanionBuilder =
    OutboxAttachmentsCompanion Function({
      Value<String> outboxId,
      Value<String> filename,
      Value<Uint8List> bytes,
      Value<int> rowid,
    });

class $$OutboxAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxAttachmentsTable> {
  $$OutboxAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get outboxId => $composableBuilder(
    column: $table.outboxId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxAttachmentsTable> {
  $$OutboxAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get outboxId => $composableBuilder(
    column: $table.outboxId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxAttachmentsTable> {
  $$OutboxAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get outboxId =>
      $composableBuilder(column: $table.outboxId, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);
}

class $$OutboxAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxAttachmentsTable,
          OutboxAttachmentRow,
          $$OutboxAttachmentsTableFilterComposer,
          $$OutboxAttachmentsTableOrderingComposer,
          $$OutboxAttachmentsTableAnnotationComposer,
          $$OutboxAttachmentsTableCreateCompanionBuilder,
          $$OutboxAttachmentsTableUpdateCompanionBuilder,
          (
            OutboxAttachmentRow,
            BaseReferences<
              _$AppDatabase,
              $OutboxAttachmentsTable,
              OutboxAttachmentRow
            >,
          ),
          OutboxAttachmentRow,
          PrefetchHooks Function()
        > {
  $$OutboxAttachmentsTableTableManager(
    _$AppDatabase db,
    $OutboxAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> outboxId = const Value.absent(),
                Value<String> filename = const Value.absent(),
                Value<Uint8List> bytes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxAttachmentsCompanion(
                outboxId: outboxId,
                filename: filename,
                bytes: bytes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String outboxId,
                required String filename,
                required Uint8List bytes,
                Value<int> rowid = const Value.absent(),
              }) => OutboxAttachmentsCompanion.insert(
                outboxId: outboxId,
                filename: filename,
                bytes: bytes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxAttachmentsTable,
      OutboxAttachmentRow,
      $$OutboxAttachmentsTableFilterComposer,
      $$OutboxAttachmentsTableOrderingComposer,
      $$OutboxAttachmentsTableAnnotationComposer,
      $$OutboxAttachmentsTableCreateCompanionBuilder,
      $$OutboxAttachmentsTableUpdateCompanionBuilder,
      (
        OutboxAttachmentRow,
        BaseReferences<
          _$AppDatabase,
          $OutboxAttachmentsTable,
          OutboxAttachmentRow
        >,
      ),
      OutboxAttachmentRow,
      PrefetchHooks Function()
    >;
typedef $$PendingMemberMembershipsTableCreateCompanionBuilder =
    PendingMemberMembershipsCompanion Function({
      required String id,
      required String memberId,
      required String membershipId,
      required String planName,
      required DateTime startDate,
      required DateTime endDate,
      required String status,
      Value<String?> saleId,
      Value<String> syncStatus,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PendingMemberMembershipsTableUpdateCompanionBuilder =
    PendingMemberMembershipsCompanion Function({
      Value<String> id,
      Value<String> memberId,
      Value<String> membershipId,
      Value<String> planName,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<String> status,
      Value<String?> saleId,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PendingMemberMembershipsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingMemberMembershipsTable> {
  $$PendingMemberMembershipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get membershipId => $composableBuilder(
    column: $table.membershipId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planName => $composableBuilder(
    column: $table.planName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingMemberMembershipsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingMemberMembershipsTable> {
  $$PendingMemberMembershipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get membershipId => $composableBuilder(
    column: $table.membershipId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planName => $composableBuilder(
    column: $table.planName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingMemberMembershipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingMemberMembershipsTable> {
  $$PendingMemberMembershipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get membershipId => $composableBuilder(
    column: $table.membershipId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planName =>
      $composableBuilder(column: $table.planName, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingMemberMembershipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingMemberMembershipsTable,
          PendingMemberMembershipRow,
          $$PendingMemberMembershipsTableFilterComposer,
          $$PendingMemberMembershipsTableOrderingComposer,
          $$PendingMemberMembershipsTableAnnotationComposer,
          $$PendingMemberMembershipsTableCreateCompanionBuilder,
          $$PendingMemberMembershipsTableUpdateCompanionBuilder,
          (
            PendingMemberMembershipRow,
            BaseReferences<
              _$AppDatabase,
              $PendingMemberMembershipsTable,
              PendingMemberMembershipRow
            >,
          ),
          PendingMemberMembershipRow,
          PrefetchHooks Function()
        > {
  $$PendingMemberMembershipsTableTableManager(
    _$AppDatabase db,
    $PendingMemberMembershipsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingMemberMembershipsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PendingMemberMembershipsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PendingMemberMembershipsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<String> membershipId = const Value.absent(),
                Value<String> planName = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> saleId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingMemberMembershipsCompanion(
                id: id,
                memberId: memberId,
                membershipId: membershipId,
                planName: planName,
                startDate: startDate,
                endDate: endDate,
                status: status,
                saleId: saleId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String memberId,
                required String membershipId,
                required String planName,
                required DateTime startDate,
                required DateTime endDate,
                required String status,
                Value<String?> saleId = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PendingMemberMembershipsCompanion.insert(
                id: id,
                memberId: memberId,
                membershipId: membershipId,
                planName: planName,
                startDate: startDate,
                endDate: endDate,
                status: status,
                saleId: saleId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingMemberMembershipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingMemberMembershipsTable,
      PendingMemberMembershipRow,
      $$PendingMemberMembershipsTableFilterComposer,
      $$PendingMemberMembershipsTableOrderingComposer,
      $$PendingMemberMembershipsTableAnnotationComposer,
      $$PendingMemberMembershipsTableCreateCompanionBuilder,
      $$PendingMemberMembershipsTableUpdateCompanionBuilder,
      (
        PendingMemberMembershipRow,
        BaseReferences<
          _$AppDatabase,
          $PendingMemberMembershipsTable,
          PendingMemberMembershipRow
        >,
      ),
      PendingMemberMembershipRow,
      PrefetchHooks Function()
    >;
typedef $$MembershipPlansTableCreateCompanionBuilder =
    MembershipPlansCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      required int durationDays,
      required double price,
      required String branchId,
      Value<String> validBranchesJson,
      Value<bool> isActive,
      Value<bool> isFavorite,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$MembershipPlansTableUpdateCompanionBuilder =
    MembershipPlansCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<int> durationDays,
      Value<double> price,
      Value<String> branchId,
      Value<String> validBranchesJson,
      Value<bool> isActive,
      Value<bool> isFavorite,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$MembershipPlansTableFilterComposer
    extends Composer<_$AppDatabase, $MembershipPlansTable> {
  $$MembershipPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get validBranchesJson => $composableBuilder(
    column: $table.validBranchesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MembershipPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $MembershipPlansTable> {
  $$MembershipPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchId => $composableBuilder(
    column: $table.branchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validBranchesJson => $composableBuilder(
    column: $table.validBranchesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MembershipPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembershipPlansTable> {
  $$MembershipPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get validBranchesJson => $composableBuilder(
    column: $table.validBranchesJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$MembershipPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MembershipPlansTable,
          MembershipPlanRow,
          $$MembershipPlansTableFilterComposer,
          $$MembershipPlansTableOrderingComposer,
          $$MembershipPlansTableAnnotationComposer,
          $$MembershipPlansTableCreateCompanionBuilder,
          $$MembershipPlansTableUpdateCompanionBuilder,
          (
            MembershipPlanRow,
            BaseReferences<
              _$AppDatabase,
              $MembershipPlansTable,
              MembershipPlanRow
            >,
          ),
          MembershipPlanRow,
          PrefetchHooks Function()
        > {
  $$MembershipPlansTableTableManager(
    _$AppDatabase db,
    $MembershipPlansTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembershipPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembershipPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembershipPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> durationDays = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<String> branchId = const Value.absent(),
                Value<String> validBranchesJson = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembershipPlansCompanion(
                id: id,
                name: name,
                description: description,
                durationDays: durationDays,
                price: price,
                branchId: branchId,
                validBranchesJson: validBranchesJson,
                isActive: isActive,
                isFavorite: isFavorite,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                required int durationDays,
                required double price,
                required String branchId,
                Value<String> validBranchesJson = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => MembershipPlansCompanion.insert(
                id: id,
                name: name,
                description: description,
                durationDays: durationDays,
                price: price,
                branchId: branchId,
                validBranchesJson: validBranchesJson,
                isActive: isActive,
                isFavorite: isFavorite,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MembershipPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MembershipPlansTable,
      MembershipPlanRow,
      $$MembershipPlansTableFilterComposer,
      $$MembershipPlansTableOrderingComposer,
      $$MembershipPlansTableAnnotationComposer,
      $$MembershipPlansTableCreateCompanionBuilder,
      $$MembershipPlansTableUpdateCompanionBuilder,
      (
        MembershipPlanRow,
        BaseReferences<_$AppDatabase, $MembershipPlansTable, MembershipPlanRow>,
      ),
      MembershipPlanRow,
      PrefetchHooks Function()
    >;
typedef $$MembershipAddOnsCacheTableCreateCompanionBuilder =
    MembershipAddOnsCacheCompanion Function({
      required String id,
      required String membershipId,
      required String name,
      Value<String?> description,
      required double price,
      Value<bool> isActive,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$MembershipAddOnsCacheTableUpdateCompanionBuilder =
    MembershipAddOnsCacheCompanion Function({
      Value<String> id,
      Value<String> membershipId,
      Value<String> name,
      Value<String?> description,
      Value<double> price,
      Value<bool> isActive,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$MembershipAddOnsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $MembershipAddOnsCacheTable> {
  $$MembershipAddOnsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get membershipId => $composableBuilder(
    column: $table.membershipId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MembershipAddOnsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $MembershipAddOnsCacheTable> {
  $$MembershipAddOnsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get membershipId => $composableBuilder(
    column: $table.membershipId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MembershipAddOnsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembershipAddOnsCacheTable> {
  $$MembershipAddOnsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get membershipId => $composableBuilder(
    column: $table.membershipId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$MembershipAddOnsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MembershipAddOnsCacheTable,
          MembershipAddOnRow,
          $$MembershipAddOnsCacheTableFilterComposer,
          $$MembershipAddOnsCacheTableOrderingComposer,
          $$MembershipAddOnsCacheTableAnnotationComposer,
          $$MembershipAddOnsCacheTableCreateCompanionBuilder,
          $$MembershipAddOnsCacheTableUpdateCompanionBuilder,
          (
            MembershipAddOnRow,
            BaseReferences<
              _$AppDatabase,
              $MembershipAddOnsCacheTable,
              MembershipAddOnRow
            >,
          ),
          MembershipAddOnRow,
          PrefetchHooks Function()
        > {
  $$MembershipAddOnsCacheTableTableManager(
    _$AppDatabase db,
    $MembershipAddOnsCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembershipAddOnsCacheTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MembershipAddOnsCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MembershipAddOnsCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> membershipId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembershipAddOnsCacheCompanion(
                id: id,
                membershipId: membershipId,
                name: name,
                description: description,
                price: price,
                isActive: isActive,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String membershipId,
                required String name,
                Value<String?> description = const Value.absent(),
                required double price,
                Value<bool> isActive = const Value.absent(),
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => MembershipAddOnsCacheCompanion.insert(
                id: id,
                membershipId: membershipId,
                name: name,
                description: description,
                price: price,
                isActive: isActive,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MembershipAddOnsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MembershipAddOnsCacheTable,
      MembershipAddOnRow,
      $$MembershipAddOnsCacheTableFilterComposer,
      $$MembershipAddOnsCacheTableOrderingComposer,
      $$MembershipAddOnsCacheTableAnnotationComposer,
      $$MembershipAddOnsCacheTableCreateCompanionBuilder,
      $$MembershipAddOnsCacheTableUpdateCompanionBuilder,
      (
        MembershipAddOnRow,
        BaseReferences<
          _$AppDatabase,
          $MembershipAddOnsCacheTable,
          MembershipAddOnRow
        >,
      ),
      MembershipAddOnRow,
      PrefetchHooks Function()
    >;
typedef $$AppPreferencesTableCreateCompanionBuilder =
    AppPreferencesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppPreferencesTableUpdateCompanionBuilder =
    AppPreferencesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppPreferencesTable,
          AppPreferenceRow,
          $$AppPreferencesTableFilterComposer,
          $$AppPreferencesTableOrderingComposer,
          $$AppPreferencesTableAnnotationComposer,
          $$AppPreferencesTableCreateCompanionBuilder,
          $$AppPreferencesTableUpdateCompanionBuilder,
          (
            AppPreferenceRow,
            BaseReferences<
              _$AppDatabase,
              $AppPreferencesTable,
              AppPreferenceRow
            >,
          ),
          AppPreferenceRow,
          PrefetchHooks Function()
        > {
  $$AppPreferencesTableTableManager(
    _$AppDatabase db,
    $AppPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppPreferencesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppPreferencesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppPreferencesTable,
      AppPreferenceRow,
      $$AppPreferencesTableFilterComposer,
      $$AppPreferencesTableOrderingComposer,
      $$AppPreferencesTableAnnotationComposer,
      $$AppPreferencesTableCreateCompanionBuilder,
      $$AppPreferencesTableUpdateCompanionBuilder,
      (
        AppPreferenceRow,
        BaseReferences<_$AppDatabase, $AppPreferencesTable, AppPreferenceRow>,
      ),
      AppPreferenceRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
  $$OutboxEntriesTableTableManager get outboxEntries =>
      $$OutboxEntriesTableTableManager(_db, _db.outboxEntries);
  $$OutboxAttachmentsTableTableManager get outboxAttachments =>
      $$OutboxAttachmentsTableTableManager(_db, _db.outboxAttachments);
  $$PendingMemberMembershipsTableTableManager get pendingMemberMemberships =>
      $$PendingMemberMembershipsTableTableManager(
        _db,
        _db.pendingMemberMemberships,
      );
  $$MembershipPlansTableTableManager get membershipPlans =>
      $$MembershipPlansTableTableManager(_db, _db.membershipPlans);
  $$MembershipAddOnsCacheTableTableManager get membershipAddOnsCache =>
      $$MembershipAddOnsCacheTableTableManager(_db, _db.membershipAddOnsCache);
  $$AppPreferencesTableTableManager get appPreferences =>
      $$AppPreferencesTableTableManager(_db, _db.appPreferences);
}
