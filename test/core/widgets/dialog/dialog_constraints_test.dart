import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/core/widgets/dialog/dialog_constraints.dart';

void main() {
  group('ConstrainedDialogContent', () {
    testWidgets('pins width on desktop', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConstrainedDialogContent(
              maxWidth: DialogConstraints.compactMaxWidth,
              child: SizedBox(height: 100, child: Text('content')),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(ConstrainedDialogContent));
      expect(size.width, DialogConstraints.compactMaxWidth);
      expect(size.width, lessThan(1400));
    });

    testWidgets('fills screen on mobile', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConstrainedDialogContent(
              maxWidth: DialogConstraints.compactMaxWidth,
              child: Text('content'),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(ConstrainedDialogContent));
      expect(size.width, 390);
      expect(size.height, 844);
    });
  });

  group('DialogConstraints.getInsetPadding', () {
    testWidgets('centers dialog on desktop', (tester) async {
      late EdgeInsets padding;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1400, 900)),
            child: Builder(
              builder: (context) {
                padding = DialogConstraints.getInsetPadding(
                  context,
                  maxWidth: DialogConstraints.compactMaxWidth,
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(padding.left, (1400 - 500) / 2);
      expect(padding.right, (1400 - 500) / 2);
      expect(padding.vertical, 48);
    });
  });
}
