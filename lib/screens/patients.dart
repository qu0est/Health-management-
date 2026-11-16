import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n.dart';
import '../store.dart';
import '../widgets.dart';
import 'appointments.dart';

int? ageOf(String? birthDate) {
  final b = DateTime.tryParse(birthDate ?? '');
  if (b == null) return null;
  final now = DateTime.now();
  var age = now.year - b.year;
  if (now.month < b.month || (now.month == b.month && now.day < b.day)) age--;
  return age;
}

Future<List<String>> pickDocumentNames() async {
  final files = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
  );
  return files.map((f) => f.name).toList();
}

// ---------------------------------------------------------------------------
// Search and consultation of patient records
// ---------------------------------------------------------------------------
class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  String _query = '';
  String? _bloodType, _department, _status;

  @override
  Widget build(BuildContext context) {
    final results = store.searchPatients(_query,
        bloodType: _bloodType, department: _department, status: _status);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('patients.title')),
        actions: const [LangButton()],
      ),
      body: PageBody(
        bottom: ButtonRow(
          leftLabel: context.tr('back'),
          onLeft: () => Navigator.pop(context),
          rightLabel: context.tr('dash.addPatient'),
          onRight: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PatientFormScreen()));
            setState(() {});
          },
        ),
        children: [
          TextField(
            key: const Key('search'),
            decoration: InputDecoration(
              labelText: context.tr('patients.search'),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          gap,
          OptionDropdown(
            label: context.tr('bloodType'),
            value: _bloodType,
            options: bloodTypes,
            allowAll: true,
            onChanged: (v) => setState(() => _bloodType = v),
          ),
          gap,
          OptionDropdown(
            label: context.tr('department'),
            value: _department,
            options: departments,
            allowAll: true,
            onChanged: (v) => setState(() => _department = v),
          ),
          gap,
          OptionDropdown(
            label: context.tr('status'),
            value: _status,
            options: statuses,
            allowAll: true,
            onChanged: (v) => setState(() => _status = v),
          ),
          gap,
          Text('${results.length} ${context.tr('patients.count')}',
              style: Theme.of(context).textTheme.bodySmall),
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(context.tr('patients.empty')),
            ),
          for (final p in results)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                    child: Text((p['lastName'] as String).isEmpty
                        ? '?'
                        : (p['lastName'] as String)[0].toUpperCase())),
                title: Text(store.patientName(p)),
                subtitle: Text([
                  p['recordNo'],
                  context.date(p['birthDate']),
                  if (p['status'] != null) context.opt(p['status']),
                ].where((s) => s != '').join(' · ')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PatientDetailScreen(id: p['id'])));
                  setState(() {});
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Patient registration / edition
// ---------------------------------------------------------------------------
class PatientFormScreen extends StatefulWidget {
  const PatientFormScreen({super.key, this.patient});
  final Json? patient;

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _form = GlobalKey<FormState>();
  late final Json p;
  final _text = <String, TextEditingController>{};

  static const _textFields = [
    'lastName',
    'firstName',
    'phone',
    'address',
    'recordNo',
    'medication',
    'admissionReason',
    'doctor',
    'height',
    'weight',
    'bloodPressure',
    'heartRate',
  ];

  @override
  void initState() {
    super.initState();
    final source = widget.patient;
    p = source == null
        ? {
            'recordNo': store.nextRecordNo(),
            'gender': 'Male',
            'bloodType': 'A+',
            'firstConsultation': isoDate(DateTime.now()),
            'admissionDate': isoDate(DateTime.now()),
            'admissionType': 'Emergency',
            'department': 'General Medicine',
            'status': 'Admitted',
          }
        : Map<String, dynamic>.from(source);
    p['allergies'] = List<String>.from(p['allergies'] ?? []);
    p['chronic'] = List<String>.from(p['chronic'] ?? []);
    p['files'] = List<String>.from(p['files'] ?? []);
    for (final f in _textFields) {
      _text[f] = TextEditingController(text: p[f] ?? '');
    }
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    for (final f in _textFields) {
      p[f] = _text[f]!.text.trim();
    }
    store.savePatient(p);
    toast(context, context.tr('patient.saved'));
    Navigator.pop(context);
  }

