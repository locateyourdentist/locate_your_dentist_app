import '../models/whatsapp_template_model.dart';

class WhatsappTemplateValidator {
  static final RegExp _variableRegex = RegExp(r'\{\{(\d+)\}\}');

  static List<int> extractVariableNumbers(String body) {
    return _variableRegex
        .allMatches(body)
        .map((m) => int.parse(m.group(1)!))
        .toList();
  }

  static List<ValidationCheckResult> validate(
    WhatsappTemplateModel template, {
    List<WhatsappTemplateModel> existing = const [],
  }) {
    final results = <ValidationCheckResult>[];

    results.add(ValidationCheckResult(
      ruleName: 'Template Name',
      passed: template.templateName.trim().isNotEmpty,
      message: template.templateName.trim().isNotEmpty
          ? 'Template name is present'
          : 'Template name is required',
    ));

    final duplicateExists = existing.any((t) =>
        t.id != template.id &&
        t.templateName.trim().toLowerCase() ==
            template.templateName.trim().toLowerCase());
    results.add(ValidationCheckResult(
      ruleName: 'Duplicate Name',
      passed: !duplicateExists,
      message: duplicateExists
          ? 'A template with this name already exists'
          : 'Template name is unique',
    ));

    final bodyLen = template.body.length;
    results.add(ValidationCheckResult(
      ruleName: 'Body Length',
      passed: bodyLen > 0 && bodyLen <= 1024,
      message: bodyLen == 0
          ? 'Body cannot be empty'
          : bodyLen > 1024
              ? 'Body exceeds 1024 characters ($bodyLen/1024)'
              : 'Body length OK ($bodyLen/1024)',
    ));

    final footerLen = template.footer?.length ?? 0;
    results.add(ValidationCheckResult(
      ruleName: 'Footer Length',
      passed: footerLen <= 60,
      message: footerLen <= 60
          ? 'Footer length OK ($footerLen/60)'
          : 'Footer exceeds 60 characters ($footerLen/60)',
    ));

    bool headerPassed = true;
    String headerMessage = 'Header is valid';
    switch (template.headerType) {
      case 'TEXT':
        final len = template.headerText?.length ?? 0;
        headerPassed = len > 0 && len <= 60;
        headerMessage = len == 0
            ? 'Header text is required'
            : len > 60
                ? 'Header text exceeds 60 characters ($len/60)'
                : 'Header text OK ($len/60)';
        break;
      case 'IMAGE':
      case 'VIDEO':
        headerPassed =
            template.headerMediaUrl != null && template.headerMediaUrl!.isNotEmpty;
        headerMessage = headerPassed
            ? 'Header media uploaded'
            : 'Please upload the header ${template.headerType.toLowerCase()}';
        break;
      case 'DOCUMENT':
        headerPassed =
            template.headerMediaUrl != null && template.headerMediaUrl!.trim().isNotEmpty;
        headerMessage = headerPassed
            ? 'Header document URL set'
            : 'Header document URL is required';
        break;
      default:
        headerPassed = true;
        headerMessage = 'No header';
    }
    results.add(ValidationCheckResult(
      ruleName: 'Header',
      passed: headerPassed,
      message: headerMessage,
    ));

    final variableNumbers = extractVariableNumbers(template.body);
    bool variablesPassed = true;
    String variablesMessage = 'No variables used';
    if (variableNumbers.isNotEmpty) {
      final uniqueSorted = variableNumbers.toSet().toList()..sort();
      final isContiguous =
          uniqueSorted.asMap().entries.every((e) => e.value == e.key + 1);
      if (!isContiguous) {
        variablesPassed = false;
        variablesMessage =
            'Variables must be sequential starting from {{1}} with no gaps';
      } else {
        final firstSeenOrder = <int>[];
        final seen = <int>{};
        for (final n in variableNumbers) {
          if (seen.add(n)) firstSeenOrder.add(n);
        }
        final isAscending =
            firstSeenOrder.asMap().entries.every((e) => e.value == e.key + 1);
        if (!isAscending) {
          variablesPassed = false;
          variablesMessage = 'Variables must appear in ascending order in the body';
        } else {
          variablesMessage = 'Variables {{1}}..{{${uniqueSorted.last}}} are sequential';
        }
      }
    }
    results.add(ValidationCheckResult(
      ruleName: 'Variable Order',
      passed: variablesPassed,
      message: variablesMessage,
    ));

    final buttonCountOk = template.buttons.length <= 10;
    results.add(ValidationCheckResult(
      ruleName: 'Button Limit',
      passed: buttonCountOk,
      message: buttonCountOk
          ? '${template.buttons.length}/10 buttons'
          : 'A template cannot have more than 10 buttons',
    ));

    final buttonFieldErrors = <String>[];
    for (var i = 0; i < template.buttons.length; i++) {
      final btn = template.buttons[i];
      final label = 'Button ${i + 1}';
      switch (btn.type) {
        case 'QUICK_REPLY':
          if ((btn.text ?? '').trim().isEmpty) {
            buttonFieldErrors.add('$label: quick reply text is required');
          }
          break;
        case 'CALL':
          if ((btn.phoneNumber ?? '').trim().isEmpty) {
            buttonFieldErrors.add('$label: phone number is required');
          }
          break;
        case 'WEBSITE':
        case 'DYNAMIC_URL':
          if ((btn.url ?? '').trim().isEmpty) {
            buttonFieldErrors.add('$label: URL is required');
          }
          break;
        case 'COPY_CODE':
          if ((btn.exampleCode ?? '').trim().isEmpty) {
            buttonFieldErrors.add('$label: example code is required');
          }
          break;
      }
    }
    results.add(ValidationCheckResult(
      ruleName: 'Button Fields',
      passed: buttonFieldErrors.isEmpty,
      message: buttonFieldErrors.isEmpty
          ? 'All button fields are complete'
          : buttonFieldErrors.join('; '),
    ));

    return results;
  }
}
