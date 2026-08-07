import 'package:flutter/material.dart';

import '../../../../core/widgets/cached_avatar.dart';
import '../../../memberships/domain/member_branch_activity.dart';
import '../../domain/member.dart';
import 'member_branch_activity_chips.dart';

/// Shared member row for the members list and member picker.
///
/// Layout: avatar + name/phone (flex) | branch activity chips | optional sync.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phone = member.mobileNumber?.trim();
    final hasPhone = phone != null && phone.isNotEmpty;

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CachedAvatar(
                imageUrl: member.photo,
                radius: 22,
                thumbSize: 88,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                    if (hasPhone) ...[
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showBranchActivity) ...[
                const SizedBox(width: 8),
                // Flexible so Wrap chips get bounded width inside Row
                // (unbounded Wrap layout can crash during scheduler passes).
                Flexible(
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
              ],
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
