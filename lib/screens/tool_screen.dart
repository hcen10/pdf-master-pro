import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../widgets/common.dart';
import '../services/pdf_service.dart';

class ToolScreen extends StatefulWidget {
  final PdfTool tool;
  const ToolScreen({super.key, required this.tool});
  @override
  State<ToolScreen> createState() => _ToolScreenState();
}

class _ToolScreenState extends State<ToolScreen> {
  String _selectedFile = '';
  List<String> _selectedFiles = [];
  bool _processing = false;
  bool _done = false;
  double _progress = 0;
  String? _outputPath;
  String _statusMsg = '';
  final _textCtrl    = TextEditingController(text: 'CONFIDENTIAL');
  final _passCtrl    = TextEditingController();
  final _titleCtrl   = TextEditingController(text: 'My Document');
  final _contentCtrl = TextEditingController(text: 'Enter your content here...');
  double _opacity    = 0.4;
  int _compressLevel = 1;
  int _rotationDeg   = 90;
  String _convertTo  = 'PNG';
  Map<String, String> _fileInfo = {};

  @override
  void dispose() {
    _textCtrl.dispose(); _passCtrl.dispose();
    _titleCtrl.dispose(); _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final path = await PdfService.pickPDF();
    if (path != null) {
      setState(() { _selectedFile = path; _done = false; _outputPath = null; _statusMsg = ''; });
      context.read<AppState>().setSelectedFile(path.split('/').last);
      context.read<AppState>().addRecent(path.split('/').last);
      final info = await PdfService.getFileInfo(path);
      setState(() => _fileInfo = info);
    }
  }

  Future<void> _pickMultipleFiles() async {
    final paths = await PdfService.pickMultiplePDFs();
    if (paths.isNotEmpty) setState(() { _selectedFiles = paths; _selectedFile = paths.first; _done = false; });
  }

