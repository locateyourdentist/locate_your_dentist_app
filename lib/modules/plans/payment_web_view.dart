import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ClinicWeb1 extends StatefulWidget {
  const ClinicWeb1({super.key});

  @override
  State<ClinicWeb1> createState() => _ClinicWeb1State();
}

class _ClinicWeb1State extends State<ClinicWeb1> {
  late final String url;
  late final String clinicName;
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>;
    url = args['url'];
    clinicName = args['clinicName'] ?? 'Payment';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() => isLoading = false);
          },
          onWebResourceError: (error) {
            Get.snackbar("Error", error.description);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(clinicName)),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
