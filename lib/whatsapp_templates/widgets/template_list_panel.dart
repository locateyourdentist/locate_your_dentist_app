import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import '../controllers/whatsapp_template_controller.dart';
import '../controllers/template_builder_controller.dart';
import '../models/whatsapp_template_model.dart';
import 'custom_button.dart';
import 'template_card.dart';
import 'whatsapp_preview_panel.dart';

const List<String> kStatusFilters = ['All', 'Approved', 'Pending', 'Rejected', 'Draft'];

class TemplateListPanel extends StatefulWidget {
  final WhatsappTemplateController listController;
  final TemplateBuilderController builderController;
  final ValueChanged<WhatsappTemplateModel> onSelectTemplate;

  const TemplateListPanel({
    super.key,
    required this.listController,
    required this.builderController,
    required this.onSelectTemplate,
  });

  @override
  State<TemplateListPanel> createState() => _TemplateListPanelState();
}

class _TemplateListPanelState extends State<TemplateListPanel> {
  late final TextEditingController _searchController;

  WhatsappTemplateController get listController => widget.listController;
  TemplateBuilderController get builderController => widget.builderController;
  ValueChanged<WhatsappTemplateModel> get onSelectTemplate => widget.onSelectTemplate;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()
      ..addListener(() => listController.setSearchQuery(_searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _previewTemplate(BuildContext context, WhatsappTemplateModel template) {
    final tempController = TemplateBuilderController();
    tempController.loadTemplate(template);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: WhatsappPreviewPanel(controller: tempController),
          ),
        ),
      ),
    ).then((_) => tempController.onClose());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        border: const Border(right: BorderSide(color: Colors.black12)),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([listController, builderController]),
        builder: (context, _) {
          final ctrl = listController;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Templates', style: AppTextStyles.headline(context)),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.primary),
                    onPressed: ctrl.fetchTemplates,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CustomTextField(
                hint: 'Search templates',
                icon: Icons.search,
                controller: _searchController,
                onTap: () {},
                validator: (_) => null,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kStatusFilters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final status = kStatusFilters[index];
                    final selected = ctrl.statusFilter == status;
                    return ChoiceChip(
                      label: Text(status),
                      selected: selected,
                      selectedColor: AppColors.primary,
                      labelStyle: AppTextStyles.caption(
                        context,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                      onSelected: (_) => ctrl.setStatusFilter(status),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'New',
                      icon: Icons.add,
                      onPressed: () {
                        builderController.newTemplate();
                        onSelectTemplate(builderController.current);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      label: 'Duplicate',
                      icon: Icons.copy_all_outlined,
                      outlined: true,
                      onPressed: builderController.current.id == null
                          ? null
                          : () => listController.duplicateTemplate(
                              builderController.current.id!, context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      label: 'Delete',
                      icon: Icons.delete_outline,
                      outlined: true,
                      color: AppColors.error,
                      onPressed: builderController.current.id == null
                          ? null
                          : () async {
                              await listController.deleteTemplate(
                                  builderController.current.id!, context);
                              builderController.newTemplate();
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ctrl.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ctrl.filteredTemplates.isEmpty
                        ? Center(
                            child: Text(
                              'No templates yet',
                              style: AppTextStyles.caption(context, color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            itemCount: ctrl.filteredTemplates.length,
                            itemBuilder: (context, index) {
                              final template = ctrl.filteredTemplates[index];
                              return TemplateCard(
                                template: template,
                                selected: builderController.current.id == template.id,
                                onEdit: () => onSelectTemplate(template),
                                onClone: () => listController.duplicateTemplate(template.id!, context),
                                onDelete: () => listController.deleteTemplate(template.id!, context),
                                onPreview: () => _previewTemplate(context, template),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
