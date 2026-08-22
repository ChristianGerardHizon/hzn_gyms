import 'package:kylie_gym/src/core/hooks/use_infinite_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'does not throw when post-frame check runs before content dimensions',
    (tester) async {
      var loadMoreCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: HookBuilder(
            builder: (context) {
              final controller = useInfiniteScroll(
                onLoadMore: () => loadMoreCalls++,
                hasMore: true,
                isLoading: false,
              );
              return ListView(
                controller: controller,
                children: const [
                  SizedBox(height: 2000, child: Text('tall content')),
                ],
              );
            },
          ),
        ),
      );

      // First pump schedules the post-frame callback; second runs it.
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(loadMoreCalls, 0);
    },
  );

  testWidgets('loads more when scrolled near the bottom', (tester) async {
    var loadMoreCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: HookBuilder(
          builder: (context) {
            final controller = useInfiniteScroll(
              onLoadMore: () => loadMoreCalls++,
              hasMore: true,
              isLoading: false,
              threshold: 200,
            );
            return SizedBox(
              height: 300,
              child: ListView(
                controller: controller,
                children: List.generate(
                  20,
                  (i) => SizedBox(height: 100, child: Text('item $i')),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    await tester.drag(find.byType(ListView), const Offset(0, -1500));
    await tester.pump();

    expect(loadMoreCalls, greaterThan(0));
  });

  testWidgets('skips load when already loading or hasMore is false', (
    tester,
  ) async {
    var loadMoreCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: HookBuilder(
          builder: (context) {
            final controller = useInfiniteScroll(
              onLoadMore: () => loadMoreCalls++,
              hasMore: false,
              isLoading: false,
            );
            return SizedBox(
              height: 300,
              child: ListView(
                controller: controller,
                children: List.generate(
                  20,
                  (i) => SizedBox(height: 100, child: Text('item $i')),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -1500));
    await tester.pump();

    expect(loadMoreCalls, 0);
  });
}
