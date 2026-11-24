import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stag_appbar/stag_appbar.dart';
import 'package:stag_sidebar_integration_example/main.dart';

void main() {
  testWidgets('switches layout, theme and navigation', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExamplePage()));
    expect(tester.widget<StagAppBarLayout>(find.byType(StagAppBarLayout)).mode,
        StagAppBarLayoutMode.aboveSidebar);

    await tester.tap(find.byTooltip('Toggle layout'));
    await tester.pumpAndSettle();
    expect(tester.widget<StagAppBarLayout>(find.byType(StagAppBarLayout)).mode,
        StagAppBarLayoutMode.besideSidebar);

    await tester.tap(find.byTooltip('Toggle theme'));
    await tester.pumpAndSettle();
    expect(tester.widget<StagAppBar>(find.byType(StagAppBar)).style.backgroundColor,
        const StagAppBarStyle.light().backgroundColor);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
