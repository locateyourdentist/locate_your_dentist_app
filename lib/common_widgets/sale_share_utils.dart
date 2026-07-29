import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

String? saleDetailUrl(String? postId) {
  if (postId == null || postId.isEmpty || !kIsWeb) return null;
  return '${Uri.base.origin}/salePostDetailWebPage/$postId';
}

Future<void> shareSalePost({
  required String message,
  required String price,
  required String mobileNumber,
  required String userType,
  String? imageUrl,
  String? postId,
}) async {
  final buffer = StringBuffer()
    ..writeln("🦷 $userType Ad")
    ..writeln()
    ..writeln(message)
    ..writeln()
    ..writeln("Price: ₹$price");
  if (mobileNumber.trim().isNotEmpty) {
    buffer.writeln("Contact: $mobileNumber");
  }
  final detailUrl = saleDetailUrl(postId);
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
              name: 'sale_ad.jpg',
              mimeType: 'image/jpeg',
            ),
          ],
          text: shareText,
        );
        return;
      }
    } catch (_) {
    }
  }

  await Share.share(shareText);
}
