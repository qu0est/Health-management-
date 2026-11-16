import 'package:material_ui/material_ui.dart';

import '../l10n.dart';
import '../store.dart';
import '../widgets.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('appt.title')),
        actions: const [LangButton()],
      ),
      body: const AppointmentList(),
    );
  }
}

/// Appointment list (all patients, or one patient when [patientId] is set)
/// with add / change date / cancel actions.
class AppointmentList extends StatefulWidget {
  const AppointmentList({super.key, this.patientId, this.onChanged});
  final String? patientId;
  final VoidCallback? onChanged;

  @override
  State<AppointmentList> createState() => _AppointmentListState();
}

class _AppointmentListState extends State<AppointmentList> {
  Future<void> _edit([Json? existing]) async {
    if (store.patients.isEmpty) {
      toast(context, context.tr('appt.noPatients'));
      return;
    }
    final initial =
        DateTime.tryParse(existing?['dateTime'] ?? '') ??
        DateTime.now().add(const Duration(days: 1));
    String? patientId =
        existing?['patientId'] ??
        widget.patientId ??
        store.patients.first['id'];
    var date = isoDate(initial);
    var time = TimeOfDay(
      hour: existing == null ? 9 : initial.hour,
      minute: existing == null ? 0 : initial.minute,
    );
    final reason = TextEditingController(text: existing?['reason'] ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setLocal) => AlertDialog(
          title: Text(c.tr(existing == null ? 'appt.add' : 'appt.edit')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.patientId == null) ...[
                  OptionDropdown(
                    label: c.tr('appt.patient'),
                    value: patientId,
                    options: [for (final p in store.patients) p['id']],
                    display: (id) {
                      final p = store.patientById(id)!;
                      return '${store.patientName(p)} (${p['recordNo']})';
                    },
                    onChanged: (v) => setLocal(() => patientId = v),
                  ),
                  gap,
                ],
                DateField(
                  label: c.tr('appt.date'),
                  value: date,
                  onChanged: (v) => setLocal(() => date = v),
                ),
                gap,
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: c.tr('appt.time'),
                    contentPadding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${time.hour.toString().padLeft(2, '0')}:'
                          '${time.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                      FilledButton(
                        onPressed: () async {
                          final t = await showTimePicker(
                            context: c,
                            initialTime: time,
                          );
                          if (t != null) setLocal(() => time = t);
                        },
                        child: Text(c.tr('pick')),
                      ),
                    ],
                  ),
                ),
                gap,
                TextField(
                  controller: reason,
                  decoration: InputDecoration(labelText: c.tr('appt.reason')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(c.tr('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(c.tr('save')),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final d = DateTime.parse(date);
    store.saveAppointment({
      ...?existing,
      'patientId': patientId,
      'dateTime': DateTime(
        d.year,
        d.month,
        d.day,
        time.hour,
        time.minute,
      ).toIso8601String(),
      'reason': reason.text.trim(),
    });
    _refresh();
  }

  void _refresh() {
    setState(() {});
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final list = store.appointmentsFor(widget.patientId);
    return PageBody(
      bottom: FilledButton.icon(
        key: const Key('addAppointment'),
        icon: const Icon(Icons.add),
        label: Text(context.tr('appt.add')),
        onPressed: _edit,
      ),
      children: [
        if (list.isEmpty) Text(context.tr('appt.empty')),
        for (final a in list) _tile(a),
      ],
    );
  }

  Widget _tile(Json a) {
    final cancelled = a['status'] == 'cancelled';
    final p = store.patientById(a['patientId']);
    final style = cancelled
        ? const TextStyle(decoration: TextDecoration.lineThrough)
        : null;
    return Card(
      child: ListTile(
        leading: Icon(cancelled ? Icons.event_busy : Icons.event_available),
        title: Text(context.dateTime(a['dateTime']), style: style),
        subtitle: Text(
          [
            if (widget.patientId == null && p != null) store.patientName(p),
            if ((a['reason'] ?? '') != '') a['reason'],
            context.tr(cancelled ? 'appt.cancelled' : 'appt.scheduled'),
          ].join(' · '),
        ),
        trailing: cancelled
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: context.tr('appt.edit'),
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: () => _edit(a),
                  ),
                  IconButton(
                    tooltip: context.tr('appt.cancel'),
                    icon: const Icon(Icons.cancel_outlined),
                    onPressed: () async {
                      if (!await confirm(
                        context,
                        context.tr('appt.cancelAsk'),
                      )) {
                        return;
                      }
                      store.cancelAppointment(a);
                      _refresh();
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
