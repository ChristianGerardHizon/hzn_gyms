import '../../../core/utils/search_tokens.dart';
import '../../sales/domain/open_unpaid_sale.dart';
import 'member.dart';

/// Max letter edits allowed when comparing member names.
const duplicateMatchMaxNameEdits = 3;

/// Max digit edits allowed when comparing phone numbers.
const duplicateMatchMaxPhoneEdits = 3;

/// How long the Next-step duplicate lookup may run before continuing as new.
const duplicateMemberLookupTimeout = Duration(seconds: 5);

/// Digits-only phone string for rough matching (strips spaces, dashes, +63, etc.).
///
/// Philippine mobiles are normalized to the national form without a leading `0`
/// (e.g. `+63 917…`, `0917…`, and `917…` all become `917…`).
String normalizePhoneDigits(String? phone) {
  if (phone == null) return '';
  var digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('63') && digits.length >= 12) {
    digits = digits.substring(2);
  }
  if (digits.startsWith('0') && digits.length >= 10) {
    digits = digits.substring(1);
  }
  return digits;
}

/// Normalized display name for duplicate checks (trim, lower, collapse spaces).
String normalizeMemberMatchName(String? name) => normalizeCustomerName(name);

/// Enough name + phone input to look up possible existing members.
bool isDuplicateMemberLookupReady({
  required String name,
  required String phone,
}) {
  final digits = normalizePhoneDigits(phone);
  final normalizedName = normalizeMemberMatchName(name);
  return normalizedName.length >= 2 && digits.length >= 7;
}

/// Levenshtein edit distance between two strings.
int stringEditDistance(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  final previous = List<int>.generate(b.length + 1, (i) => i);
  final current = List<int>.filled(b.length + 1, 0);

  for (var i = 0; i < a.length; i++) {
    current[0] = i + 1;
    for (var j = 0; j < b.length; j++) {
      final insertCost = current[j] + 1;
      final deleteCost = previous[j + 1] + 1;
      final replaceCost = previous[j] + (a[i] == b[j] ? 0 : 1);
      current[j + 1] = [
        insertCost,
        deleteCost,
        replaceCost,
      ].reduce((x, y) => x < y ? x : y);
    }
    for (var j = 0; j <= b.length; j++) {
      previous[j] = current[j];
    }
  }
  return previous[b.length];
}

/// Rough phone equality for PH-style numbers (with/without leading 0 or 63).
///
/// Matches exact/suffix variants, or up to [maxEdits] digit typos
/// (default [duplicateMatchMaxPhoneEdits]).
bool phonesRoughlyMatch(
  String? a,
  String? b, {
  int minDigits = 7,
  int maxEdits = duplicateMatchMaxPhoneEdits,
}) {
  final da = normalizePhoneDigits(a);
  final db = normalizePhoneDigits(b);
  if (da.length < minDigits || db.length < minDigits) return false;
  if (da == db) return true;
  if (da.endsWith(db) || db.endsWith(da)) return true;
  if ((da.length - db.length).abs() > maxEdits) return false;
  return stringEditDistance(da, db) <= maxEdits;
}

/// Rough name equality: exact, token rules, or up to [maxEdits] letter typos.
bool namesRoughlyMatch(
  String? a,
  String? b, {
  int maxEdits = duplicateMatchMaxNameEdits,
}) {
  final na = normalizeMemberMatchName(a);
  final nb = normalizeMemberMatchName(b);
  if (na.isEmpty || nb.isEmpty) return false;
  if (na == nb) return true;

  final ta = na.split(' ');
  final tb = nb.split(' ');

  // Typo tolerance on the full / compact name when both sides are long enough
  // (avoids "Jane" ≈ "Jane Doe" via three inserted letters).
  final canUseEdits = na.length >= 5 &&
      nb.length >= 5 &&
      (ta.length - tb.length).abs() <= 1;

  if (canUseEdits &&
      (na.length - nb.length).abs() <= maxEdits &&
      stringEditDistance(na, nb) <= maxEdits) {
    return true;
  }

  final compactA = na.replaceAll(' ', '');
  final compactB = nb.replaceAll(' ', '');
  if (canUseEdits &&
      compactA.length >= 5 &&
      compactB.length >= 5 &&
      (compactA.length - compactB.length).abs() <= maxEdits &&
      stringEditDistance(compactA, compactB) <= maxEdits) {
    return true;
  }

  if (ta.length >= 2 && tb.length >= 2) {
    if (ta.first == tb.first && ta.last == tb.last) return true;
    // First + last each within 1 edit, total within maxEdits.
    final firstDist = stringEditDistance(ta.first, tb.first);
    final lastDist = stringEditDistance(ta.last, tb.last);
    if (firstDist <= 1 &&
        lastDist <= 1 &&
        firstDist + lastDist <= maxEdits) {
      return true;
    }
  }

  final shorter = ta.length <= tb.length ? ta : tb;
  final longer = ta.length <= tb.length ? tb : ta;
  if (shorter.length >= 2 && shorter.every(longer.contains)) return true;

  return false;
}

