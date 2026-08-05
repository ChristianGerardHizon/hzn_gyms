import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ListTile intermediate background', () {
    testWidgets(
      'ColoredBox between Material and ListTile triggers invisible-ink warning',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ColoredBox(
                color: Colors.grey.shade200,
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text('Item'),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final exception = tester.takeException();
        expect(exception, isA<FlutterError>());
        expect(
          exception.toString(),
          contains(
            'ListTile background color or ink splashes may be invisible',
          ),
        );
      },
    );

    testWidgets(
      'Scaffold.backgroundColor does not trigger invisible-ink warning',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.grey.shade200,
              body: ListView(
                children: [
                  ListTile(
                    title: const Text('Item'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Material color under ListTile does not trigger invisible-ink warning',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Material(
                color: Colors.grey.shade200,
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text('Item'),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );
  });
}
