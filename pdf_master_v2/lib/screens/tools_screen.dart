import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../widgets/common.dart';
import 'tool_screen.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});
  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = kTools.where((t) {
      final name = state.t(t.key).toLowerCase();
      final desc = state.t('${t.key}_desc').toLowerCase();
      return _search.isEmpty ||
          name.contains(_search.toLowerCase()) ||
          desc.contains(_search.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(state.t('tools')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: state.t('search_tools'),
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: filtered.isEmpty
          ? Center(
              child: Text(
                '🔍  No tools found',
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) => _ToolListTile(tool: filtered[i], state: state),
            ),
    );
  }
}

class _ToolListTile extends StatelessWidget {
  final PdfTool tool;
  final AppState state;
  const _ToolListTile({required this.tool, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ToolScreen(tool: tool))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2A2A3F) : const Color(0xFFCCCCEE),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: tool.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(tool.icon, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(state.t(tool.key),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(width: 6),
                      if (tool.isPopular)
                        ToolBadge(label: state.t('popular'), color: const Color(0xFFF7971E)),
                      if (tool.isNew)
                        ToolBadge(label: state.t('new_tag'), color: const Color(0xFF43E97B)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    state.t('${tool.key}_desc'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: tool.color, size: 22),
          ],
        ),
      ),
    );
  }
}
