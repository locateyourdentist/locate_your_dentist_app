class WhatsappTemplateButton {
  String type; // QUICK_REPLY, CALL, WEBSITE, COPY_CODE, DYNAMIC_URL
  String? text;
  String? phoneNumber;
  String? url;
  String? exampleCode;

  WhatsappTemplateButton({
    required this.type,
    this.text,
    this.phoneNumber,
    this.url,
    this.exampleCode,
  });

  factory WhatsappTemplateButton.fromJson(Map<String, dynamic> json) {
    return WhatsappTemplateButton(
      type: json['type'] ?? 'QUICK_REPLY',
      text: json['text'],
      phoneNumber: json['phoneNumber'],
      url: json['url'],
      exampleCode: json['exampleCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      'phoneNumber': phoneNumber,
      'url': url,
      'exampleCode': exampleCode,
    };
  }

  WhatsappTemplateButton copyWith({
    String? type,
    String? text,
    String? phoneNumber,
    String? url,
    String? exampleCode,
  }) {
    return WhatsappTemplateButton(
      type: type ?? this.type,
      text: text ?? this.text,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      url: url ?? this.url,
      exampleCode: exampleCode ?? this.exampleCode,
    );
  }
}

class TemplateVersionSnapshot {
  final DateTime? snapshotAt;
  final String action; // draft_save, submit_to_meta
  final String templateName;
  final String category;
  final String language;
  final String templateType;
  final String headerType;
  final String? headerText;
  final String? headerMediaUrl;
  final String body;
  final String? footer;
  final List<WhatsappTemplateButton> buttons;
  final String status;

  TemplateVersionSnapshot({
    this.snapshotAt,
    required this.action,
    required this.templateName,
    required this.category,
    required this.language,
    required this.templateType,
    required this.headerType,
    this.headerText,
    this.headerMediaUrl,
    required this.body,
    this.footer,
    required this.buttons,
    required this.status,
  });

  factory TemplateVersionSnapshot.fromJson(Map<String, dynamic> json) {
    return TemplateVersionSnapshot(
      snapshotAt: json['snapshotAt'] != null
          ? DateTime.tryParse(json['snapshotAt'])
          : null,
      action: json['action'] ?? 'draft_save',
      templateName: json['templateName'] ?? '',
      category: json['category'] ?? '',
      language: json['language'] ?? '',
      templateType: json['templateType'] ?? 'TEXT',
      headerType: json['headerType'] ?? 'NONE',
      headerText: json['headerText'],
      headerMediaUrl: json['headerMediaUrl'],
      body: json['body'] ?? '',
      footer: json['footer'],
      buttons: (json['buttons'] as List<dynamic>? ?? [])
          .map((b) => WhatsappTemplateButton.fromJson(b))
          .toList(),
      status: json['status'] ?? 'draft',
    );
  }
}

class WhatsappTemplateModel {
  String? id;
  String templateName;
  String category; // MARKETING, UTILITY, AUTHENTICATION
  String language;
  String templateType; // TEXT, MEDIA, CAROUSEL, INTERACTIVE
  String headerType; // NONE, TEXT, IMAGE, VIDEO, DOCUMENT
  String? headerText;
  String? headerMediaUrl;
  String? headerMediaType;
  String body;
  String? footer;
  List<WhatsappTemplateButton> buttons;
  int variableCount;
  String status; // draft, pending, approved, rejected
  String? metaTemplateId;
  String? metaRejectionReason;
  DateTime? createdDate;
  DateTime? updatedDate;
  List<TemplateVersionSnapshot> versionHistory;

  WhatsappTemplateModel({
    this.id,
    required this.templateName,
    required this.category,
    required this.language,
    required this.templateType,
    required this.headerType,
    this.headerText,
    this.headerMediaUrl,
    this.headerMediaType,
    required this.body,
    this.footer,
    required this.buttons,
    this.variableCount = 0,
    this.status = 'draft',
    this.metaTemplateId,
    this.metaRejectionReason,
    this.createdDate,
    this.updatedDate,
    this.versionHistory = const [],
  });

  factory WhatsappTemplateModel.empty() {
    return WhatsappTemplateModel(
      templateName: '',
      category: 'MARKETING',
      language: 'English',
      templateType: 'TEXT',
      headerType: 'NONE',
      body: '',
      buttons: [],
    );
  }

  factory WhatsappTemplateModel.fromJson(Map<String, dynamic> json) {
    return WhatsappTemplateModel(
      id: json['_id'] ?? json['id'],
      templateName: json['templateName'] ?? '',
      category: json['category'] ?? 'MARKETING',
      language: json['language'] ?? 'English',
      templateType: json['templateType'] ?? 'TEXT',
      headerType: json['headerType'] ?? 'NONE',
      headerText: json['headerText'],
      headerMediaUrl: json['headerMediaUrl'],
      headerMediaType: json['headerMediaType'],
      body: json['body'] ?? '',
      footer: json['footer'],
      buttons: (json['buttons'] as List<dynamic>? ?? [])
          .map((b) => WhatsappTemplateButton.fromJson(b))
          .toList(),
      variableCount: json['variableCount'] ?? 0,
      status: json['status'] ?? 'draft',
      metaTemplateId: json['metaTemplateId'],
      metaRejectionReason: json['metaRejectionReason'],
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'])
          : null,
      updatedDate: json['updatedDate'] != null
          ? DateTime.tryParse(json['updatedDate'])
          : null,
      versionHistory: (json['versionHistory'] as List<dynamic>? ?? [])
          .map((v) => TemplateVersionSnapshot.fromJson(v))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'templateName': templateName,
      'category': category,
      'language': language,
      'templateType': templateType,
      'headerType': headerType,
      'headerText': headerText,
      'headerMediaUrl': headerMediaUrl,
      'headerMediaType': headerMediaType,
      'body': body,
      'footer': footer,
      'buttons': buttons.map((b) => b.toJson()).toList(),
      'variableCount': variableCount,
      'status': status,
    };
  }

  WhatsappTemplateModel copyWith({
    String? id,
    String? templateName,
    String? category,
    String? language,
    String? templateType,
    String? headerType,
    String? headerText,
    String? headerMediaUrl,
    String? headerMediaType,
    String? body,
    String? footer,
    List<WhatsappTemplateButton>? buttons,
    int? variableCount,
    String? status,
  }) {
    return WhatsappTemplateModel(
      id: id ?? this.id,
      templateName: templateName ?? this.templateName,
      category: category ?? this.category,
      language: language ?? this.language,
      templateType: templateType ?? this.templateType,
      headerType: headerType ?? this.headerType,
      headerText: headerText ?? this.headerText,
      headerMediaUrl: headerMediaUrl ?? this.headerMediaUrl,
      headerMediaType: headerMediaType ?? this.headerMediaType,
      body: body ?? this.body,
      footer: footer ?? this.footer,
      buttons: buttons ?? this.buttons,
      variableCount: variableCount ?? this.variableCount,
      status: status ?? this.status,
      metaTemplateId: metaTemplateId,
      metaRejectionReason: metaRejectionReason,
      createdDate: createdDate,
      updatedDate: updatedDate,
      versionHistory: versionHistory,
    );
  }
}

class ValidationCheckResult {
  final String ruleName;
  final bool passed;
  final String message;

  ValidationCheckResult({
    required this.ruleName,
    required this.passed,
    required this.message,
  });
}
