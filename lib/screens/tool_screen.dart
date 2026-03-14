import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../widgets/common.dart';

class ToolScreen extends StatefulWidget {
  final PdfTool tool;
  const ToolScreen({super.key, required this.tool});

  @override
  State<ToolScreen> createState() => _ToolScreenState();
}

class _ToolScreenState extends State<ToolScreen> {
  String _selectedFile = '';
  bool _processing = false;
  bool _done = false;
  double _progress = 0;
  final _textCtrl = TextEditingController();
  int _compressLevel = 1;   // 0=low 1=mid 2=high
  int _rotationDeg  = 90;
  bool _allPages    = true;
  String _convertTo = 'Word';

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color  = widget.tool.color;

    return Directionality(
      textDirection: state.isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.tool.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(state.t(widget.tool.key)),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Description Card ──────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Text(widget.tool.icon, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        state.t('${widget.tool.key}_desc'),
                        style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── File Picker ───────────────────────────────────
              SectionTitle('📂  ${state.t("choose_file")}'),
              GestureDetector(
                onTap: _fakePick,
                child: GlassCard(
                  radius: 14,
                  child: Row(
                    children: [
                      Text('📄', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedFile.isEmpty ? state.t('no_file') : _selectedFile,
                          style: TextStyle(
                            color: _selectedFile.isEmpty
                                ? const Color(0xFF8888AA)
                                : const Color(0xFF43E97B),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Browse',
                          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Tool-specific options ─────────────────────────
              _buildToolOptions(state),
              const SizedBox(height: 28),

              // ── Progress ──────────────────────────────────────
              if (_processing || _done) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: color.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _done
                        ? state.t('done')
                        : '${(_progress * 100).toInt()}%  ${state.t("processing")}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _done ? const Color(0xFF43E97B) : color,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Action Button ─────────────────────────────────
              GradientButton(
                text: _done ? state.t('done') : state.t('process'),
                color1: color,
                color2: Color.lerp(color, Colors.white, 0.3)!,
                icon: _done ? Icons.check_circle : Icons.play_arrow,
                onPressed: _done ? _reset : _startProcess,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tool-specific UI ─────────────────────────────────────────
  Widget _buildToolOptions(AppState state) {
    final key = widget.tool.key;

    if (key == 'watermark') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('💬  ${state.t("enter_text")}'),
          TextField(
            controller: _textCtrl,
            decoration: InputDecoration(
              hintText: state.t('enter_text'),
              prefixText: '  ',
            ),
          ),
          const SizedBox(height: 16),
          SectionTitle('🔢  Opacity'),
          _OpacitySlider(color: widget.tool.color),
        ],
      );
    }

    if (key == 'protect') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('🔑  ${state.t("enter_pass")}'),
          TextField(
            obscureText: true,
            decoration: InputDecoration(hintText: state.t('enter_pass'),
                prefixIcon: const Icon(Icons.lock_outline, size: 18)),
          ),
          const SizedBox(height: 12),
          TextField(
            obscureText: true,
            decoration: InputDecoration(hintText: state.t('confirm_pass'),
                prefixIcon: const Icon(Icons.lock_outline, size: 18)),
          ),
        ],
      );
    }

    if (key == 'compress') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('📊  Compression Level'),
          ...List.generate(3, (i) {
            final labels = [
              state.t('compress_low'),
              state.t('compress_mid'),
              state.t('compress_high'),
            ];
            final icons = ['🟢', '🟡', '🔴'];
            return GestureDetector(
              onTap: () => setState(() => _compressLevel = i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _compressLevel == i
                      ? widget.tool.color.withOpacity(0.15)
                      : (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1C1C2E)
                          : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _compressLevel == i
                        ? widget.tool.color
                        : const Color(0xFF2A2A3F),
                    width: _compressLevel == i ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(icons[i]),
                    const SizedBox(width: 12),
                    Text(labels[i], style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _compressLevel == i ? widget.tool.color : null,
                    )),
                    const Spacer(),
                    if (_compressLevel == i)
                      Icon(Icons.check_circle, color: widget.tool.color, size: 18),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    }

    if (key == 'rotate') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('🔄  Rotation Angle'),
          Row(
            children: [90, 180, 270].map((deg) => Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _rotationDeg = deg),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: _rotationDeg == deg
                        ? LinearGradient(colors: [widget.tool.color,
                            Color.lerp(widget.tool.color, Colors.white, 0.3)!])
                        : null,
                    color: _rotationDeg == deg ? null : const Color(0xFF1C1C2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        deg == 90 ? '↻' : deg == 180 ? '↕' : '↺',
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(height: 4),
                      Text('$deg°', style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: _rotationDeg == deg ? Colors.white : null,
                      )),
                    ],
                  ),
                ),
              ),
            )).toList(),
          ),
        ],
      );
    }

    if (key == 'convert') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('🔁  Convert To'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Word', 'PNG', 'JPG', 'Excel', 'TXT', 'HTML']
                .map((fmt) => GestureDetector(
                      onTap: () => setState(() => _convertTo = fmt),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: _convertTo == fmt
                              ? LinearGradient(colors: [widget.tool.color,
                                  Color.lerp(widget.tool.color, Colors.white, 0.3)!])
                              : null,
                          color: _convertTo == fmt ? null : const Color(0xFF1C1C2E),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _convertTo == fmt
                                ? Colors.transparent
                                : const Color(0xFF2A2A3F),
                          ),
                        ),
                        child: Text(
                          fmt,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _convertTo == fmt ? Colors.white : null,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      );
    }

    if (key == 'split') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('📄  ${state.t("all_pages")}'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: state.t('from_page')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: state.t('to_page')),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Default: description + info
    return GlassCard(
      radius: 14,
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.t('${widget.tool.key}_desc'),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _fakePick() {
    const files = ['document.pdf', 'report_Q1.pdf', 'contract.pdf', 'manual_v2.pdf'];
    final list = [...files]..shuffle();
    setState(() => _selectedFile = list.first);
    context.read<AppState>().setSelectedFile(list.first);
    context.read<AppState>().addRecent(list.first);
  }

  void _startProcess() {
    if (_selectedFile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please select a file first'),
        backgroundColor: const Color(0xFFFF6B8A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    setState(() { _processing = true; _done = false; _progress = 0; });

    // Animate progress
    _animateProgress();
  }

  void _animateProgress() {
    const steps = 40;
    var step = 0;
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 55));
      if (!mounted) return false;
      step++;
      setState(() => _progress = step / steps);
      if (step >= steps) {
        setState(() { _done = true; _processing = false; });
        _showSuccess();
        return false;
      }
      return true;
    });
  }

  void _showSuccess() {
    final state = context.read<AppState>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1C1C2E)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 16),
              Text(state.t('success'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(state.t('file_processed'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color)),
              const SizedBox(height: 6),
              Text('💾  ${state.t("file_saved")}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF43E97B))),
              const SizedBox(height: 24),
              GradientButton(
                text: state.t('ok'),
                color1: widget.tool.color,
                color2: Color.lerp(widget.tool.color, Colors.white, 0.3)!,
                height: 48,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reset() {
    setState(() { _done = false; _progress = 0; });
  }
}

// ─────────────────────────────────────────────────────────────
//  Opacity Slider widget
// ─────────────────────────────────────────────────────────────
class _OpacitySlider extends StatefulWidget {
  final Color color;
  const _OpacitySlider({required this.color});
  @override
  State<_OpacitySlider> createState() => _OpacitySliderState();
}

class _OpacitySliderState extends State<_OpacitySlider> {
  double _val = 0.4;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: _val,
            onChanged: (v) => setState(() => _val = v),
            activeColor: widget.color,
            inactiveColor: widget.color.withOpacity(0.2),
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '${(_val * 100).toInt()}%',
            style: TextStyle(fontWeight: FontWeight.w700, color: widget.color),
          ),
        ),
      ],
    );
  }
}
