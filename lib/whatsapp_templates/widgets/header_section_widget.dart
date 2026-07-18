import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import '../controllers/template_builder_controller.dart';

const Map<String, String> kHeaderTypeLabels = {
  'NONE': 'None',
  'TEXT': 'Text',
  'IMAGE': 'Image',
  'VIDEO': 'Video',
  'DOCUMENT': 'Document',
};

class HeaderSectionWidget extends StatelessWidget {
  final TemplateBuilderController controller;

  const HeaderSectionWidget({super.key, required this.controller});

  Future<void> _pickMedia(bool isVideo) async {
    final picker = ImagePicker();
    final XFile? file = isVideo
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final mimeType = isVideo ? 'video/mp4' : 'image/jpeg';
    controller.setHeaderMedia(bytes, file.name, mimeType);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Header', style: AppTextStyles.subtitle(context)),
        const SizedBox(height: 8),
        CustomDropdownField(
          hint: 'Header Type',
          items: kHeaderTypeLabels.values.toList(),
          selectedValue: kHeaderTypeLabels[controller.current.headerType],
          onChanged: (value) {
            final key = kHeaderTypeLabels.entries
                .firstWhere((e) => e.value == value)
                .key;
            controller.setHeaderType(key);
          },
        ),
        const SizedBox(height: 10),
        if (controller.current.headerType == 'TEXT')
          CustomTextField(
            hint: 'Header Text (max 60 chars)',
            controller: controller.headerTextController,
            maxLength: 60,
            validator: (_) => null,
            onTap: () {},
          ),
        if (controller.current.headerType == 'IMAGE' ||
            controller.current.headerType == 'VIDEO')
          _mediaPicker(context, isVideo: controller.current.headerType == 'VIDEO'),
        if (controller.current.headerType == 'DOCUMENT')
          CustomTextField(
            hint: 'Document URL (hosted link)',
            controller: controller.headerDocumentUrlController,
            validator: (_) => null,
            onTap: () {},
          ),
      ],
    );
  }

  Widget _mediaPicker(BuildContext context, {required bool isVideo}) {
    final hasBytes = controller.pendingHeaderMediaBytes != null;
    final hasExistingUrl = controller.current.headerMediaUrl != null &&
        controller.current.headerMediaUrl!.isNotEmpty;

    return Row(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade100,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: hasBytes && !isVideo
                ? Image.memory(controller.pendingHeaderMediaBytes!, fit: BoxFit.cover)
                : Icon(
                    isVideo ? Icons.videocam : Icons.image,
                    color: hasBytes || hasExistingUrl ? AppColors.primary : Colors.grey,
                    size: 32,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasBytes
                    ? (controller.pendingHeaderMediaFileName ?? 'Selected file')
                    : (hasExistingUrl ? 'Media uploaded' : 'No file selected'),
                style: AppTextStyles.caption(context, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                onPressed: () => _pickMedia(isVideo),
                icon: const Icon(Icons.upload, size: 16),
                label: Text(isVideo ? 'Upload Video' : 'Upload Image'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
