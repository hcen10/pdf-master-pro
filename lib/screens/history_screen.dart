import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../widgets/common.dart';

// ═══════════════════════════════════════════════════════════════
//  HISTORY SCREEN
// ═══════════════════════════════════════════════════════════════
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(state.t('history'))),
      body: state.recent.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📂', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 16),
                  Text(state.t('no_recent'),
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 14)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.recent.length,
              itemBuilder: (_, i) {
                final file = state.recent[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C2E) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2A2A3F) : const Color(0xFFCCCCEE),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C6FF7).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: Text('📄', style: TextStyle(fontSize: 20))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(file,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('Recently opened',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).textTheme.bodySmall?.color)),
                          ],
                        ),
                      ),
                      Icon(Icons.more_vert,
                          size: 18,
                          color: Theme.of(context).textTheme.bodySmall?.color),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
