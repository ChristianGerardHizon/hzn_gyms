import 'package:flutter/material.dart';

import '../../../../core/widgets/cached_avatar.dart';
import '../../../memberships/domain/member_branch_activity.dart';
import '../../domain/member.dart';
import 'member_branch_activity_chips.dart';

/// Shared member row for the members list and member picker.
///
/// Layout mirrors [SaleListTile]:
/// avatar | name / phone + branch activity | pending sync.
class MemberListTile extends StatelessWidget {
  const MemberListTile({
    super.key,
    required this.member,
    required this.onTap,
    this.isSelected = false,
    this.showBranchActivity = true,
    this.activity,
    this.branchCodeById = const {},
    this.branchNameById = const {},
    this.branchColorById = const {},
    this.currentBranchId,
    this.isActivityLoading = false,
    this.contentPadding,
  });

  final Member member;
  final VoidCallback onTap;
  final bool isSelected;
  final bool showBranchActivity;
  final MemberBranchActivity? activity;
  final Map<String, String> branchCodeById;
  final Map<String, String> branchNameById;
  final Map<String, String> branchColorById;
  final String? currentBranchId;
  final bool isActivityLoading;
  final EdgeInsetsGeometry? contentPadding;

  /// Compact subtitle: phone number when present.
  static String? buildSubtitle(Member member) {
    final phone = member.mobileNumber?.trim();
    if (phone == null || phone.isEmpty) return null;
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = member.name;
    final subtitle = buildSubtitle(member);
    final showSubtitleRow = subtitle != null || showBranchActivity;

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              CachedAvatar(
                imageUrl: member.photo,
                radius: 20,
                thumbSize: 80,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tooltip(
                      message: title,
                      waitDuration: const Duration(milliseconds: 350),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (showSubtitleRow) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (subtitle != null)
                            Flexible(
                              child: Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          if (showBranchActivity) ...[
                            if (subtitle != null) const SizedBox(width: 6),
                            // Flexible so the chip block can shrink below 160 on
                            // narrow rows instead of overflowing the subtitle Row.
                            Flexible(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 160),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: MemberBranchActivityChips(
                                    activity: activity,
                                    branchCodeById: branchCodeById,
                                    branchNameById: branchNameById,
                                    branchColorById: branchColorById,
                                    currentBranchId: currentBranchId,
                                    isLoading: isActivityLoading,
                                    dense: true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (member.isPendingSync) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Pending sync',
                  child: Icon(
                    Icons.cloud_upload_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
