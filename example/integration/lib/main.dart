import 'package:flutter/material.dart';
import 'package:stag_appbar/stag_appbar.dart';
import 'package:stag_sidebar/stag_sidebar.dart';

void main() => runApp(const MaterialApp(home: ExamplePage()));

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});
  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  var selected = 'dashboard';
  var light = false;
  var mode = StagAppBarLayoutMode.aboveSidebar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light
          ? const Color(0xFFEAF1F3)
          : const Color(0xFF090B15),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StagAppBarLayout(
            mode: mode,
            sidebar: StagSidebar(
              initiallyCollapsed: MediaQuery.sizeOf(context).width < 700,
              selectedId: selected,
              onItemSelected: (id) => setState(() => selected = id),
              style: light
                  ? const StagSidebarStyle.light()
                  : const StagSidebarStyle(),
              sections: const [
                StagSidebarSection(
                  items: [
                    StagSidebarItem(
                      id: 'dashboard',
                      label: 'Dashboard',
                      icon: Icons.dashboard_outlined,
                    ),
                    StagSidebarItem(
                      id: 'settings',
                      label: 'Settings',
                      icon: Icons.settings_outlined,
                    ),
                  ],
                ),
              ],
            ),
            appBar: StagAppBar(
              title: Text(
                selected == 'dashboard' ? 'Dashboard' : 'Settings',
                overflow: TextOverflow.ellipsis,
              ),
              style: light
                  ? const StagAppBarStyle.light()
                  : const StagAppBarStyle(),
              actions: [
                IconButton(
                  tooltip: 'Toggle layout',
                  onPressed: () => setState(
                    () => mode = mode == StagAppBarLayoutMode.aboveSidebar
                        ? StagAppBarLayoutMode.besideSidebar
                        : StagAppBarLayoutMode.aboveSidebar,
                  ),
                  icon: const Icon(Icons.view_quilt_outlined),
                ),
                IconButton(
                  tooltip: 'Toggle theme',
                  onPressed: () => setState(() => light = !light),
                  icon: Icon(
                    light
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                  ),
                ),
              ],
            ),
            body: const Center(
              child: Text(
                'Your content goes here',
                style: TextStyle(color: Color(0xFF8194A2)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
