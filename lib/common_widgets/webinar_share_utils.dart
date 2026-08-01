import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

const String _kProdWebOrigin = 'https://www.locateyourdentist.com';

String? webinarDetailUrl(String? webinarId) {
  if (webinarId == null || webinarId.isEmpty) return null;
  final origin = kIsWeb ? Uri.base.origin : _kProdWebOrigin;
  return '$origin/viewWebinarDetailWebPage/$webinarId';
}

String plainTextFromDelta(List<Map<String, dynamic>>? delta) {
  if (delta == null) return '';
  return delta.map((e) => e['insert'] ?? '').join().trim();
}

Future<void> shareWebinarPost({
  required String webinarTitle,
  required String orgName,
  String? place,
  String? date,
  String? startTime,
  String? endTime,
  String? description,
  String? imageUrl,
  String? webinarId,
}) async {
  final buffer = StringBuffer()
    ..writeln("🎓 $webinarTitle")
    ..writeln()
    ..writeln("by $orgName");
  if ((place ?? '').trim().isNotEmpty) {
    buffer.writeln("Location: $place");
  }
  if ((date ?? '').trim().isNotEmpty) {
    buffer.writeln("Date: $date");
  }
  if ((startTime ?? '').trim().isNotEmpty || (endTime ?? '').trim().isNotEmpty) {
    buffer.writeln("Time: ${startTime ?? ''} - ${endTime ?? ''}");
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
  final detailUrl = webinarDetailUrl(webinarId);
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
        await Share.shareXFiles(
          [
            XFile.fromData(
              response.bodyBytes,
              name: 'webinar_post.jpg',
              mimeType: 'image/jpeg',
            ),
          ],
          text: shareText,
        );
        return;
      }
    } catch (_) {}
  }

  await Share.share(shareText);
}
