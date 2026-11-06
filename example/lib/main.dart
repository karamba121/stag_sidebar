import 'package:flutter/material.dart';
import 'package:stag_sidebar/stag_sidebar.dart';

void main() => runApp(const SidebarPreviewApp());

class SidebarPreviewApp extends StatelessWidget {
  const SidebarPreviewApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Stag Sidebar Preview',
    theme: ThemeData(useMaterial3: true),
    home: const SidebarPreviewPage(),
  );
}

class SidebarPreviewPage extends StatefulWidget {
  const SidebarPreviewPage({super.key});

  @override
  State<SidebarPreviewPage> createState() => _SidebarPreviewPageState();
}

class _SidebarPreviewPageState extends State<SidebarPreviewPage> {
  String _selectedId = 'dashboard';

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD5ECF5), Color(0xFFDAF0E4)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StagSidebar(
                  selectedId: _selectedId,
                  onItemSelected: (id) => setState(() => _selectedId = id),
                  sections: [
                    StagSidebarSection(
                      items: [
                        StagSidebarItem(
                          id: 'dashboard',
                          label: 'Dashboard',
                          icon: Icons.dashboard_outlined,
                        ),
                      ],
                    ),
                    StagSidebarSection(
                      items: [
                        StagSidebarItem(
                          id: 'swap',
                          label: 'Swap',
                          icon: Icons.swap_horiz,
                          children: [
                            StagSidebarItem(
                              id: 'add-liquidity',
                              label: 'Add Liquidity',
                              icon: Icons.add_circle_outline,
                            ),
                            StagSidebarItem(
                              id: 'manage-liquidity',
                              label: 'Manage Liquidity',
                              icon: Icons.hub_outlined,
                            ),
                            StagSidebarItem(
                              id: 'thor-stake',
                              label: 'Thor Stake',
                              icon: Icons.bolt_outlined,
                            ),
                            StagSidebarItem(
                              id: 'pending-liquidity',
                              label: 'Pending Liquidity',
                              icon: Icons.schedule_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                    StagSidebarSection(
                      items: [
                        StagSidebarItem(
                          id: 'vesting',
                          label: 'Vesting',
                          icon: Icons.pie_chart_outline,
                        ),
                      ],
                    ),
                    StagSidebarSection(
                      items: [
                        StagSidebarItem(
                          id: 'wallet',
                          label: 'Your Wallet',
                          icon: Icons.account_balance_wallet_outlined,
                          selectedGradient: const LinearGradient(
                            colors: [Color(0xFF31BDE4), Color(0xFF31C4DD)],
                          ),
                        ),
                      ],
                    ),
                    StagSidebarSection(
                      items: [
                        StagSidebarItem(
                          id: 'thornode',
                          label: 'Thornode',
                          icon: Icons.cloud_queue_outlined,
                        ),
                        StagSidebarItem(
                          id: 'stats',
                          label: 'Stats',
                          icon: Icons.tune,
                        ),
                      ],
                    ),
                  ],
                  actions: [
                    StagSidebarAction(
                      label: 'Telegram',
                      icon: Icons.send,
                      onPressed: () {},
                    ),
                    StagSidebarAction(
                      label: 'Twitter',
                      icon: Icons.alternate_email,
                      onPressed: () {},
                      iconColor: const Color(0xFF52C9D7),
                    ),
                    StagSidebarAction(
                      label: 'Discord',
                      icon: Icons.sports_esports_outlined,
                      onPressed: () {},
                      iconColor: const Color(0xFF8585FF),
                    ),
                    StagSidebarAction(
                      label: 'Reddit',
                      icon: Icons.reddit,
                      onPressed: () {},
                      iconColor: const Color(0xFFFF744D),
                    ),
                  ],
                  style: const StagSidebarStyle(
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                    sectionSpacing: 12,
                    itemSpacing: 2,
                    itemHeight: 38,
                  ),
                ),
                if (MediaQuery.sizeOf(context).width >= 600) ...[
                  const SizedBox(width: 48),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STAG SIDEBAR',
                          style: TextStyle(
                            color: Color(0xFF516C79),
                            fontSize: 12,
                            letterSpacing: 2.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Navegação que se adapta ao seu app.',
                          style: TextStyle(
                            color: Color(0xFF142934),
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Selecione um item e use o controle inferior para alternar entre os modos expandido e compacto.',
                          style: TextStyle(
                            color: Color(0xFF49616C),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
