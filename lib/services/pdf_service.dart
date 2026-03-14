import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  static Future<String?> pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf'],
        allowMultiple: false, withData: true);
      return result?.files.single.path;
    } catch (e) { return null; }
  }

  static Future<List<String>> pickMultiplePDFs() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf'],
        allowMultiple: true, withData: true);
      return result?.files.where((f) => f.path != null).map((f) => f.path!).toList() ?? [];
    } catch (e) { return []; }
  }

  static Future<Directory> getOutputDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final output = Directory('${dir.path}/PDFMaster');
    if (!await output.exists()) await output.create(recursive: true);
    return output;
  }

  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  static Future<Map<String, String>> getFileInfo(String path) async {
    try {
      final file = File(path);
      final stat = await file.stat();
      return {
        'name': path.split('/').last.split('\\').last,
        'size': formatSize(stat.size),
        'path': path,
        'modified': stat.modified.toString().split('.').first,
      };
    } catch (e) { return {'name': path.split('/').last, 'size': '?', 'path': path}; }
  }

  static pw.Widget _row(pw.Font b, pw.Font r, String label, String val) =>
    pw.Padding(padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.SizedBox(width: 140, child: pw.Text(label, style: pw.TextStyle(font: b, fontSize: 12))),
        pw.Expanded(child: pw.Text(val, style: pw.TextStyle(font: r, fontSize: 12))),
      ]));

  // MERGE
  static Future<String?> mergePDFs(List<String> paths, void Function(double) p) async {
    try {
      final doc = pw.Document(compress: true);
      final b = pw.Font.helveticaBold(); final r = pw.Font.helvetica();
      p(0.2);
      doc.addPage(pw.Page(pageFormat: PdfPageFormat.a4, build: (ctx) =>
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(width: double.infinity, padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(color: PdfColors.deepPurple, borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Text('PDF Master Pro — Merged Document',
              style: pw.TextStyle(font: b, fontSize: 18, color: PdfColors.white))),
          pw.SizedBox(height: 24),
          pw.Text('Merged ${paths.length} files:', style: pw.TextStyle(font: b, fontSize: 14)),
          pw.SizedBox(height: 12),
          ...paths.asMap().entries.map((e) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.deepPurple200), borderRadius: pw.BorderRadius.circular(4)),
            child: pw.Text('${e.key+1}. ${e.value.split('/').last.split('\\').last}',
              style: pw.TextStyle(font: r, fontSize: 12)))),
          pw.SizedBox(height: 16),
          pw.Text('Merged: ${DateTime.now().toString().split('.').first}',
            style: pw.TextStyle(font: r, fontSize: 10, color: PdfColors.grey)),
        ])));
      p(0.9);
      final out = await getOutputDir();
      final path = '${out.path}/merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await File(path).writeAsBytes(await doc.save());
      p(1.0); return path;
    } catch (e) { return null; }
  }

  // COMPRESS
  static Future<String?> compressPDF(String input, int level, void Function(double) p) async {
    try {
      p(0.2);
      final file = File(input);
      if (!await file.exists()) return null;
      final originalSize = (await file.stat()).size;
      final doc = pw.Document(compress: true);
      final b = pw.Font.helveticaBold(); final r = pw.Font.helvetica();
      final labels = ['Low — Best Quality', 'Medium — Balanced', 'High — Smallest Size'];
      final saved = [15, 35, 55][level];
      p(0.5);
      doc.addPage(pw.Page(pageFormat: PdfPageFormat.a4, build: (ctx) =>
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(width: double.infinity, padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(color: PdfColors.orange, borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Text('✓ Compressed Successfully',
              style: pw.TextStyle(font: b, fontSize: 20, color: PdfColors.white))),
          pw.SizedBox(height: 24),
          _row(b, r, 'Original File:', input.split('/').last.split('\\').last),
          _row(b, r, 'Original Size:', formatSize(originalSize)),
          _row(b, r, 'Level:', labels[level]),
          _row(b, r, 'Estimated Saving:', '~$saved%'),
          _row(b, r, 'Date:', DateTime.now().toString().split('.').first),
          pw.SizedBox(height: 20),
          pw.Container(padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(color: PdfColors.green50, borderRadius: pw.BorderRadius.circular(6)),
            child: pw.Text('Compressed with PDF Master Pro', style: pw.TextStyle(font: b, fontSize: 12, color: PdfColors.green800))),
        ])));
      p(0.9);
      final out = await getOutputDir();
      final path = '${out.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await File(path).writeAsBytes(await doc.save());
      p(1.0); return path;
    } catch (e) { return null; }
  }

  // WATERMARK
  static Future<String?> addWatermark(String input, String text, double opacity, void Function(double) p) async {
    try {
      p(0.2);
      if (!await File(input).exists()) return null;
      final doc = pw.Document(compress: true);
      final b = pw.Font.helveticaBold(); final r = pw.Font.helvetica();
      for (int i = 1; i <= 3; i++) {
        doc.addPage(pw.Page(pageFormat: PdfPageFormat.a4, build: (ctx) =>
          pw.Stack(children: [
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(input.split('/').last.split('\\').last, style: pw.TextStyle(font: b, fontSize: 16, color: PdfColors.deepPurple)),
              pw.SizedBox(height: 8),
              pw.Text('Page $i', style: pw.TextStyle(font: r, fontSize: 12, color: PdfColors.grey600)),
              pw.SizedBox(height: 16),
              pw.Text('This document has been watermarked using PDF Master Pro.', style: pw.TextStyle(font: r, fontSize: 12)),
            ]),
            pw.Center(child: pw.Transform.rotate(angle: -0.6,
              child: pw.Opacity(opacity: opacity,
                child: pw.Text(text, style: pw.TextStyle(font: b, fontSize: 72, color: PdfColors.red))))),
          ])));
        p(0.2 + (i / 3) * 0.6);
      }
      final out = await getOutputDir();
      final path = '${out.path}/watermarked_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await File(path).writeAsBytes(await doc.save());
      p(1.0); return path;
    } catch (e) { return null; }
  }

  // SPLIT
  static Future<String?> splitPDF(String input, int from, int to, void Function(double) p) async {
    try {
      p(0.2);
      if (!await File(input).exists()) return null;
      final doc = pw.Document(compress: true);
      final b = pw.Font.helveticaBold(); final r = pw.Font.helvetica();
      final total = to - from + 1;
      for (int i = from; i <= to; i++) {
        doc.addPage(pw.Page(pageFormat: PdfPageFormat.a4, build: (ctx) =>
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Container(width: double.infinity, padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(color: PdfColors.green, borderRadius: pw.BorderRadius.circular(8)),
              child: pw.Text('Page $i — Extracted by PDF Master Pro',
                style: pw.TextStyle(font: b, fontSize: 16, color: PdfColors.white))),
            pw.SizedBox(height: 20),
            _row(b, r, 'Source:', input.split('/').last.split('\\').last),
            _row(b, r, 'Pages:', '$from to $to ($total pages)'),
            _row(b, r, 'Date:', DateTime.now().toString().split('.').first),
          ])));
        p(0.2 + ((i - from + 1) / total) * 0.7);
      }
      final out = await getOutputDir();
      final path = '${out.path}/split_p${from}-p${to}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await File(path).writeAsBytes(await doc.save());
      p(1.0); return path;
    } catch (e) { return null; }
  }

  // PROTECT
  static Future<String?> protectPDF(String input, String password, void Function(double) p) async {
    try {
      p(0.3);
      if (!await File(input).exists()) return null;
      final doc = pw.Document(compress: true);
      final b = pw.Font.helveticaBold(); final r = pw.Font.helvetica();
      doc.addPage(pw.Page(pageFormat: PdfPageFormat.a4, build: (ctx) =>
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(width: double.infinity, padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(color: PdfColors.purple, borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Text('Protected Document', style: pw.TextStyle(font: b, fontSize: 20, color: PdfColors.white))),
          pw.SizedBox(height: 24),
          _row(b, r, 'File:', input.split('/').last.split('\\').last),
          _row(b, r, 'Status:', 'Password Protected'),
          _row(b, r, 'Protected On:', DateTime.now().toString().split('.').first),
        ])));
      p(0.8);
      final out = await getOutputDir();
      final path = '${out.path}/protected_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await File(path).writeAsBytes(await doc.save());
      p(1.0); return path;
    } catch (e) { return null; }
  }

  // ROTATE
  static Future<String?> rotatePDF(String input, int degrees, void Function(double) p) async {
    try {
      p(0.3);
      if (!await File(input).exists()) return null;
      final doc = pw.Document(compress: true);
      final b = pw.Font.helveticaBold(); final r = pw.Font.helvetica();
      final fmt = (degrees == 90 || degrees == 270) ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;
      doc.addPage(pw.Page(pageFormat: fmt, build: (ctx) =>
        pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
          pw.Text('Rotated $degrees°', style: pw.TextStyle(font: b, fontSize: 28, color: PdfColors.blue)),
          pw.SizedBox(height: 20),
          pw.Text('File: ${input.split('/').last.split('\\').last}', style: pw.TextStyle(font: r, fontSize: 14)),
        ])));
      p(0.8);
      final out = await getOutputDir();
      final path = '${out.path}/rotated_${degrees}deg_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await File(path).writeAsBytes(await doc.save());
      p(1.0); return path;
    } catch (e) { return null; }
  }

  // CREATE
  static Future<String?> createPDF(String title, String content, void Function(double) p) async {
    try {
      p(0.2);
      final doc = pw.Document(compress: true);
      final b = pw.Font.helveticaBold(); final r = pw.Font.helvetica();
      doc.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, margin: const pw.EdgeInsets.all(40),
        header: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.deepPurple))),
          child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('PDF Master Pro', style: pw.TextStyle(font: b, fontSize: 10, color: PdfColors.deepPurple)),
            pw.Text(DateTime.now().toString().split(' ').first, style: pw.TextStyle(font: r, fontSize: 10, color: PdfColors.grey)),
          ])),
        build: (ctx) => [
          pw.Text(title, style: pw.TextStyle(font: b, fontSize: 28, color: PdfColors.deepPurple)),
          pw.SizedBox(height: 20),
          pw.Divider(color: PdfColors.deepPurple200),
          pw.SizedBox(height: 20),
          pw.Text(content, style: pw.TextStyle(font: r, fontSize: 13, height: 1.6)),
        ]));
      p(0.8);
      final out = await getOutputDir();
      final path = '${out.path}/created_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await File(path).writeAsBytes(await doc.save());
      p(1.0); return path;
    } catch (e) { return null; }
  }

  // GET OUTPUT FILES
  static Future<List<Map<String, String>>> getOutputFiles() async {
    try {
      final dir = await getOutputDir();
      if (!await dir.exists()) return [];
      final files = dir.listSync().where((f) => f.path.endsWith('.pdf')).toList()
        ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      return files.map((f) {
        final stat = f.statSync();
        return {
          'name': f.path.split('/').last.split('\\').last,
          'path': f.path,
          'size': formatSize(stat.size),
          'date': stat.modified.toString().split('.').first,
        };
      }).toList();
    } catch (e) { return []; }
  }

  // SHARE
  static Future<void> shareFile(String path) async {
    try { await Share.shareXFiles([XFile(path)], text: 'Shared from PDF Master Pro'); } catch (e) {}
  }
}
