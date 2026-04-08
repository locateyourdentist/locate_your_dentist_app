import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

  class ClinicWeb extends StatefulWidget {
  const ClinicWeb({super.key});
  @override
  State<ClinicWeb> createState() => _ClinicWebState();
  }
  class _ClinicWebState extends State<ClinicWeb> {
  late final String url;
  late final String clinicName;
  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    url = args['url'] ?? '';
    clinicName = args['clinicName'] ?? 'Clinic WebView';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchUrl(url);
    });
  }
  Future<void> _launchUrl(String url) async {
    String safeUrl = url.trim();

    if (!safeUrl.startsWith('http://') &&
        !safeUrl.startsWith('https://')) {
      safeUrl = 'https://$safeUrl';
    }

    debugPrint('Launching: $safeUrl');
    debugPrint(url);
    final Uri uri = Uri.parse(safeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $safeUrl');
      Get.snackbar('Error', 'Could not open the website',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(clinicName)),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
