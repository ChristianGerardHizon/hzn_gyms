import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// A skeleton placeholder that mirrors the members list layout while the
/// initial page of data is loading.
///
/// Showing the list structure immediately makes the screen feel instant
/// compared to a blank full-screen spinner.
class MemberListSkeleton extends StatelessWidget {
  const MemberListSkeleton({super.key, this.itemCount = 12});

  /// Number of placeholder rows to render.
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header (matches MemberListPanel header)
        Container(
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Text('Members', style: theme.textTheme.titleLarge),
              const Spacer(),
              Skeletonizer(
                enabled: true,
                child: Text('000 total', style: theme.textTheme.bodySmall),
              ),
            ],
          ),
        ),

        // Search placeholder
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Skeletonizer(
            enabled: true,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search members...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
                filled: true,
              ),
            ),
          ),
        ),

        // Skeleton rows (mirrors MemberListTile)
        Expanded(
          child: Skeletonizer(
            enabled: true,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Member name placeholder'),
                            SizedBox(height: 2),
                            Text('0912 345 6789'),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        height: 18,
                        width: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0x14000000),
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
