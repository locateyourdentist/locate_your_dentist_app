import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_quill/flutter_quill.dart';


class EditorPage extends StatefulWidget {
 // const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,

          /// ✅ IMAGE HANDLING FOR ALL PLATFORMS
          onImagePaste: (Uint8List imageBytes) async {
            try {
              final imageUrl = await uploadImageToServer(imageBytes);
              return imageUrl; // MUST return URL
            } catch (e) {
              debugPrint("Upload failed: $e");
              return null;
            }
          },
        ),
      ),
    );
  }

  /// 🌐 Upload image to your Node.js API
  Future<String> uploadImageToServer(Uint8List bytes) async {
    final dio = Dio();

    FormData formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(
        bytes,
        filename: "image_${DateTime.now().millisecondsSinceEpoch}.jpg",
      ),
    });

    final response = await dio.post(
      "http://192.168.31.117:3000/lyd/user/uploadImages",
      data: formData,
    );

    return response.data["url"];
  }

  void saveDocument() {
    final jsonData =
    jsonEncode(_controller.document.toDelta().toJson());

    debugPrint("Saved JSON: $jsonData");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Document Saved")),
    );
  }

  void loadDocument() {
    const sample = [
      {"insert": "Hello \n"},
      {"insert": "This is rich text editor\n", "attributes": {"bold": true}}
    ];

    _controller.document = Document.fromJson(sample);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Universal Text Editor"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveDocument,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: loadDocument,
          ),
        ],
      ),
      body: Column(
        children: [
          QuillSimpleToolbar(
            controller: _controller,
            config: QuillSimpleToolbarConfig(
              embedButtons: FlutterQuillEmbeds.toolbarButtons(),
              showClipboardPaste: true,
            ),
          ),

          Expanded(
            child: QuillEditor(
              controller: _controller,
              focusNode: _focusNode,
              scrollController: _scrollController,
              config: QuillEditorConfig(
                placeholder: "Start typing...",
                padding: const EdgeInsets.all(16),
                embedBuilders: FlutterQuillEmbeds.editorBuilders(
                  imageEmbedConfig: QuillEditorImageEmbedConfig(
                    imageProviderBuilder: (context, imageUrl) {
                      return NetworkImage(imageUrl);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}