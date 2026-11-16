import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n.dart';
import '../store.dart';
import '../widgets.dart';
import 'appointments.dart';
import 'auth.dart';
import 'patients.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _open(BuildContext context, Widget screen) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toIso8601String();
    final admitted =
        store.patients.where((p) => p['status'] == 'Admitted').length;
    final upcoming = store.appointments
        .where((a) =>
            a['status'] == 'scheduled' &&
            (a['dateTime'] as String).compareTo(now) > 0)
        .length;

    Widget button(String key, IconData icon, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FilledButton.icon(
            key: Key(key),
            onPressed: onTap,
            icon: Icon(icon),
            label: Text(context.tr(key)),
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('app.title')),
        actions: const [LangButton()],
      ),
      body: PageBody(
        children: [
          Text(context.tr('dash.title'),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(context.tr('dash.subtitle')),
          const SizedBox(height: 4),
          Text(
            '${context.tr('dash.connected')} ${store.currentUser?['name']} '
            '(${context.tr('role.${store.role}')})',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          gap,
          Row(
            children: [
              _Stat(context.tr('stat.patients'), store.patients.length),
              _Stat(context.tr('stat.admitted'), admitted),
              _Stat(context.tr('stat.upcoming'), upcoming),
            ],
          ),
          gap,
          button('dash.patients', Icons.folder_shared,
              () => _open(context, const PatientListScreen())),
          button('dash.addPatient', Icons.person_add,
              () => _open(context, const PatientFormScreen())),
          button('dash.appointments', Icons.event,
              () => _open(context, const AppointmentsScreen())),
          if (store.canAdminister) ...[
            button('dash.audit', Icons.history,
                () => _open(context, const AuditScreen())),
            button('dash.backup', Icons.backup,
                () => _open(context, const BackupScreen())),
          ],
          button('dash.logout', Icons.logout, () {
            store.logout();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          }),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: Column(
            children: [
              Text('$value', style: Theme.of(context).textTheme.headlineSmall),
              Text(label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// Traceability: who did what and when (administrators only).
class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = store.audit;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('audit.title')),
        actions: const [LangButton()],
      ),
      body: PageBody(
        children: [
          if (entries.isEmpty) Text(context.tr('audit.empty')),
          for (final e in entries)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history),
              title: Text([
                context.tr('act.${e['action']}'),
                if ((e['detail'] ?? '') != '') e['detail'],
              ].join(' : ')),
              subtitle: Text('${context.dateTime(e['time'])} — ${e['user']}'
                  '${e['role'] == '' ? '' : ' (${context.tr('role.${e['role']}')})'}'),
            ),
        ],
      ),
    );
  }
}

/// Data backup: export everything as text, restore it on any device.
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _input = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('backup.title')),
        actions: const [LangButton()],
      ),
      body: PageBody(
        children: [
          Text(context.tr('backup.info')),
          gap,
          FilledButton.icon(
            icon: const Icon(Icons.copy),
            label: Text(context.tr('backup.copy')),
            onPressed: () async {
              await Clipboard.setData(
                  ClipboardData(text: store.exportBackup()));
              if (context.mounted) toast(context, context.tr('backup.copied'));
            },
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _input,
            maxLines: 5,
            decoration: InputDecoration(labelText: context.tr('backup.paste')),
          ),
          gap,
          FilledButton.icon(
            icon: const Icon(Icons.restore),
            label: Text(context.tr('backup.restore')),
            onPressed: () async {
              if (!await confirm(context, context.tr('backup.restoreAsk'))) {
                return;
              }
              final ok = store.restoreBackup(_input.text);
              if (context.mounted) {
                toast(context,
                    context.tr(ok ? 'backup.restored' : 'backup.invalid'));
              }
            },
          ),
        ],
      ),
    );
  }
}
