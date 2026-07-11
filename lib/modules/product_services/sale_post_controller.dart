import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// One picked photo, holding either raw bytes (web) or a local File
/// (mobile/desktop) so the same UI can render either source.
class PickedSaleImage {
  final Uint8List? bytes;
  final File? file;
  const PickedSaleImage({this.bytes, this.file});
}

/// A single sale listing. Purely local/in-memory for now — there is no
/// backend "create sale post" endpoint yet, so [SalePostController] just
/// keeps these in memory so the create pages and list pages can share data.
/// Swap [SalePostController] internals for real API calls once the endpoint
/// exists; this model can stay the same.
class SalePostItem {
  final String id;
  final String mobileNumber;
  final String message;
  final String price;
  final bool negotiable;
  final String userType;
  final List<PickedSaleImage> images;
  final DateTime postedAt;

  SalePostItem({
    required this.id,
    required this.mobileNumber,
    required this.message,
    required this.price,
    required this.negotiable,
    required this.userType,
    required this.images,
    required this.postedAt,
  });
}

/// In-memory store for sale listings shared between the create pages and
/// the list pages so the flow is fully testable before the backend exists.
///
/// TODO: once a real "create/list sale post" API is available, replace
/// [addPost] with the corresponding network call and populate [posts] from
/// the API response instead of local state.
class SalePostController extends GetxController {
  final List<SalePostItem> posts = [];

  void addPost(SalePostItem post) {
    posts.insert(0, post);
    update();
  }
}
