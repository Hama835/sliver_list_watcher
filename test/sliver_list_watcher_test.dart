import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_list_watcher/sliver_list_watcher.dart';

void main() {
  testWidgets('SliverListWatcher should render correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      SliverListWatcher(
        onScrollEnd: () {},
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item $index'),
          );
        },
        itemCount: 10,
        topWidgets: const [
          Text('Top Widget 1'),
          Text('Top Widget 2'),
        ],
        loadingWidget: const CircularProgressIndicator(),
      ),
    );

    expect(find.text('Top Widget 1'), findsOneWidget);
    expect(find.text('Top Widget 2'), findsOneWidget);
    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 9'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('SliverListWatcher should trigger onScrollEnd callback',
      (WidgetTester tester) async {
    bool onScrollEndTriggered = false;

    await tester.pumpWidget(
      SliverListWatcher(
        onScrollEnd: () {
          onScrollEndTriggered = true;
        },
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item $index'),
          );
        },
        itemCount: 10,
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(onScrollEndTriggered, isTrue);
  });
}
