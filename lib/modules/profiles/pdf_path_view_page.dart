import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class ViewPDFPage extends StatefulWidget {
  final String pdfUrl;
  const ViewPDFPage({super.key, required this.pdfUrl});
  @override
  State<ViewPDFPage> createState() => _ViewPDFPageState();
}
class _ViewPDFPageState extends State<ViewPDFPage> {
  String? localPath;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    downloadPDF();
  }
  Future<void> downloadPDF() async {
    setState(() => loading = true);
    try {
      var dir = await getApplicationDocumentsDirectory();
      String filePath = "${dir.path}/resume.pdf";
      await Dio().download(
        // localPath,
        widget.pdfUrl,
        filePath,
        onReceiveProgress: (rec, total) {
          print("Downloading: $rec / $total");
        },
      );

      File file = File(filePath);
      if (file.existsSync()) {
        setState(() {
          localPath = filePath;
          loading = false;
        });
      } else {
        print("File does not exist");
        setState(() => loading = false);
      }
    } catch (e) {
      print("PDF Download Error: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resume PDF"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : localPath == null
          ? const Center(child: Text("Unable to load PDF"))
          : PDFView(
        filePath: localPath!,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}
