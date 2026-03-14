import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(state.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Language Section ──────────────────────────────────
          SectionTitle('🌐  ${state.t("language")}'),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: kLanguageNames.entries.map((entry) {
                final isSelected = state.language == entry.key;
                return InkWell(
                  onTap: () => state.setLanguage(entry.key),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Text(entry.value, style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected ? accent : null,
                        )),
                        const Spacer(),
                        if (isSelected)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.check, color: Colors.white, size: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // ── Theme ─────────────────────────────────────────────
          SectionTitle('🎨  ${state.t("theme")}'),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () { if (!state.isDark) state.toggleTheme(); },
                  child: _ThemeOption(
                    icon: '🌙',
                    label: state.t('dark'),
                    selected: state.isDark,
                    accent: accent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () { if (state.isDark) state.toggleTheme(); },
                  child: _ThemeOption(
                    icon: '☀️',
                    label: state.t('light'),
                    selected: !state.isDark,
                    accent: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Preferences ───────────────────────────────────────
          SectionTitle('🔧  Preferences'),
          SettingsToggle(
            icon: '💾',
            title: state.t('auto_save'),
            subtitle: 'Save output files automatically',
            value: state.autoSave,
            onChanged: (_) => state.toggleAutoSave(),
          ),
          const SizedBox(height: 10),
          SettingsToggle(
            icon: '🔔',
            title: state.t('notifications'),
            subtitle: 'Receive processing notifications',
            value: state.notifs,
            onChanged: (_) => state.toggleNotifs(),
          ),
          const SizedBox(height: 20),

          // ── About Actions ─────────────────────────────────────
          SectionTitle('📱  ${state.t("about")}'),
          ...[
            ('⭐', state.t('rate')),
            ('🔗', state.t('share_app')),
            ('💬', state.t('help')),
          ].map((item) => _ActionTile(icon: item.$1, label: item.$2)),
          const SizedBox(height: 20),

          // Version
          Center(
            child: Text(
              state.t('version') + '\n' + state.t('made_with'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
                height: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String icon;
  final String label;
  final bool selected;
  final Color accent;
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: selected
            ? accent.withOpacity(0.15)
            : (isDark ? const Color(0xFF1C1C2E) : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? accent : (isDark ? const Color(0xFF2A2A3F) : const Color(0xFFCCCCEE)),
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? accent : null,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String icon;
  final String label;
  const _ActionTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C2E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF2A2A3F) : const Color(0xFFCCCCEE),
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const Spacer(),
            Icon(Icons.chevron_right,
                size: 18,
                color: Theme.of(context).textTheme.bodySmall?.color),
          ],
        ),
      ),
    );
  }
}
