import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:locate_your_dentist/utills/constants.dart';

/// Points at the backend's server-rendered `/job/:jobId` preview page
/// (routes/job_public_routes.js on the API server) — deliberately NOT
/// Uri.base.origin/the site's own domain. www.locateyourdentist.com is a
/// separate Render Static Site (the Flutter build) with no knowledge of
/// this route; only the backend's own origin (AppConstants.baseUrl) serves
/// it. That preview page carries proper Open Graph tags for link previews
/// (WhatsApp, etc.) and links onward into the app.
String? jobDetailUrl(String? jobId) {
  if (jobId == null || jobId.isEmpty) return null;
  final origin = AppConstants.baseUrl.endsWith('/')
      ? AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 1)
      : AppConstants.baseUrl;
  return '$origin/job/$jobId';
}

String plainTextFromDelta(List<Map<String, dynamic>>? delta) {
  if (delta == null) return '';
  return delta.map((e) => e['insert'] ?? '').join().trim();
}

Future<void> shareJobPost({
  required String jobTitle,
  required String orgName,
  String? jobType,
  String? salary,
  String? location,
  String? description,
  String? imageUrl,
  String? jobId,
}) async {
  final buffer = StringBuffer()
    ..writeln("💼 $jobTitle")
    ..writeln()
    ..writeln("at $orgName");
  if ((jobType ?? '').trim().isNotEmpty) {
    buffer.writeln("Type: $jobType");
  }
  if ((salary ?? '').trim().isNotEmpty) {
    buffer.writeln("Salary: $salary");
  }
  if ((location ?? '').trim().isNotEmpty) {
    buffer.writeln("Location: $location");
  }
  final trimmedDescription = (description ?? '').trim();
  if (trimmedDescription.isNotEmpty) {
    buffer.writeln();
    buffer.writeln(
      trimmedDescription.length > 300
          ? '${trimmedDescription.substring(0, 300)}...'
          : trimmedDescription,
    );
  }
  final detailUrl = jobDetailUrl(jobId);
  if (detailUrl != null) {
    buffer.writeln();
    buffer.writeln("View full details: $detailUrl");
  }
  buffer.write("\nShared via Locate Your Dentist");
  final shareText = buffer.toString();

  if (imageUrl != null && imageUrl.trim().isNotEmpty) {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        await Share.shareXFiles([
          XFile.fromData(
            response.bodyBytes,
            name: 'job_post.jpg',
            mimeType: 'image/jpeg',
          ),
        ], text: shareText);
        return;
      }
    } catch (_) {}
  }

  await Share.share(shareText);
}
