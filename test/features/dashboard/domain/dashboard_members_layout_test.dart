import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/dashboard/domain/dashboard_members_layout.dart';

void main() {
  group('DashboardMembersLayout', () {
    test('defaults to 4 columns with photo', () {
      const layout = DashboardMembersLayout();
      expect(layout.columns, 4);
      expect(layout.showPhoto, isTrue);
      expect(layout.childAspectRatio, 0.75);
    });

    test('name-only mode uses denser aspect ratio', () {
      expect(
        DashboardMembersLayout.childAspectRatioFor(showPhoto: false),
        2.8,
      );
      expect(
        const DashboardMembersLayout(showPhoto: false).childAspectRatio,
        2.8,
      );
    });

    test('clampColumns accepts allowed values and rejects others', () {
      for (final count in DashboardMembersLayout.allowedColumns) {
        expect(DashboardMembersLayout.clampColumns(count), count);
      }
      expect(DashboardMembersLayout.clampColumns(0), 4);
      expect(DashboardMembersLayout.clampColumns(6), 4);
    });

    test('copyWith clamps columns and updates showPhoto', () {
      const layout = DashboardMembersLayout();
      final next = layout.copyWith(columns: 3, showPhoto: false);
      expect(next.columns, 3);
      expect(next.showPhoto, isFalse);

      final single = layout.copyWith(columns: 1);
      expect(single.columns, 1);

      final clamped = layout.copyWith(columns: 9);
      expect(clamped.columns, 4);
      expect(clamped.showPhoto, isTrue);
    });

    test('equality is based on columns and showPhoto', () {
      expect(
        const DashboardMembersLayout(columns: 3, showPhoto: false),
        const DashboardMembersLayout(columns: 3, showPhoto: false),
      );
      expect(
        const DashboardMembersLayout(columns: 3),
        isNot(const DashboardMembersLayout(columns: 4)),
      );
    });

    group('allowedColumnsForWidth', () {
      test('mobile offers 1–2', () {
        expect(
          DashboardMembersLayout.allowedColumnsForWidth(375),
          [1, 2],
        );
        expect(
          DashboardMembersLayout.allowedColumnsForWidth(599),
          [1, 2],
        );
      });

      test('tablet medium offers 2–3', () {
        expect(
          DashboardMembersLayout.allowedColumnsForWidth(600),
          [2, 3],
        );
        expect(
          DashboardMembersLayout.allowedColumnsForWidth(899),
          [2, 3],
        );
      });

      test('tablet large offers 2–4', () {
        expect(
          DashboardMembersLayout.allowedColumnsForWidth(900),
          [2, 3, 4],
        );
        expect(
          DashboardMembersLayout.allowedColumnsForWidth(1199),
          [2, 3, 4],
        );
      });

      test('desktop offers 2–5', () {
        expect(
          DashboardMembersLayout.allowedColumnsForWidth(1200),
          [2, 3, 4, 5],
        );
      });
    });

    group('resolveColumns', () {
      test('keeps preferred when it fits the width', () {
        expect(
          DashboardMembersLayout.resolveColumns(preferred: 2, width: 375),
          2,
        );
        expect(
          DashboardMembersLayout.resolveColumns(preferred: 5, width: 1400),
          5,
        );
      });

      test('caps preferred when wider than the screen allows', () {
        expect(
          DashboardMembersLayout.resolveColumns(preferred: 5, width: 375),
          2,
        );
        expect(
          DashboardMembersLayout.resolveColumns(preferred: 4, width: 700),
          3,
        );
        expect(
          DashboardMembersLayout.resolveColumns(preferred: 5, width: 1000),
          4,
        );
      });

      test('raises preferred when narrower than the screen minimum', () {
        expect(
          DashboardMembersLayout.resolveColumns(preferred: 1, width: 800),
          2,
        );
      });

      test('effectiveColumnsForWidth uses preferred columns', () {
        const layout = DashboardMembersLayout(columns: 5);
        expect(layout.effectiveColumnsForWidth(375), 2);
        expect(layout.effectiveColumnsForWidth(1400), 5);
      });
    });
  });
}
