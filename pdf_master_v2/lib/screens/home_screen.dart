import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../widgets/common.dart';
import 'tool_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            floating: true,
            snap: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF0A0A12), const Color(0xFF13131E)]
                        : [const Color(0xFFF4F4FF), const Color(0xFFEEEEFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF7C6FF7), Color(0xFFFF6B8A)],
                                ),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Center(child: Text('📄', style: TextStyle(fontSize: 20))),
                            ),
                            const SizedBox(width: 10),
                            ShaderMask(
                              shaderCallback: (r) => const LinearGradient(
                                colors: [Color(0xFF7C6FF7), Color(0xFFFF6B8A)],
                              ).createShader(r),
                              child: Text(
                                state.t('app_name'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C6FF7).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF7C6FF7).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'PRO',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF7C6FF7),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          state.t('tagline'),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? const Color(0xFF8888AA) : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // File Picker Card
                _FilePickerCard(state: state),
                const SizedBox(height: 24),

                // Popular Tools
                SectionTitle('⚡ ' + state.t('all_tools')),
                _ToolsGrid(compact: true, state: state),
                const SizedBox(height: 24),

                // Features
                SectionTitle('✨ Features'),
                FeatureRow(icon: '🔒', text: state.t('privacy'),  color: const Color(0xFF43E97B)),
                FeatureRow(icon: '♾️', text: state.t('free'),     color: const Color(0xFF7C6FF7)),
                FeatureRow(icon: '⚡', text: state.t('fast'),     color: const Color(0xFFF7971E)),
                FeatureRow(icon: '🛡️', text: state.t('secure'),   color: const Color(0xFF4FACFE)),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  File Picker Card
// ─────────────────────────────────────────────────────────────
class _FilePickerCard extends StatelessWidget {
  final AppState state;
  const _FilePickerCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final hasFile = state.selectedFile.isNotEmpty;
    return GestureDetector(
      onTap: () => _fakePick(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF7C6FF7).withOpacity(0.12),
              const Color(0xFFFF6B8A).withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF7C6FF7).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF7C6FF7).withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Text('📂', style: TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.t('choose_file'),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasFile ? '📄 ${state.selectedFile}' : state.t('tap_select'),
                    style: TextStyle(
                      fontSize: 12,
                      color: hasFile
                          ? const Color(0xFF43E97B)
                          : const Color(0xFF8888AA),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C6FF7), Color(0xFFFF6B8A)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Browse',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fakePick(BuildContext ctx) {
    const files = ['report_2024.pdf', 'contract_v2.pdf', 'invoice.pdf', 'manual.pdf'];
    files.shuffle();
    ctx.read<AppState>().setSelectedFile(files.first);
    ctx.read<AppState>().addRecent(files.first);
  }
}

// ─────────────────────────────────────────────────────────────
//  Tools Grid (compact for home)
// ─────────────────────────────────────────────────────────────
class _ToolsGrid extends StatelessWidget {
  final bool compact;
  final AppState state;
  const _ToolsGrid({required this.compact, required this.state});

  @override
  Widget build(BuildContext context) {
    final tools = compact ? kTools.take(8).toList() : kTools;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: tools.length,
      itemBuilder: (ctx, i) => _MiniToolCard(tool: tools[i], state: state),
    );
  }
}

class _MiniToolCard extends StatelessWidget {
  final PdfTool tool;
  final AppState state;
  const _MiniToolCard({required this.tool, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ToolScreen(tool: tool))),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2A2A3F) : const Color(0xFFCCCCEE),
          ),
          boxShadow: isDark ? [] : [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (tool.isPopular || tool.isNew)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6, right: 6),
                  child: ToolBadge(
                    label: tool.isNew ? state.t('new_tag') : state.t('popular'),
                    color: tool.isNew ? const Color(0xFF43E97B) : const Color(0xFFF7971E),
                  ),
                ),
              )
            else
              const SizedBox(height: 14),
            Text(tool.icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                state.t(tool.key),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
