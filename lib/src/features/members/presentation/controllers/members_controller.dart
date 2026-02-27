import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/member_repository.dart';
import '../../domain/member.dart';

part 'members_controller.g.dart';

/// Controller for managing the list of members.
@Riverpod(keepAlive: true)
class MembersController extends _$MembersController {
  MemberRepository get _repository => ref.read(memberRepositoryProvider);

  @override
  Future<List<Member>> build() async {
    final result = await _repository.fetchAll();

    return result.fold(
      (failure) => throw failure,
      (members) => members,
    );
  }

  /// Refreshes the member list.
  Future<void> refresh() async {
    _repository.invalidateCache();
    state = const AsyncLoading();

    final result = await _repository.fetchAll();

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (members) => AsyncData(members),
    );
  }

  /// Creates a new member.
  Future<Member?> createMember(Member member) async {
    final result = await _repository.create(member);
    return result.fold(
      (failure) => null,
      (created) {
        refresh();
        return created;
      },
    );
  }

  /// Creates a new member with an optional photo.
  Future<Member?> createMemberWithPhoto(
    Member member, {
    http.MultipartFile? photo,
  }) async {
    final result = await _repository.createWithPhoto(member, photo: photo);
    return result.fold(
      (failure) => null,
      (created) {
        refresh();
        return created;
      },
    );
  }

  /// Updates an existing member.
  Future<bool> updateMember(Member member) async {
    final result = await _repository.update(member);
    return result.fold(
      (failure) => false,
      (updated) {
        refresh();
        return true;
      },
    );
  }

  /// Deletes a member.
  Future<bool> deleteMember(String id) async {
    final result = await _repository.delete(id);
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }
}
