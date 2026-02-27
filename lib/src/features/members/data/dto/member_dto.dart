import 'package:dart_mappable/dart_mappable.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/member.dart';

part 'member_dto.mapper.dart';

/// Data Transfer Object for Member from PocketBase.
@MappableClass()
class MemberDto with MemberDtoMappable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String name;
  final String? photo;
  final String? mobileNumber;
  final String? dateOfBirth;
  final String? address;
  final String? sex;
  final String? remarks;
  final String? addedBy;
  final String? rfidCardId;
  final String? email;
  final String? emergencyContact;
  final String? created;
  final String? updated;

  const MemberDto({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.name,
    this.photo,
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
  });

  /// Creates a DTO from a PocketBase RecordModel.
  factory MemberDto.fromRecord(RecordModel record) {
    return MemberDto(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      name: record.getStringValue('name'),
      photo: record.getStringValue('photo'),
      mobileNumber: record.getStringValue('mobileNumber'),
      dateOfBirth: record.get<String>('dateOfBirth'),
      address: record.getStringValue('address'),
      sex: record.getStringValue('sex'),
      remarks: record.getStringValue('remarks'),
      addedBy: record.getStringValue('addedBy'),
      rfidCardId: record.getStringValue('rfidCardId'),
      email: record.getStringValue('email'),
      emergencyContact: record.getStringValue('emergencyContact'),
      created: record.get<String>('created'),
      updated: record.get<String>('updated'),
    );
  }

  /// Converts the DTO to a domain Member entity.
  Member toEntity({String? baseUrl}) {
    return Member(
      id: id,
      name: name,
      photo: _buildPhotoUrl(baseUrl),
      mobileNumber:
          mobileNumber != null && mobileNumber!.isNotEmpty ? mobileNumber : null,
      dateOfBirth: parseToLocal(dateOfBirth),
      address: address != null && address!.isNotEmpty ? address : null,
      sex: _parseSex(sex),
      remarks: remarks != null && remarks!.isNotEmpty ? remarks : null,
      addedBy: addedBy != null && addedBy!.isNotEmpty ? addedBy : null,
      rfidCardId:
          rfidCardId != null && rfidCardId!.isNotEmpty ? rfidCardId : null,
      email: email != null && email!.isNotEmpty ? email : null,
      emergencyContact: emergencyContact != null && emergencyContact!.isNotEmpty
          ? emergencyContact
          : null,
      created: parseToLocal(created),
      updated: parseToLocal(updated),
    );
  }

  String? _buildPhotoUrl(String? baseUrl) {
    if (photo == null || photo!.isEmpty || baseUrl == null) return null;
    final url = '$baseUrl/api/files/$collectionName/$id/$photo';
    // Append updated timestamp to bust CachedNetworkImage cache on re-upload
    if (updated != null && updated!.isNotEmpty) {
      return '$url?t=$updated';
    }
    return url;
  }

  static MemberSex? _parseSex(String? value) {
    if (value == null || value.isEmpty) return null;
    switch (value.toLowerCase()) {
      case 'male':
        return MemberSex.male;
      case 'female':
        return MemberSex.female;
      case 'other':
        return MemberSex.other;
      default:
        return null;
    }
  }
}
