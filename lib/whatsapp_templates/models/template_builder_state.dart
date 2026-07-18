import 'dart:convert';
import 'whatsapp_template_model.dart';

/// Lean snapshot of only the fields a user actively edits, used for undo/redo.
/// Deliberately excludes media bytes/ids and metadata so snapshots stay cheap.
class TemplateBuilderState {
  final String headerType;
  final String? headerText;
  final String body;
  final String? footer;
  final List<WhatsappTemplateButton> buttons;

  TemplateBuilderState({
    required this.headerType,
    this.headerText,
    required this.body,
    this.footer,
    required this.buttons,
  });

  factory TemplateBuilderState.fromModel(WhatsappTemplateModel model) {
    return TemplateBuilderState(
      headerType: model.headerType,
      headerText: model.headerText,
      body: model.body,
      footer: model.footer,
      buttons: model.buttons.map((b) => b.copyWith()).toList(),
    );
  }

  Map<String, dynamic> _compareMap() {
    return {
      'headerType': headerType,
      'headerText': headerText,
      'body': body,
      'footer': footer,
      'buttons': buttons.map((b) => b.toJson()).toList(),
    };
  }

  bool isSameAs(TemplateBuilderState other) {
    return jsonEncode(_compareMap()) == jsonEncode(other._compareMap());
  }
}