  Widget _field(String key,
      {bool required = false, TextInputType? keyboard, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        key: Key('field.$key'),
        controller: _text[key],
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: required
            ? (v) =>
                (v == null || v.trim().isEmpty) ? context.tr('required') : null
            : null,
        decoration: InputDecoration(labelText: context.tr(key)),
      ),
    );
  }

  /// Multi-select chips; "None" is exclusive with the other choices.
  Widget _chips(String key, List<String> options) {
    final selected = p[key] as List<String>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr(key), style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            for (final o in options)
              FilterChip(
                label: Text(context.opt(o)),
                selected: selected.contains(o),
                onSelected: (on) => setState(() {
                  if (!on) {
                    selected.remove(o);
                  } else if (o == 'None') {
                    selected
                      ..clear()
                      ..add(o);
                  } else {
                    selected
                      ..remove('None')
                      ..add(o);
                  }
                }),
              ),
          ],
        ),
        gap,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final age = ageOf(p['birthDate']);
    final files = p['files'] as List<String>;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            context.tr(widget.patient == null ? 'patient.new' : 'patient.edit')),
        actions: const [LangButton()],
      ),
      body: Form(
        key: _form,
        child: PageBody(
          bottom: ButtonRow(
            leftLabel: context.tr('cancel'),
            onLeft: () => Navigator.pop(context),
            rightLabel: context.tr('save'),
            onRight: _save,
          ),
          children: [
            // --- Personal information ---
            SectionTitle(context.tr('sec.personal')),
            _field('lastName', required: true),
            _field('firstName', required: true),
            DateField(
              label: age == null
                  ? context.tr('birthDate')
                  : '${context.tr('birthDate')} ($age ${context.tr('years')})',
              value: p['birthDate'],
              last: DateTime.now(),
              onChanged: (v) => setState(() => p['birthDate'] = v),
            ),
            gap,
            OptionDropdown(
              label: context.tr('gender'),
              value: p['gender'],
              options: genders,
              onChanged: (v) => setState(() => p['gender'] = v),
            ),
            gap,
            _field('phone', keyboard: TextInputType.phone),
            _field('address'),
            _field('recordNo', required: true),
            DateField(
              label: context.tr('firstConsultation'),
              value: p['firstConsultation'],
              onChanged: (v) => setState(() => p['firstConsultation'] = v),
            ),
            gap,

            // --- Medical information ---
            SectionTitle(context.tr('sec.medical')),
            OptionDropdown(
              label: context.tr('bloodType'),
              value: p['bloodType'],
              options: bloodTypes,
              onChanged: (v) => setState(() => p['bloodType'] = v),
            ),
            gap,
            _chips('allergies', allergyOptions),
            _chips('chronic', chronicOptions),
            _field('medication'),

            // --- Admission ---
            SectionTitle(context.tr('sec.admission')),
            _field('admissionReason'),
            DateField(
              label: context.tr('admissionDate'),
              value: p['admissionDate'],
              onChanged: (v) => setState(() => p['admissionDate'] = v),
            ),
            gap,
            OptionDropdown(
              label: context.tr('admissionType'),
              value: p['admissionType'],
              options: admissionTypes,
              onChanged: (v) => setState(() => p['admissionType'] = v),
            ),
            gap,
            OptionDropdown(
              label: context.tr('department'),
              value: p['department'],
              options: departments,
              onChanged: (v) => setState(() => p['department'] = v),
            ),
            gap,
            _field('doctor'),
            OptionDropdown(
              label: context.tr('status'),
              value: p['status'],
              options: statuses,
              onChanged: (v) => setState(() => p['status'] = v),
            ),
            gap,

            // --- Vital signs ---
            SectionTitle(context.tr('sec.vitals')),
            _field('height', keyboard: TextInputType.number),
            _field('weight', keyboard: TextInputType.number),
            _field('bloodPressure'),
            _field('heartRate', keyboard: TextInputType.number),

            // --- Digital archiving ---
            SectionTitle(context.tr('sec.files')),
            for (final f in files)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.insert_drive_file),
                title: Text(f),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => files.remove(f)),
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                icon: const Icon(Icons.upload_file),
                label: Text(context.tr('upload')),
                onPressed: () async {
                  final names = await pickDocumentNames();
                  setState(() => files.addAll(names));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Electronic medical record of one patient
// ---------------------------------------------------------------------------
class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key, required this.id});
  final String id;

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  @override
  void initState() {
    super.initState();
    final p = store.patientById(widget.id);
    if (p != null) store.logPatientView(p);
  }

  Widget _row(String label, String? value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: Text(label,
                  style: Theme.of(context).textTheme.bodySmall),
            ),
            Expanded(
                child: Text((value == null || value.isEmpty) ? '—' : value)),
          ],
        ),
      );

  String _list(dynamic values) =>
      ((values ?? []) as List).map((v) => context.opt(v)).join(', ');

  Future<void> _addConsultation(Json p) async {
    if (!store.canWriteReports) {
      toast(context, context.tr('consult.denied'));
      return;
    }
    final reason = TextEditingController();
    final report = TextEditingController();
    final exams = TextEditingController();
    var date = isoDate(DateTime.now());
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setLocal) => AlertDialog(
          title: Text(c.tr('consult.add')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DateField(
                  label: c.tr('consult.date'),
                  value: date,
                  onChanged: (v) => setLocal(() => date = v),
                ),
                gap,
                TextField(
                  controller: reason,
                  decoration:
                      InputDecoration(labelText: c.tr('consult.reason')),
                ),
                gap,
                TextField(
                  controller: report,
                  maxLines: 3,
                  decoration:
                      InputDecoration(labelText: c.tr('consult.report')),
                ),
                gap,
                TextField(
                  controller: exams,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: c.tr('consult.exams')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: Text(c.tr('cancel'))),
            FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: Text(c.tr('save'))),
          ],
        ),
      ),
    );
    if (ok != true) return;
    store.addConsultation(p, {
      'date': date,
      'reason': reason.text.trim(),
      'report': report.text.trim(),
      'exams': exams.text.trim(),
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = store.patientById(widget.id);
    if (p == null) return const Scaffold();
    final age = ageOf(p['birthDate']);
    final consultations = (p['consultations'] ?? []) as List;
    final files = (p['files'] ?? []) as List;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(store.patientName(p)),
          actions: [
            IconButton(
              tooltip: context.tr('edit'),
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PatientFormScreen(patient: p)));
                setState(() {});
              },
            ),
            if (store.canAdminister)
              IconButton(
                tooltip: context.tr('delete'),
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  if (!await confirm(context, context.tr('patient.deleteAsk'))) {
                    return;
                  }
                  store.deletePatient(p);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            const LangButton(),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: context.tr('tab.info')),
              Tab(text: context.tr('tab.consultations')),
              Tab(text: context.tr('tab.appointments')),
              Tab(text: context.tr('tab.documents')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- Record ---
            PageBody(children: [
              SectionTitle(context.tr('sec.personal')),
              _row(context.tr('recordNo'), p['recordNo']),
              _row(context.tr('lastName'), p['lastName']),
              _row(context.tr('firstName'), p['firstName']),
              _row(
                  context.tr('birthDate'),
                  age == null
                      ? null
                      : '${context.date(p['birthDate'])} '
                          '($age ${context.tr('years')})'),
              _row(context.tr('gender'),
                  p['gender'] == null ? null : context.opt(p['gender'])),
              _row(context.tr('phone'), p['phone']),
              _row(context.tr('address'), p['address']),
              _row(context.tr('firstConsultation'),
                  context.date(p['firstConsultation'])),
              SectionTitle(context.tr('sec.medical')),
              _row(context.tr('bloodType'), p['bloodType']),
              _row(context.tr('allergies'), _list(p['allergies'])),
              _row(context.tr('chronic'), _list(p['chronic'])),
              _row(context.tr('medication'), p['medication']),
              SectionTitle(context.tr('sec.admission')),
              _row(context.tr('admissionReason'), p['admissionReason']),
              _row(context.tr('admissionDate'),
                  context.date(p['admissionDate'])),
              _row(
                  context.tr('admissionType'),
                  p['admissionType'] == null
                      ? null
                      : context.opt(p['admissionType'])),
              _row(context.tr('department'),
                  p['department'] == null ? null : context.opt(p['department'])),
              _row(context.tr('doctor'), p['doctor']),
              _row(context.tr('status'),
                  p['status'] == null ? null : context.opt(p['status'])),
              SectionTitle(context.tr('sec.vitals')),
              _row(context.tr('height'), p['height']),
              _row(context.tr('weight'), p['weight']),
              _row(context.tr('bloodPressure'), p['bloodPressure']),
              _row(context.tr('heartRate'), p['heartRate']),
            ]),

            // --- Consultation history ---
            PageBody(
              bottom: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: Text(context.tr('consult.add')),
                onPressed: () => _addConsultation(p),
              ),
              children: [
                if (consultations.isEmpty) Text(context.tr('consult.empty')),
                for (final c in consultations)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${context.date(c['date'])} — ${c['reason'] ?? ''}',
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8),
                          _row(context.tr('consult.report'), c['report']),
                          _row(context.tr('consult.exams'), c['exams']),
                          _row(context.tr('consult.by'), c['author']),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // --- Appointments ---
            AppointmentList(
                patientId: widget.id, onChanged: () => setState(() {})),

            // --- Documents ---
            PageBody(
              bottom: FilledButton.icon(
                icon: const Icon(Icons.upload_file),
                label: Text(context.tr('upload')),
                onPressed: () async {
                  final names = await pickDocumentNames();
                  if (names.isEmpty) return;
                  store.addFiles(p, names);
                  setState(() {});
                },
              ),
              children: [
                if (files.isEmpty) Text(context.tr('noFiles')),
                for (final f in files)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(f.toString().toLowerCase().endsWith('.pdf')
                        ? Icons.picture_as_pdf
                        : Icons.image),
                    title: Text('$f'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
