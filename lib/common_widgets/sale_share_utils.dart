import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:locate_your_dentist/utills/constants.dart';

/// Points at the backend's server-rendered `/sale/:id` preview page
/// (routes/sale_post_public_routes.js on the API server) — deliberately NOT
/// Uri.base.origin/the site's own domain. www.locateyourdentist.com is a
/// separate Render Static Site (the Flutter build) with no knowledge of
/// this route; only the backend's own origin (AppConstants.baseUrl) serves
/// it. That preview page carries proper Open Graph tags for link previews
/// (WhatsApp, etc.) and links onward into the app.
String? saleDetailUrl(String? postId) {
  if (postId == null || postId.isEmpty) return null;
  final origin = AppConstants.baseUrl.endsWith('/')
      ? AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 1)
      : AppConstants.baseUrl;
  return '$origin/sale/$postId';
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
        await Share.shareXFiles([
          XFile.fromData(
            response.bodyBytes,
            name: 'sale_ad.jpg',
            mimeType: 'image/jpeg',
          ),
        ], text: shareText);
        return;
      }
    } catch (_) {}
  }

  await Share.share(shareText);
}
