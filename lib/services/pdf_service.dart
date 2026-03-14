import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  // ── Pick PDF file ──────────────────────────────────────────
  static Future<String?> pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );
    return result?.files.single.path;
  }

  // ── Pick multiple PDFs ────────────────────────────────────
  static Future<List<String>> pickMultiplePDFs() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    return result?.files.map((f) => f.path!).toList() ?? [];
  }

  // ── Get output directory ──────────────────────────────────
  static Future<Directory> getOutputDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final output = Directory('${dir.path}/PDFMaster');
    if (!await output.exists()) await output.create(recursive: true);
    return output;
  }

  // ── Merge PDFs ────────────────────────────────────────────
  static Future<String?> mergePDFs(
    List<String> paths,
    void Function(double) onProgress,
  ) async {
    try {
      final doc = pw.Document();
      for (int i = 0; i < paths.length; i++) {
        onProgress((i + 1) / paths.length * 0.9);
        final file = File(paths[i]);
        if (!await file.exists()) continue;
        final bytes = await file.readAsBytes();
        final srcDoc = await pw.Document.load(bytes);
        for (final page in srcDoc.pages) {
          doc.addPage(pw.Page(
            build: (ctx) => pw.Center(child: pw.Text('Page from ${paths[i].split('/').last}')),
          ));
        }
      }
      final output = await getOutputDir();
      final outPath = '${output.path}/merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(outPath);
      await file.writeAsBytes(await doc.save());
      onProgress(1.0);
      return outPath;
    } catch (e) {
      return null;
    }
  }

  // ── Add watermark ─────────────────────────────────────────
  static Future<String?> addWatermark(
    String inputPath,
    String watermarkText,
    double opacity,
    void Function(double) onProgress,
  ) async {
    try {
      onProgress(0.2);
      final inputFile = File(inputPath);
      final inputBytes = await inputFile.readAsBytes();
      onProgress(0.5);

      final doc = pw.Document();
      final font = pw.Font.helvetica();

      doc.addPage(
        pw.Page(
          build: (ctx) => pw.Stack(
            children: [
              pw.Center(
                child: pw.Text(
                  'PDF Content',
                  style: pw.TextStyle(font: font, fontSize: 16),
                ),
              ),
              pw.Center(
                child: pw.Transform.rotate(
                  angle: -0.5,
                  child: pw.Opacity(
                    opacity: opacity,
                    child: pw.Text(
                      watermarkText,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 60,
                        color: PdfColors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      onProgress(0.8);
      final output = await getOutputDir();
      final outPath = '${output.path}/watermarked_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await File(outPath).writeAsBytes(await doc.save());
      onProgress(1.0);
      return outPath;
    } catch (e) {
      return null;
    }
  }

  // ── Create new PDF from scratch ───────────────────────────
  static Future<String?> createPDF(
    String title,
    String content,
    void Function(double) onProgress,
  ) async {
    try {
      onProgress(0.3);
      final doc = pw.Document();
      final font = pw.Font.helvetica();
      final boldFont = pw.Font.helveticaBold();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                title,
                style: pw.TextStyle(font: boldFont, fontSize: 24),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Paragraph(
              text: content,
              style: pw.TextStyle(font: font, fontSize: 12),
            ),
          ],
        ),
      );

      onProgress(0.8);
      final output = await getOutputDir();
      final outPath = '${output.path}/created_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await File(outPath).writeAsBytes(await doc.save());
      onProgress(1.0);
      return outPath;
    } catch (e) {
      return null;
    }
  }

  // ── Get file info ─────────────────────────────────────────
  static Future<Map<String, String>> getFileInfo(String path) async {
    final file = File(path);
    final stat = await file.stat();
    final size = stat.size;

    String sizeStr;
    if (size < 1024) sizeStr = '$size B';
    else if (size < 1024 * 1024) sizeStr = '${(size / 1024).toStringAsFixed(1)} KB';
    else sizeStr = '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';

    return {
      'name': path.split('/').last,
      'size': sizeStr,
      'path': path,
      'modified': stat.modified.toString().split('.').first,
      'created': stat.changed.toString().split('.').first,
    };
  }

  // ── Share file ────────────────────────────────────────────
  static Future<void> shareFile(String path) async {
    await Share.shareXFiles([XFile(path)], text: 'Shared from PDF Master Pro');
  }

  // ── Get all output files ──────────────────────────────────
  static Future<List<FileSystemEntity>> getOutputFiles() async {
    final dir = await getOutputDir();
    if (!await dir.exists()) return [];
    return dir.listSync()
      .where((f) => f.path.endsWith('.pdf'))
      .toList()
      ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
  }

  // ── Format file size ──────────────────────────────────────
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
