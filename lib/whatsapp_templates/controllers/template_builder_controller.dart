import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import '../models/whatsapp_template_model.dart';
import '../models/template_builder_state.dart';
import '../services/whatsapp_template_service.dart';
import '../utils/whatsapp_template_validator.dart';
import '../utils/highlighting_text_controller.dart';

class TemplateBuilderController extends GetxController {
  final WhatsappTemplateService _service = WhatsappTemplateService();

  WhatsappTemplateModel current = WhatsappTemplateModel.empty();

  final TextEditingController nameController = TextEditingController();
  final HighlightingTextEditingController bodyController =
      HighlightingTextEditingController();
  final TextEditingController footerController = TextEditingController();
  final TextEditingController headerTextController = TextEditingController();
  final TextEditingController headerDocumentUrlController =
      TextEditingController();

  Uint8List? pendingHeaderMediaBytes;
  String? pendingHeaderMediaFileName;

  final List<TemplateBuilderState> _undoStack = [];
  final List<TemplateBuilderState> _redoStack = [];

  bool isDirty = false;
  bool isSaving = false;
  Timer? _autoSaveTimer;

  bool get canUndo => _undoStack.length > 1;
  bool get canRedo => _redoStack.isNotEmpty;

  TemplateBuilderController() {
    bodyController.addListener(pushUndoSnapshot);
    headerTextController.addListener(pushUndoSnapshot);
    footerController.addListener(pushUndoSnapshot);
    headerDocumentUrlController.addListener(pushUndoSnapshot);
    nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    current.templateName = nameController.text;
    isDirty = true;
    update();
  }

  void loadTemplate(WhatsappTemplateModel template) {
    current = template;
    _syncModelToControllers();
    pendingHeaderMediaBytes = null;
    pendingHeaderMediaFileName = null;
    _undoStack
      ..clear()
      ..add(TemplateBuilderState.fromModel(current));
    _redoStack.clear();
    isDirty = false;
    update();
  }

  void newTemplate() {
    loadTemplate(WhatsappTemplateModel.empty());
  }

  void _syncControllersToModel() {
    current.templateName = nameController.text;
    current.body = bodyController.text;
    current.footer = footerController.text.isEmpty ? null : footerController.text;
    current.headerText =
        headerTextController.text.isEmpty ? null : headerTextController.text;
    if (current.headerType == 'DOCUMENT') {
      current.headerMediaUrl = headerDocumentUrlController.text.isEmpty
          ? null
          : headerDocumentUrlController.text;
    }
  }

  void _syncModelToControllers() {
    nameController.text = current.templateName;
    bodyController.text = current.body;
    footerController.text = current.footer ?? '';
    headerTextController.text = current.headerText ?? '';
    headerDocumentUrlController.text =
        current.headerType == 'DOCUMENT' ? (current.headerMediaUrl ?? '') : '';
  }

  void pushUndoSnapshot() {
    _syncControllersToModel();
    final snapshot = TemplateBuilderState.fromModel(current);
    if (_undoStack.isNotEmpty && _undoStack.last.isSameAs(snapshot)) return;
    _undoStack.add(snapshot);
    _redoStack.clear();
    isDirty = true;
    update();
  }

  void _applySnapshot(TemplateBuilderState snapshot) {
    current.headerType = snapshot.headerType;
    current.headerText = snapshot.headerText;
    current.body = snapshot.body;
    current.footer = snapshot.footer;
    current.buttons = snapshot.buttons.map((b) => b.copyWith()).toList();
    _syncModelToControllers();
    update();
  }

  void undo() {
    if (!canUndo) return;
    _syncControllersToModel();
    final currentSnapshot = TemplateBuilderState.fromModel(current);
    if (_undoStack.isNotEmpty && _undoStack.last.isSameAs(currentSnapshot)) {
      _redoStack.add(_undoStack.removeLast());
    } else {
      _redoStack.add(currentSnapshot);
    }
    _applySnapshot(_undoStack.last);
    isDirty = true;
  }

  void redo() {
    if (!canRedo) return;
    final snapshot = _redoStack.removeLast();
    _undoStack.add(snapshot);
    _applySnapshot(snapshot);
    isDirty = true;
  }

  void setHeaderType(String type) {
    current.headerType = type;
    if (type != 'IMAGE' && type != 'VIDEO') {
      pendingHeaderMediaBytes = null;
      pendingHeaderMediaFileName = null;
    }
    pushUndoSnapshot();
  }

  void setHeaderMedia(Uint8List bytes, String fileName, String mimeType) {
    pendingHeaderMediaBytes = bytes;
    pendingHeaderMediaFileName = fileName;
    current.headerMediaType = mimeType;
    pushUndoSnapshot();
  }

  void insertVariableAtCursor() {
    final numbers = WhatsappTemplateValidator.extractVariableNumbers(
      bodyController.text,
    );
    final next = numbers.isEmpty
        ? 1
        : (numbers.reduce((a, b) => a > b ? a : b) + 1);
    final token = '{{$next}}';
    final selection = bodyController.selection;
    final text = bodyController.text;
    final insertAt = selection.start >= 0 ? selection.start : text.length;
    final newText = text.replaceRange(insertAt, selection.end >= 0 ? selection.end : insertAt, token);
    bodyController.text = newText;
    bodyController.selection = TextSelection.collapsed(offset: insertAt + token.length);
    pushUndoSnapshot();
  }

