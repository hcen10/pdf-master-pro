import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import 'home_screen.dart';
import 'tools_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  final _screens = const [
    HomeScreen(),
    ToolsScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: state.isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: IndexedStack(index: _idx, children: _screens),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF10101A) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF2A2A3F) : const Color(0xFFEEEEFF),
                width: 1,
              ),
            ),
            boxShadow: isDark
                ? []
                : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  _NavItem(icon: '🏠', label: state.t('home'),     idx: 0, current: _idx, accent: accent, onTap: _setIdx),
                  _NavItem(icon: '🛠️', label: state.t('tools'),    idx: 1, current: _idx, accent: accent, onTap: _setIdx),
                  _NavItem(icon: '📂', label: state.t('history'),  idx: 2, current: _idx, accent: accent, onTap: _setIdx),
                  _NavItem(icon: '⚙️', label: state.t('settings'), idx: 3, current: _idx, accent: accent, onTap: _setIdx),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setIdx(int i) => setState(() => _idx = i);
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final int idx;
  final int current;
  final Color accent;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.idx,
    required this.current,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = idx == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(idx),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(fontSize: selected ? 24 : 21),
                child: Text(icon),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? accent : const Color(0xFF8888AA),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: selected ? 20 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
