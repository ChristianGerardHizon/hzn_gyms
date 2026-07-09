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
    created,
    updated,
    syncedAt,
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
  final DateTime? created;
  final DateTime? updated;
  final DateTime syncedAt;
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
    this.created,
    this.updated,
    required this.syncedAt,
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
    if (!nullToAbsent || created != null) {
      map['created'] = Variable<DateTime>(created);
    }
    if (!nullToAbsent || updated != null) {
      map['updated'] = Variable<DateTime>(updated);
    }
    map['synced_at'] = Variable<DateTime>(syncedAt);
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
      created: created == null && nullToAbsent
          ? const Value.absent()
          : Value(created),
      updated: updated == null && nullToAbsent
          ? const Value.absent()
          : Value(updated),
      syncedAt: Value(syncedAt),
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
      created: serializer.fromJson<DateTime?>(json['created']),
      updated: serializer.fromJson<DateTime?>(json['updated']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
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
      'created': serializer.toJson<DateTime?>(created),
      'updated': serializer.toJson<DateTime?>(updated),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
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
    Value<DateTime?> created = const Value.absent(),
    Value<DateTime?> updated = const Value.absent(),
    DateTime? syncedAt,
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
    created: created.present ? created.value : this.created,
    updated: updated.present ? updated.value : this.updated,
    syncedAt: syncedAt ?? this.syncedAt,
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
      created: data.created.present ? data.created.value : this.created,
      updated: data.updated.present ? data.updated.value : this.updated,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
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
          ..write('created: $created, ')
          ..write('updated: $updated, ')
          ..write('syncedAt: $syncedAt')
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
    created,
    updated,
    syncedAt,
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
          other.created == this.created &&
          other.updated == this.updated &&
          other.syncedAt == this.syncedAt);
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
  final Value<DateTime?> created;
  final Value<DateTime?> updated;
  final Value<DateTime> syncedAt;
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
    this.created = const Value.absent(),
    this.updated = const Value.absent(),
    this.syncedAt = const Value.absent(),
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
    this.created = const Value.absent(),
    this.updated = const Value.absent(),
    required DateTime syncedAt,
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
    Expression<DateTime>? created,
    Expression<DateTime>? updated,
    Expression<DateTime>? syncedAt,
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
      if (created != null) 'created': created,
      if (updated != null) 'updated': updated,
      if (syncedAt != null) 'synced_at': syncedAt,
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
    Value<DateTime?>? created,
    Value<DateTime?>? updated,
    Value<DateTime>? syncedAt,
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
      created: created ?? this.created,
      updated: updated ?? this.updated,
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
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (updated.present) {
      map['updated'] = Variable<DateTime>(updated.value);
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
          ..write('created: $created, ')
          ..write('updated: $updated, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MembersTable members = $MembersTable(this);
  late final MembersDao membersDao = MembersDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [members];
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
      Value<DateTime?> created,
      Value<DateTime?> updated,
      required DateTime syncedAt,
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
      Value<DateTime?> created,
      Value<DateTime?> updated,
      Value<DateTime> syncedAt,
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

  GeneratedColumn<DateTime> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);

  GeneratedColumn<DateTime> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
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
                Value<DateTime?> created = const Value.absent(),
                Value<DateTime?> updated = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
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
                created: created,
                updated: updated,
                syncedAt: syncedAt,
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
                Value<DateTime?> created = const Value.absent(),
                Value<DateTime?> updated = const Value.absent(),
                required DateTime syncedAt,
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
                created: created,
                updated: updated,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
}