/// True when entered name and phone both roughly match [candidate].
bool isLikelyDuplicateMember({
  required String enteredName,
  required String enteredPhone,
  required Member candidate,
}) {
  return namesRoughlyMatch(enteredName, candidate.name) &&
      phonesRoughlyMatch(enteredPhone, candidate.mobileNumber);
}

/// Filters [candidates] to those that roughly match entered name + phone.
///
/// Results are sorted with exact phone digit matches first, then by name.
List<Member> findLikelyDuplicateMembers({
  required String enteredName,
  required String enteredPhone,
  required Iterable<Member> candidates,
  int limit = 3,
}) {
  final enteredDigits = normalizePhoneDigits(enteredPhone);
  final enteredNormalizedName = normalizeMemberMatchName(enteredName);
  final matches = candidates
      .where(
        (m) => isLikelyDuplicateMember(
          enteredName: enteredName,
          enteredPhone: enteredPhone,
          candidate: m,
        ),
      )
      .toList();

  matches.sort((a, b) {
    final aExactPhone = normalizePhoneDigits(a.mobileNumber) == enteredDigits;
    final bExactPhone = normalizePhoneDigits(b.mobileNumber) == enteredDigits;
    if (aExactPhone != bExactPhone) return aExactPhone ? -1 : 1;

    final aExactName =
        normalizeMemberMatchName(a.name) == enteredNormalizedName;
    final bExactName =
        normalizeMemberMatchName(b.name) == enteredNormalizedName;
    if (aExactName != bExactName) return aExactName ? -1 : 1;

    final aNameDist = stringEditDistance(
      normalizeMemberMatchName(a.name),
      enteredNormalizedName,
    );
    final bNameDist = stringEditDistance(
      normalizeMemberMatchName(b.name),
      enteredNormalizedName,
    );
    if (aNameDist != bNameDist) return aNameDist.compareTo(bNameDist);

    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });

  if (matches.length <= limit) return matches;
  return matches.sublist(0, limit);
}

/// Broad queries so typo'd name/phone still retrieve nearby candidates.
List<String> duplicateMemberSearchQueries({
  required String name,
  required String phone,
}) {
  final queries = <String>{};
  final nameQuery = normalizeWhitespace(name);
  final phoneQuery = normalizePhoneDigits(phone);

  if (isMemberSearchQueryReady(nameQuery)) {
    queries.add(nameQuery);
    final tokens = splitSearchTokens(nameQuery);
    if (tokens.isNotEmpty) {
      final firstToken = tokens.first;
      if (firstToken.length >= 3) {
        queries.add(firstToken.substring(0, 3));
      } else if (isMemberSearchQueryReady(firstToken)) {
        queries.add(firstToken);
      }
    }
  }

  if (isMemberSearchQueryReady(phoneQuery)) {
    queries.add(phoneQuery);
    // Carrier / prefix slice so a few wrong trailing digits still hit.
    if (phoneQuery.length >= 4) {
      queries.add(phoneQuery.substring(0, 4));
    }
  }

  return queries.toList();
}

/// Searches by name and phone, then returns rough duplicates for the gate on Next.
///
/// Returns an empty list (continue as new) if [timeout] elapses before search
/// finishes — default [duplicateMemberLookupTimeout] (5 seconds).
Future<List<Member>> lookupLikelyDuplicateMembers({
  required String name,
  required String phone,
  required Future<List<Member>> Function(String query) search,
  Duration timeout = duplicateMemberLookupTimeout,
}) async {
  if (!isDuplicateMemberLookupReady(name: name, phone: phone)) {
    return const [];
  }

  Future<List<Member>> run() async {
    final byId = <String, Member>{};
    for (final query
        in duplicateMemberSearchQueries(name: name, phone: phone)) {
      final found = await search(query);
      for (final member in found) {
        byId[member.id] = member;
      }
    }

    return findLikelyDuplicateMembers(
      enteredName: name,
      enteredPhone: phone,
      candidates: byId.values,
    );
  }

  return run().timeout(timeout, onTimeout: () => const <Member>[]);
}

/// Form values used to pre-fill the create wizard from a selected existing member.
Map<String, dynamic> memberFormValuesFromMember(Member member) {
  return {
    'name': member.name,
    'mobileNumber': member.mobileNumber,
    'email': member.email,
    'dateOfBirth': member.dateOfBirth,
    'sex': member.sex,
    'address': member.address,
    'emergencyContact': member.emergencyContact,
    'remarks': member.remarks,
  };
}
