import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import '../models/whatsapp_template_model.dart';

class WhatsappTemplateService {
  String get _base =>
      "${AppConstants.baseUrl}${AppConstants.whatsappTemplateUrl}";

  String get _token => Api.userInfo.read('token') ?? "";

  Map<String, String> get _jsonHeaders => {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $_token",
      };

  Future<http.Response> getTemplates({String? status, String? search}) async {
    final query = <String, String>{};
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (search != null && search.isNotEmpty) query['search'] = search;
    final uri = Uri.parse(
      "$_base${AppConstants.getWhatsappTemplatesUrl}",
    ).replace(queryParameters: query.isEmpty ? null : query);
    return http.get(uri, headers: _jsonHeaders);
  }

  Future<http.Response> getTemplateById(String id) async {
    final uri = Uri.parse(
      "$_base${AppConstants.getWhatsappTemplateByIdUrl}/$id",
    );
    return http.get(uri, headers: _jsonHeaders);
  }

  Future<http.Response> _sendWithOptionalMedia(
    String url,
    WhatsappTemplateModel template, {
    Uint8List? mediaBytes,
    String? mediaFileName,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['templateName'] = template.templateName;
    request.fields['category'] = template.category;
    request.fields['language'] = template.language;
    request.fields['templateType'] = template.templateType;
    request.fields['headerType'] = template.headerType;
    request.fields['headerText'] = template.headerText ?? '';
    if (template.headerType == 'DOCUMENT') {
      request.fields['headerMediaUrl'] = template.headerMediaUrl ?? '';
    }
    request.fields['body'] = template.body;
    request.fields['footer'] = template.footer ?? '';
    request.fields['buttons'] = jsonEncode(
      template.buttons.map((b) => b.toJson()).toList(),
    );
    request.fields['createdBy'] = Api.userInfo.read('userId') ?? '';

    if (mediaBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'whatsappTemplateMedia',
          mediaBytes,
          filename: mediaFileName ?? 'headerMedia',
        ),
      );
    }

    request.headers.addAll({
      "Authorization": "Bearer $_token",
      "Accept": "application/json",
    });

    final streamed = await request.send();
    return http.Response.fromStream(streamed);
  }

  Future<http.Response> createTemplate(
    WhatsappTemplateModel template, {
    Uint8List? mediaBytes,
    String? mediaFileName,
  }) {
    final url = "$_base${AppConstants.createWhatsappTemplateUrl}";
    return _sendWithOptionalMedia(
      url,
      template,
      mediaBytes: mediaBytes,
      mediaFileName: mediaFileName,
    );
  }

  Future<http.Response> updateTemplate(
    String id,
    WhatsappTemplateModel template, {
    Uint8List? mediaBytes,
    String? mediaFileName,
  }) {
    final url = "$_base${AppConstants.updateWhatsappTemplateUrl}/$id";
    return _sendWithOptionalMedia(
      url,
      template,
      mediaBytes: mediaBytes,
      mediaFileName: mediaFileName,
    );
  }

  Future<http.Response> autoSaveTemplate(
    String id,
    WhatsappTemplateModel template,
  ) async {
    final url = Uri.parse(
      "$_base${AppConstants.autoSaveWhatsappTemplateUrl}/$id",
    );
    return http.post(url, headers: _jsonHeaders, body: jsonEncode(template.toJson()));
  }

  Future<http.Response> deleteTemplate(String id) async {
    final url = Uri.parse("$_base${AppConstants.deleteWhatsappTemplateUrl}/$id");
    return http.post(url, headers: _jsonHeaders);
  }

  Future<http.Response> duplicateTemplate(String id) async {
    final url = Uri.parse(
      "$_base${AppConstants.duplicateWhatsappTemplateUrl}/$id",
    );
    return http.post(url, headers: _jsonHeaders);
  }

  Future<http.Response> submitToMeta(String id) async {
    final url = Uri.parse(
      "$_base${AppConstants.submitWhatsappTemplateToMetaUrl}/$id",
    );
    return http.post(url, headers: _jsonHeaders);
  }

  Future<http.Response> restoreVersion(String id, int versionIndex) async {
    final url = Uri.parse(
      "$_base${AppConstants.restoreWhatsappTemplateVersionUrl}/$id",
    );
    return http.post(
      url,
      headers: _jsonHeaders,
      body: jsonEncode({'versionIndex': versionIndex}),
    );
  }
}
