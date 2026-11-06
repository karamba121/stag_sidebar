import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stag_sidebar/stag_sidebar.dart';

void main() {
  testWidgets('submenu toggles, selects children and works in compact mode',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final semantics = tester.ensureSemantics();
    final selections = <String>[];
    var toggles = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Row(children: [
      StagSidebar(
        onItemSelected: selections.add,
        sections: [
          StagSidebarSection(items: [
            StagSidebarItem(
                id: 'swap',
                label: 'Swap',
                icon: Icons.swap_horiz,
                onTap: () => toggles++,
                children: const [
                  StagSidebarItem(
                      id: 'add', label: 'Add Liquidity', icon: Icons.add),
                  StagSidebarItem(
                      id: 'manage',
                      label: 'Manage Liquidity',
                      icon: Icons.tune),
                ]),
          ])
        ],
      ),
      const Expanded(child: SizedBox()),
    ]))));
    expect(find.text('Add Liquidity').hitTestable(), findsNothing);
    await tester.tap(find.text('Swap'));
    for (var frame = 0; frame < 12; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.takeException(), isNull);
    }
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Add Liquidity'), findsOneWidget);
    await tester.tap(find.text('Add Liquidity'));
    await tester.pumpAndSettle();
    expect(selections, ['add']);
    expect(toggles, 1);
    await tester.tap(find.byTooltip('Collapse sidebar'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Add Liquidity'), findsOneWidget);
    await tester.tap(find.byTooltip('Swap'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Add Liquidity').hitTestable(), findsNothing);
    await tester.tap(find.byTooltip('Swap'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Manage Liquidity'));
    await tester.pumpAndSettle();
    expect(selections, ['add', 'manage']);
    expect(toggles, 3);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('submenu supports initial expansion and reduced motion',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: Row(children: [
      MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: StagSidebar(
            sections: [
              StagSidebarSection(items: [
                StagSidebarItem(
                    id: 'parent',
                    label: 'Menu',
                    icon: Icons.menu,
                    initiallyExpanded: true,
                    children: [
                      StagSidebarItem(
                          id: 'child', label: 'Child', icon: Icons.star)
                    ]),
              ])
            ],
          )),
      Expanded(child: SizedBox()),
    ]))));
    expect(find.bySemanticsLabel('Child'), findsOneWidget);
    await tester.tap(find.text('Menu'));
    await tester.pump();
    expect(find.bySemanticsLabel('Child'), findsNothing);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('submenu animation can reverse while running', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: Row(children: [
      StagSidebar(sections: [
        StagSidebarSection(items: [
          StagSidebarItem(
              id: 'menu',
              label: 'Menu',
              icon: Icons.menu,
              children: [
                StagSidebarItem(id: 'child', label: 'Child', icon: Icons.star),
              ]),
        ])
      ]),
      Expanded(child: SizedBox()),
    ]))));
    await tester.tap(find.text('Menu'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Menu'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(find.text('Child').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 640), const Size(1200, 800)]) {
    testWidgets('animates both directions without overflow at $size',
        (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final changes = <bool>[];
      var actionCalls = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Row(children: [
          StagSidebar(
            onCollapsedChanged: changes.add,
            actions: [
              StagSidebarAction(
                  label: 'Share',
                  icon: Icons.share,
                  onPressed: () => actionCalls++)
            ],
            sections: const [
              StagSidebarSection(padding: EdgeInsets.all(6), items: [
                StagSidebarItem(
                    id: 'home', label: 'Dashboard', icon: Icons.home),
              ])
            ],
          ),
          const Expanded(child: SizedBox()),
        ])),
      ));
      await tester.tap(find.byTooltip('Collapse sidebar'));
      for (var frame = 0; frame < 12; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(StagSidebar)).width, closeTo(64, .1));
      await tester.tap(find.byTooltip('More actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Share'));
      await tester.pumpAndSettle();
      expect(actionCalls, 1);
      await tester.tap(find.byTooltip('Expand sidebar'));
      for (var frame = 0; frame < 12; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(StagSidebar)).width, closeTo(210, .1));
      expect(tester.getBottomLeft(find.byTooltip('Collapse sidebar')).dy,
          greaterThan(size.height - 60));
      expect(changes, [true, false]);
    });
  }

  testWidgets('reveals horizontal actions on hover and closes on exit',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Row(children: [
      StagSidebar(initiallyCollapsed: true, sections: const [], actions: [
        StagSidebarAction(label: 'First', icon: Icons.send, onPressed: () {}),
        StagSidebarAction(label: 'Second', icon: Icons.share, onPressed: () {}),
      ]),
      const Expanded(child: SizedBox()),
    ]))));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(300, 20));
    await tester.pump();
    await mouse.moveTo(tester.getCenter(find.byTooltip('More actions')));
    await tester.pumpAndSettle();
    final first = tester.getRect(find.byTooltip('First'));
    final second = tester.getRect(find.byTooltip('Second'));
    expect(second.left, greaterThan(first.right));
    expect(second.center.dy, closeTo(first.center.dy, .1));
    await mouse.moveTo(first.center);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byTooltip('First'), findsOneWidget);
    await mouse.moveTo(const Offset(300, 20));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byTooltip('First'), findsNothing);
    await mouse.removePointer();
  });

  testWidgets('opens actions on tap and keeps the strip inside a narrow screen',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var chosen = false;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Row(children: [
      const Spacer(),
      StagSidebar(initiallyCollapsed: true, sections: const [], actions: [
        StagSidebarAction(
            label: 'First', icon: Icons.send, onPressed: () => chosen = true),
        StagSidebarAction(label: 'Second', icon: Icons.share, onPressed: () {}),
        StagSidebarAction(label: 'Third', icon: Icons.star, onPressed: () {}),
        StagSidebarAction(
            label: 'Fourth', icon: Icons.favorite, onPressed: () {}),
      ]),
    ]))));
    final widthBefore = tester.getSize(find.byType(StagSidebar)).width;
    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    final first = tester.getRect(find.byTooltip('First'));
    final last = tester.getRect(find.byTooltip('Fourth'));
    expect(first.left, greaterThanOrEqualTo(0));
    expect(last.right, lessThanOrEqualTo(320));
    expect(tester.getSize(find.byType(StagSidebar)).width, widthBefore);
    await tester.tap(find.byTooltip('First'));
    await tester.pumpAndSettle();
    expect(chosen, isTrue);
    expect(find.byTooltip('First'), findsNothing);
    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Expand sidebar'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('More actions'), findsNothing);
    expect(
        tester
            .getRect(find.byType(StagSidebar))
            .contains(tester.getCenter(find.byTooltip('First'))),
        isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scrolls a long action strip and dismisses on outside tap',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var chosen = false;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Row(children: [
      StagSidebar(initiallyCollapsed: true, sections: const [], actions: [
        for (var i = 0; i < 8; i++)
          StagSidebarAction(
              label: 'Action $i',
              icon: Icons.star,
              onPressed: () {
                if (i == 7) chosen = true;
              }),
      ]),
      const Expanded(child: SizedBox()),
    ]))));
    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    await tester.drag(find.byTooltip('Action 0'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Action 7'));
    await tester.pumpAndSettle();
    expect(chosen, isTrue);
    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(300, 20));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Action 0'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('remains scrollable in a short viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 150));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: Row(children: [
      StagSidebar(sections: [
        StagSidebarSection(items: [
          StagSidebarItem(id: 'home', label: 'Dashboard', icon: Icons.home),
          StagSidebarItem(
              id: 'settings', label: 'Settings', icon: Icons.settings),
        ])
      ]),
      Expanded(child: SizedBox()),
    ]))));
    expect(tester.takeException(), isNull);
    await tester.drag(
        find.byType(SingleChildScrollView).first, const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Collapse sidebar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('offers an accessible toggle and respects reduced motion',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: Row(children: [
      MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: StagSidebar(
            initiallyCollapsed: true,
            sections: [
              StagSidebarSection(items: [
                StagSidebarItem(
                    id: 'home', label: 'Dashboard', icon: Icons.home),
              ])
            ],
          )),
      Expanded(child: SizedBox()),
    ]))));
    final toggle = tester.getSemantics(find.bySemanticsLabel('Expand sidebar'));
    expect(
        toggle,
        matchesSemantics(
            label: 'Expand sidebar', isButton: true, hasTapAction: true));
    await tester.tap(find.byTooltip('Expand sidebar'));
    await tester.pump();
    expect(tester.getSize(find.byType(StagSidebar)).width, closeTo(210, .1));
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
