import 'dart:convert';

/// Sale post `message` is stored as a plain string on the backend, but since
/// the create pages now write a JSON-encoded Quill delta into that same
/// field, reads need to transparently support both the new rich-text posts
/// and any older plain-text posts created before this change.
String quillMessageToPlainText(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded
          .map((e) => (e is Map ? e['insert']?.toString() : null) ?? '')
          .join()
          .trim();
    }
  } catch (_) {}
  return raw;
}

List<Map<String, dynamic>> quillMessageToDelta(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return [
      {"insert": "\n"},
    ];
  }
  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return List<Map<String, dynamic>>.from(decoded);
    }
  } catch (_) {}
  return [
    {"insert": "$raw\n"},
  ];
}
