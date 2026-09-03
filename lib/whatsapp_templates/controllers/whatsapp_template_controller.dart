import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/custom_toast.dart';
import '../models/whatsapp_template_model.dart';
import '../services/whatsapp_template_service.dart';

class WhatsappTemplateController extends GetxController {
  final WhatsappTemplateService _service = WhatsappTemplateService();

  List<WhatsappTemplateModel> _templates = [];
  List<WhatsappTemplateModel> get templates => _templates;

  bool isLoading = false;
  String searchQuery = '';
  String statusFilter = 'All';

  List<WhatsappTemplateModel> get filteredTemplates {
    return _templates.where((t) {
      final matchesStatus =
          statusFilter == 'All' ||
          t.status.toLowerCase() == statusFilter.toLowerCase();
      final matchesSearch =
          searchQuery.trim().isEmpty ||
          t.templateName.toLowerCase().contains(
            searchQuery.trim().toLowerCase(),
          );
      return matchesStatus && matchesSearch;
    }).toList();
  }

  Future<void> fetchTemplates() async {
    isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      update();
    });
    try {
      final response = await _service.getTemplates();
      final data = jsonDecode(response.body);
      if (data['status'].toString().toLowerCase() == 'success') {
        _templates = (data['data'] as List<dynamic>? ?? [])
            .map((t) => WhatsappTemplateModel.fromJson(t))
            .toList();
      }
    } catch (error) {
      debugPrint('fetchTemplates error: $error');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> deleteTemplate(String id, BuildContext context) async {
    try {
      final response = await _service.deleteTemplate(id);
      final data = jsonDecode(response.body);
      if (data['status'].toString().toLowerCase() == 'success') {
        _templates.removeWhere((t) => t.id == id);
        showCustomToast(context, 'Template deleted');
        update();
      } else {
        showCustomToast(
          context,
          data['message'] ?? 'Failed to delete template',
        );
      }
    } catch (error) {
      showCustomToast(context, 'Failed to delete template');
    }
  }

  Future<void> duplicateTemplate(String id, BuildContext context) async {
    try {
      final response = await _service.duplicateTemplate(id);
      final data = jsonDecode(response.body);
      if (data['status'].toString().toLowerCase() == 'success') {
        _templates.insert(0, WhatsappTemplateModel.fromJson(data['data']));
        showCustomToast(context, 'Template duplicated');
        update();
      } else {
        showCustomToast(
          context,
          data['message'] ?? 'Failed to duplicate template',
        );
      }
    } catch (error) {
      showCustomToast(context, 'Failed to duplicate template');
    }
  }

  void setStatusFilter(String status) {
    statusFilter = status;
    update();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    update();
  }
}
