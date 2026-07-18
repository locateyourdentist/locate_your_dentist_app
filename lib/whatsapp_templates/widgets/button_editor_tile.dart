import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textfield.dart';
import '../models/whatsapp_template_model.dart';

const Map<String, String> kButtonTypeLabels = {
  'QUICK_REPLY': 'Quick Reply',
  'CALL': 'Call',
  'WEBSITE': 'Website',
  'COPY_CODE': 'Copy Code',
  'DYNAMIC_URL': 'Dynamic URL',
};

class ButtonEditorTile extends StatefulWidget {
  final int index;
  final WhatsappTemplateButton button;
  final ValueChanged<WhatsappTemplateButton> onChanged;
  final VoidCallback onRemove;

  const ButtonEditorTile({
    super.key,
    required this.index,
    required this.button,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<ButtonEditorTile> createState() => _ButtonEditorTileState();
}

class _ButtonEditorTileState extends State<ButtonEditorTile> {
  late final TextEditingController _textController;
  late final TextEditingController _phoneController;
  late final TextEditingController _urlController;
  late final TextEditingController _exampleCodeController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.button.text)
      ..addListener(() => widget.onChanged(widget.button.copyWith(text: _textController.text)));
    _phoneController = TextEditingController(text: widget.button.phoneNumber)
      ..addListener(() => widget.onChanged(widget.button.copyWith(phoneNumber: _phoneController.text)));
    _urlController = TextEditingController(text: widget.button.url)
      ..addListener(() => widget.onChanged(widget.button.copyWith(url: _urlController.text)));
    _exampleCodeController = TextEditingController(text: widget.button.exampleCode)
      ..addListener(() => widget.onChanged(widget.button.copyWith(exampleCode: _exampleCodeController.text)));
  }

  @override
  void dispose() {
    _textController.dispose();
    _phoneController.dispose();
    _urlController.dispose();
    _exampleCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('button_${widget.index}'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.drag_indicator, color: AppColors.grey, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: CustomDropdownField(
                  hint: 'Button ${widget.index + 1} Type',
                  items: kButtonTypeLabels.values.toList(),
                  selectedValue: kButtonTypeLabels[widget.button.type],
                  onChanged: (value) {
                    final key = kButtonTypeLabels.entries
                        .firstWhere((e) => e.value == value)
                        .key;
                    widget.onChanged(widget.button.copyWith(type: key));
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.error, size: 18),
                onPressed: widget.onRemove,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._fieldsForType(),
        ],
      ),
    );
  }

  List<Widget> _fieldsForType() {
    switch (widget.button.type) {
      case 'QUICK_REPLY':
        return [
          CustomTextField(
            hint: 'Button label (e.g. Yes)',
            controller: _textController,
            onTap: () {},
            validator: (_) => null,
            fillColor: Colors.grey[50],
          ),
        ];
      case 'CALL':
        return [
          CustomTextField(
            hint: 'Button label (e.g. Call Now)',
            controller: _textController,
            onTap: () {},
            validator: (_) => null,
          ),
          const SizedBox(height: 8),
          CustomTextField(
            hint: 'Phone number (+91xxxxxxxxxx)',
            controller: _phoneController,
            onTap: () {},
            validator: (_) => null,
            keyboardType: TextInputType.phone,
          ),
        ];
      case 'WEBSITE':
        return [
          CustomTextField(
            hint: 'Button label (e.g. Visit Website)',
            controller: _textController,
            onTap: () {},
            validator: (_) => null,
          ),
          const SizedBox(height: 8),
          CustomTextField(
            hint: 'https://example.com',
            controller: _urlController,
            onTap: () {},
            validator: (_) => null,
          ),
        ];
      case 'DYNAMIC_URL':
        return [
          CustomTextField(
            hint: 'Button label (e.g. Track Order)',
            controller: _textController,
            onTap: () {},
            validator: (_) => null,
          ),
          const SizedBox(height: 8),
          CustomTextField(
            hint: 'https://example.com/{{1}}',
            controller: _urlController,
            onTap: () {},
            validator: (_) => null,
          ),
        ];
      case 'COPY_CODE':
        return [
          CustomTextField(
            hint: 'Example code (e.g. SAVE20)',
            controller: _exampleCodeController,
            onTap: () {},
            validator: (_) => null,
          ),
        ];
      default:
        return [];
    }
  }
}
