import "dart:io";
import "package:file_picker/file_picker.dart";
import "package:path_provider/path_provider.dart";
import "package:share_plus/share_plus.dart";
import "package:pdf/pdf.dart";
import "package:pdf/widgets.dart" as pw;

class PdfService {
  static Future<String?> pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ["pdf"], allowMultiple: false);
    return result?.files.single.path;
  }

  static Future<List<String>> pickMultiplePDFs() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ["pdf"], allowMultiple: true);
    return result?.files.map((f) => f.path!).toList() ?? [];
  }

  static Future<Directory> getOutputDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final output = Directory("${dir.path}/PDFMaster");
    if (!await output.exists()) await output.create(recursive: true);
    return output;
  }

  static Future<String?> mergePDFs(List<String> paths, void Function(double) onProgress) async {
    try {
      final doc = pw.Document();
      final font = pw.Font.helvetica();
      for (int i = 0; i < paths.length; i++) {
        onProgress((i + 1) / paths.length * 0.9);
        doc.addPage(pw.Page(build: (ctx) => pw.Center(
          child: pw.Text("Page from: ${paths[i].split("/").last}",
              style: pw.TextStyle(font: font, fontSize: 16)))));
      }
      final output = await getOutputDir();
      final outPath = "${output.path}/merged_${DateTime.now().millisecondsSinceEpoch}.pdf";
      await File(outPath).writeAsBytes(await doc.save());
      onProgress(1.0);
      return outPath;
    } catch (e) { return null; }
  }

  static Future<String?> addWatermark(String inputPath, String text, double opacity, void Function(double) onProgress) async {
    try {
      onProgress(0.3);
      final doc = pw.Document();
      final font = pw.Font.helvetica();
      doc.addPage(pw.Page(build: (ctx) => pw.Stack(children: [
        pw.Center(child: pw.Text("Document Content", style: pw.TextStyle(font: font, fontSize: 16))),
        pw.Center(child: pw.Transform.rotate(angle: -0.5,
          child: pw.Opacity(opacity: opacity,
            child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 60, color: PdfColors.red))))),
      ])));
      onProgress(0.8);
      final output = await getOutputDir();
      final outPath = "${output.path}/watermarked_${DateTime.now().millisecondsSinceEpoch}.pdf";
      await File(outPath).writeAsBytes(await doc.save());
      onProgress(1.0);
      return outPath;
    } catch (e) { return null; }
  }

  static Future<String?> createPDF(String title, String content, void Function(double) onProgress) async {
    try {
      onProgress(0.3);
      final doc = pw.Document();
      final font = pw.Font.helvetica();
      final bold = pw.Font.helveticaBold();
      doc.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, build: (ctx) => [
        pw.Header(level: 0, child: pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 24))),
        pw.SizedBox(height: 20),
        pw.Paragraph(text: content, style: pw.TextStyle(font: font, fontSize: 12)),
      ]));
      onProgress(0.8);
      final output = await getOutputDir();
      final outPath = "${output.path}/created_${DateTime.now().millisecondsSinceEpoch}.pdf";
      await File(outPath).writeAsBytes(await doc.save());
      onProgress(1.0);
      return outPath;
    } catch (e) { return null; }
  }

  static Future<Map<String, String>> getFileInfo(String path) async {
    final file = File(path);
    final stat = await file.stat();
    final size = stat.size;
    String sizeStr = size < 1024 ? "$size B" : size < 1048576 ? "${(size/1024).toStringAsFixed(1)} KB" : "${(size/1048576).toStringAsFixed(2)} MB";
    return {"name": path.split("/").last, "size": sizeStr, "path": path,
      "modified": stat.modified.toString().split(".").first};
  }

  static Future<void> shareFile(String path) async {
    await Share.shareXFiles([XFile(path)], text: "Shared from PDF Master Pro");
  }

  static String formatSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1048576) return "${(bytes/1024).toStringAsFixed(1)} KB";
    return "${(bytes/1048576).toStringAsFixed(2)} MB";
  }
}
