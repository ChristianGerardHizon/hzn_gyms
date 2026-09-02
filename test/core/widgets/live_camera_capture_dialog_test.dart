import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_gyms/src/core/utils/photo_capture_support.dart';
import 'package:hzn_gyms/src/core/widgets/live_camera_capture_dialog.dart';

void main() {
  testWidgets('shows title, cancel, and unsupported message without live camera',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LiveCameraCaptureDialog(
              title: 'Capture payment proof',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Capture payment proof'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    // Flutter test host is typically desktop — live camera unsupported.
    expect(
      find.text('Live camera is not supported on this device.'),
      findsOneWidget,
    );
  });

  testWidgets('Cancel pops the dialog without a result', (tester) async {
    CapturedPhoto? result;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showLiveCameraCaptureDialog(
                    context,
                    title: 'Capture payment proof',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Capture payment proof'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Capture payment proof'), findsNothing);
    expect(result, isNull);
  });
}
