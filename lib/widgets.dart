import 'package:material_ui/material_ui.dart';

import 'l10n.dart';
import 'store.dart';

const gap = SizedBox(height: 14);

/// Keeps content readable on tablets / wide screens.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.bottom});
  final List<Widget> children;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: children,
                ),
              ),
              if (bottom != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: bottom,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two side-by-side buttons (e.g. Cancel / Save).
class ButtonRow extends StatelessWidget {
  const ButtonRow({
    super.key,
    required this.leftLabel,
    required this.onLeft,
    required this.rightLabel,
    required this.onRight,
  });
  final String leftLabel, rightLabel;
  final VoidCallback onLeft, onRight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: FilledButton(onPressed: onLeft, child: Text(leftLabel))),
        const SizedBox(width: 10),
        Expanded(
            child: FilledButton(onPressed: onRight, child: Text(rightLabel))),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 12),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

/// Dropdown whose stored values are translated for display.
/// When [allowAll] is set, a null value means "All".
class OptionDropdown extends StatelessWidget {
  const OptionDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.allowAll = false,
    this.display,
  });
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final bool allowAll;
  final String Function(String)? display;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      key: ValueKey('$label-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        if (allowAll)
          DropdownMenuItem<String?>(value: null, child: Text(context.tr('all'))),
        for (final o in options)
          DropdownMenuItem<String?>(
            value: o,
            child: Text(display?.call(o) ?? context.opt(o)),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

/// Read-only date field with a "Pick" button.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.first,
    this.last,
  });
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;
  final DateTime? first, last;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
      ),
      isEmpty: false,
      child: Row(
        children: [
          Expanded(child: Text(value == null ? '—' : context.date(value))),
          FilledButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.tryParse(value ?? '') ?? now,
                firstDate: first ?? DateTime(1900),
                lastDate: last ?? DateTime(now.year + 5),
              );
              if (picked != null) onChanged(isoDate(picked));
            },
            child: Text(context.tr('pick')),
          ),
        ],
      ),
    );
  }
}

Future<bool> confirm(BuildContext context, String message) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(c, false), child: Text(c.tr('no'))),
        FilledButton(
            onPressed: () => Navigator.pop(c, true), child: Text(c.tr('yes'))),
      ],
    ),
  );
  return result ?? false;
}

void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