  void addButton(WhatsappTemplateButton button) {
    if (current.buttons.length >= 10) return;
    current.buttons = [...current.buttons, button];
    pushUndoSnapshot();
  }

  void updateButton(int index, WhatsappTemplateButton button) {
    if (index < 0 || index >= current.buttons.length) return;
    final updated = [...current.buttons];
    updated[index] = button;
    current.buttons = updated;
    pushUndoSnapshot();
  }

  void removeButton(int index) {
    if (index < 0 || index >= current.buttons.length) return;
    final updated = [...current.buttons]..removeAt(index);
    current.buttons = updated;
    pushUndoSnapshot();
  }

  void reorderButtons(int oldIndex, int newIndex) {
    final updated = [...current.buttons];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    current.buttons = updated;
    pushUndoSnapshot();
  }

  List<ValidationCheckResult> validate({
    List<WhatsappTemplateModel> existing = const [],
  }) {
    _syncControllersToModel();
    return WhatsappTemplateValidator.validate(current, existing: existing);
  }

  Future<bool> saveDraft(
    BuildContext context, {
    bool silent = false,
    List<WhatsappTemplateModel> existing = const [],
  }) async {
    _syncControllersToModel();
    if (current.templateName.trim().isEmpty || current.body.trim().isEmpty) {
      if (!silent) {
        showCustomToast(context, 'Template name and body are required');
      }
      return false;
    }
    isSaving = true;
    update();
    try {
      final response = current.id == null
          ? await _service.createTemplate(
              current,
              mediaBytes: pendingHeaderMediaBytes,
              mediaFileName: pendingHeaderMediaFileName,
            )
          : await _service.updateTemplate(
              current.id!,
              current,
              mediaBytes: pendingHeaderMediaBytes,
              mediaFileName: pendingHeaderMediaFileName,
            );
      final data = jsonDecode(response.body);
      if (data['status'].toString().toLowerCase() == 'success') {
        current = WhatsappTemplateModel.fromJson(data['data']);
        pendingHeaderMediaBytes = null;
        pendingHeaderMediaFileName = null;
        isDirty = false;
        if (!silent) showCustomToast(context, 'Draft saved');
        update();
        return true;
      } else {
        if (!silent) {
          showCustomToast(context, data['message'] ?? 'Failed to save draft');
        }
        return false;
      }
    } catch (error) {
      if (!silent) showCustomToast(context, 'Failed to save draft');
      return false;
    } finally {
      isSaving = false;
      update();
    }
  }

  Future<bool> submitToMeta(
    BuildContext context, {
    List<WhatsappTemplateModel> existing = const [],
  }) async {
    final results = validate(existing: existing);
    if (results.any((r) => !r.passed)) {
      return false;
    }
    if (current.id == null) {
      final saved = await saveDraft(context, silent: true, existing: existing);
      if (!saved) return false;
    }
    isSaving = true;
    update();
    try {
      final response = await _service.submitToMeta(current.id!);
      final data = jsonDecode(response.body);
      if (data['status'].toString().toLowerCase() == 'success') {
        current = WhatsappTemplateModel.fromJson(data['data']);
        showCustomToast(context, 'Submitted to Meta for review');
        update();
        return true;
      } else {
        showCustomToast(context, data['message'] ?? 'Failed to submit to Meta');
        return false;
      }
    } catch (error) {
      showCustomToast(context, 'Failed to submit to Meta');
      return false;
    } finally {
      isSaving = false;
      update();
    }
  }

  Future<void> restoreVersionLocally(TemplateVersionSnapshot snapshot) async {
    pushUndoSnapshot();
    current.headerType = snapshot.headerType;
    current.headerText = snapshot.headerText;
    current.headerMediaUrl = snapshot.headerMediaUrl;
    current.body = snapshot.body;
    current.footer = snapshot.footer;
    current.buttons = snapshot.buttons.map((b) => b.copyWith()).toList();
    current.status = 'draft';
    _syncModelToControllers();
    pushUndoSnapshot();
  }

  String exportJson() {
    const encoder = JsonEncoder.withIndent('  ');
    _syncControllersToModel();
    return encoder.convert(current.toJson());
  }

  String? importJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return 'Invalid JSON: expected an object';
      }
      final imported = WhatsappTemplateModel.fromJson(decoded);
      current.templateName = imported.templateName;
      current.category = imported.category;
      current.language = imported.language;
      current.templateType = imported.templateType;
      current.headerType = imported.headerType;
      current.headerText = imported.headerText;
      current.headerMediaUrl = imported.headerMediaUrl;
      current.body = imported.body;
      current.footer = imported.footer;
      current.buttons = imported.buttons;
      _syncModelToControllers();
      pushUndoSnapshot();
      return null;
    } catch (error) {
      return 'Invalid JSON: $error';
    }
  }

  void startAutoSave(BuildContext context) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (isDirty && current.id != null && !isSaving) {
        _syncControllersToModel();
        try {
          final response = await _service.autoSaveTemplate(current.id!, current);
          final data = jsonDecode(response.body);
          if (data['status'].toString().toLowerCase() == 'success') {
            isDirty = false;
          }
        } catch (error) {
          debugPrint('autosave error: $error');
        }
      }
    });
  }

  void stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  @override
  void onClose() {
    stopAutoSave();
    nameController.dispose();
    bodyController.dispose();
    footerController.dispose();
    headerTextController.dispose();
    headerDocumentUrlController.dispose();
    super.onClose();
  }
}