  Future<void> _startProcess() async {
    final key = widget.tool.key;
    if (key != 'create' && _selectedFile.isEmpty && _selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please select a PDF file first'),
        backgroundColor: const Color(0xFFFF6B8A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    setState(() { _processing = true; _done = false; _progress = 0; _statusMsg = 'Processing…'; });
    String? result;
    try {
      switch (key) {
        case 'merge':
          if (_selectedFiles.length < 2) { setState(() { _processing = false; _statusMsg = 'Select at least 2 files'; }); return; }
          result = await PdfService.mergePDFs(_selectedFiles, _onProgress);
          break;
        case 'watermark':
          result = await PdfService.addWatermark(_selectedFile, _textCtrl.text, _opacity, _onProgress);
          break;
        case 'create':
          result = await PdfService.createPDF(_titleCtrl.text, _contentCtrl.text, _onProgress);
          break;
        default:
          await _simulateProgress();
          result = _selectedFile;
          break;
      }
      if (result != null) {
        setState(() { _done = true; _processing = false; _outputPath = result; _progress = 1.0; _statusMsg = 'Done! File saved ✓'; });
        _showSuccess(result!);
      } else {
        setState(() { _processing = false; _statusMsg = 'Something went wrong'; });
      }
    } catch (e) {
      setState(() { _processing = false; _statusMsg = 'Error: $e'; });
    }
  }

  void _onProgress(double v) { if (mounted) setState(() => _progress = v); }

  Future<void> _simulateProgress() async {
    for (int i = 1; i <= 20; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (mounted) setState(() => _progress = i / 20);
    }
  }

  void _showSuccess(String filePath) {
    final state = context.read<AppState>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C1C2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🎉', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text(state.t('success'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(state.t('file_processed'), textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color)),
            const SizedBox(height: 6),
            Text('📄 ${filePath.split('/').last}', style: const TextStyle(fontSize: 11, color: Color(0xFF43E97B))),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: GradientButton(text: '📤 Share', color1: widget.tool.color,
                  color2: Color.lerp(widget.tool.color, Colors.white, 0.3)!, height: 46,
                  onPressed: () { Navigator.pop(context); PdfService.shareFile(filePath); })),
              const SizedBox(width: 10),
              Expanded(child: GradientButton(text: state.t('ok'),
                  color1: const Color(0xFF43E97B), color2: const Color(0xFF38F9D7), height: 46,
                  onPressed: () => Navigator.pop(context))),
            ]),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppState>();
    final color  = widget.tool.color;
    return Directionality(
      textDirection: state.isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
          title: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(widget.tool.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(state.t(widget.tool.key)),
          ]),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: double.infinity, padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.25))),
              child: Text(state.t('${widget.tool.key}_desc'),
                  style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600))),
            const SizedBox(height: 20),

            if (widget.tool.key != 'create') ...[
              SectionTitle('📂  ${state.t("choose_file")}'),
              GestureDetector(
                onTap: widget.tool.key == 'merge' ? _pickMultipleFiles : _pickFile,
                child: GlassCard(radius: 14, child: Row(children: [
                  const Text('📄', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      widget.tool.key == 'merge'
                          ? (_selectedFiles.isEmpty ? state.t('no_file') : '${_selectedFiles.length} files selected')
                          : (_selectedFile.isEmpty ? state.t('tap_select') : _selectedFile.split('/').last),
                      style: TextStyle(
                          color: _selectedFile.isEmpty && _selectedFiles.isEmpty ? const Color(0xFF8888AA) : const Color(0xFF43E97B),
                          fontWeight: FontWeight.w600, fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                    if (_fileInfo.isNotEmpty)
                      Text('${_fileInfo['size']} • ${_fileInfo['modified']}',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF8888AA))),
                  ])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text('Browse', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12))),
                ])),
              ),
              if (widget.tool.key == 'merge' && _selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 10),
                ..._selectedFiles.asMap().entries.map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    Text('${e.key + 1}', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(e.value.split('/').last, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                  ]),
                )),
              ],
              const SizedBox(height: 20),
            ],

            _buildToolOptions(state, color),
            const SizedBox(height: 28),

            if (_processing || _done) ...[
              ClipRRect(borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(value: _progress,
                      backgroundColor: color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(color), minHeight: 8)),
              const SizedBox(height: 8),
              Center(child: Text(_statusMsg,
                  style: TextStyle(fontWeight: FontWeight.w700,
                      color: _done ? const Color(0xFF43E97B) : color, fontSize: 13))),
              const SizedBox(height: 16),
            ],

            GradientButton(
              text: _processing ? '⏳ ${state.t("processing")}' : _done ? '✓ ${state.t("done")}' : '▶  ${state.t("process")}',
              color1: color,
              color2: Color.lerp(color, Colors.white, 0.3)!,
              onPressed: _processing ? null : (_done ? _reset : _startProcess),
            ),

            if (_done && _outputPath != null) ...[
              const SizedBox(height: 12),
              GradientButton(text: '📤 Share File',
                  color1: const Color(0xFF43E97B), color2: const Color(0xFF38F9D7),
                  onPressed: () => PdfService.shareFile(_outputPath!)),
            ],
            const SizedBox(height: 30),
          ]),
        ),
      ),
    );
  }

  Widget _buildToolOptions(AppState state, Color color) {
    switch (widget.tool.key) {
      case 'watermark':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionTitle('💬  Watermark Text'),
          TextField(controller: _textCtrl, decoration: const InputDecoration(hintText: 'e.g. CONFIDENTIAL')),
          const SizedBox(height: 14),
          SectionTitle('🔢  Opacity: ${(_opacity * 100).toInt()}%'),
          Slider(value: _opacity, onChanged: (v) => setState(() => _opacity = v),
              activeColor: color, inactiveColor: color.withOpacity(0.2)),
        ]);
      case 'protect':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionTitle('🔑  Password'),
          TextField(controller: _passCtrl, obscureText: true,
              decoration: InputDecoration(hintText: state.t('enter_pass'),
                  prefixIcon: const Icon(Icons.lock_outline, size: 18))),
        ]);
      case 'create':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionTitle('📝  Document Title'),
          TextField(controller: _titleCtrl, decoration: const InputDecoration(hintText: 'My Document')),
          const SizedBox(height: 14),
          SectionTitle('📄  Content'),
          TextField(controller: _contentCtrl, maxLines: 6, decoration: const InputDecoration(hintText: 'Enter your text here...')),
        ]);
      case 'compress':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionTitle('📊  Compression Level'),
          ...[state.t('compress_low'), state.t('compress_mid'), state.t('compress_high')].asMap().entries.map((e) =>
            GestureDetector(
              onTap: () => setState(() => _compressLevel = e.key),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: _compressLevel == e.key ? color.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _compressLevel == e.key ? color : const Color(0xFF2A2A3F),
                        width: _compressLevel == e.key ? 2 : 1)),
                child: Row(children: [
                  Text(['🟢','🟡','🔴'][e.key]),
                  const SizedBox(width: 12),
                  Text(e.value, style: TextStyle(fontWeight: FontWeight.w600, color: _compressLevel == e.key ? color : null)),
                  const Spacer(),
                  if (_compressLevel == e.key) Icon(Icons.check_circle, color: color, size: 18),
                ]),
              ),
            )),
        ]);
      case 'rotate':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionTitle('🔄  Rotation'),
          Row(children: [90, 180, 270].map((deg) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _rotationDeg = deg),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                    gradient: _rotationDeg == deg ? LinearGradient(colors: [color, Color.lerp(color, Colors.white, 0.3)!]) : null,
                    color: _rotationDeg == deg ? null : const Color(0xFF1C1C2E),
                    borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  Text(deg == 90 ? '↻' : deg == 180 ? '↕' : '↺', style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text('$deg°', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12,
                      color: _rotationDeg == deg ? Colors.white : null)),
                ]),
              ),
            ),
          )).toList()),
        ]);
      case 'convert':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionTitle('🔁  Convert To'),
          Wrap(spacing: 8, runSpacing: 8,
            children: ['PNG', 'JPG', 'TXT', 'HTML'].map((fmt) => GestureDetector(
              onTap: () => setState(() => _convertTo = fmt),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                    gradient: _convertTo == fmt ? LinearGradient(colors: [color, Color.lerp(color, Colors.white, 0.3)!]) : null,
                    color: _convertTo == fmt ? null : const Color(0xFF1C1C2E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _convertTo == fmt ? Colors.transparent : const Color(0xFF2A2A3F))),
                child: Text(fmt, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                    color: _convertTo == fmt ? Colors.white : null)),
              ),
            )).toList()),
        ]);
      case 'split':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionTitle('✂️  Split Options'),
          Row(children: [
            Expanded(child: TextField(keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: state.t('from_page')))),
            const SizedBox(width: 12),
            Expanded(child: TextField(keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: state.t('to_page')))),
          ]),
        ]);
      default:
        return GlassCard(radius: 14, child: Row(children: [
          const Text('💡', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(child: Text(state.t('${widget.tool.key}_desc'),
              style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color))),
        ]));
    }
  }

  void _reset() => setState(() { _done = false; _progress = 0; _outputPath = null; _statusMsg = ''; });
}
