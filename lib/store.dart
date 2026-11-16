import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Json = Map<String, dynamic>;

final store = AppStore();

String isoDate(DateTime d) => d.toIso8601String().substring(0, 10);

/// Local, offline data store. Everything is saved on the device as JSON,
/// so the app works without any network connection.
class AppStore extends ChangeNotifier {
  static const _dbKey = 'medicore_db';
  static const _langKey = 'medicore_lang';

  SharedPreferences? _prefs;
  String lang = 'fr';
  Json? currentUser;

  List<Json> users = [];
  List<Json> patients = [];
  List<Json> appointments = [];
  List<Json> audit = [];
  int _counter = 0;

  // ---- Roles / access levels ----
  String get role => currentUser?['role'] ?? '';
  bool get isAdmin => role == 'admin';

  /// Only doctors (and admins) write medical reports.
  bool get canWriteReports => role == 'doctor' || role == 'admin';

  /// Only admins delete records, read the audit log and manage backups.
  bool get canAdminister => role == 'admin';

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs!.getString(_langKey);
    if (saved != null) {
      lang = saved;
    } else {
      final device = PlatformDispatcher.instance.locale.languageCode;
      lang = device == 'en' ? 'en' : 'fr';
    }
    final raw = _prefs!.getString(_dbKey);
    if (raw == null) {
      _seed();
      await _save();
    } else {
      _fromJson(jsonDecode(raw) as Json);
      _renameOldDemoAccounts();
    }
  }

  /// Earlier versions created the demo accounts under @medicore.app.
  void _renameOldDemoAccounts() {
    const demo = {
      'admin': 'admin123',
      'doctor': 'doctor123',
      'assistant': 'assist123',
    };
    var changed = false;
    for (final u in users) {
      final old = u['email'] as String;
      final name = old.split('@').first;
      if (old.endsWith('@medicore.app') &&
          demo.containsKey(name) &&
          u['hash'] == _hash(old, demo[name]!)) {
        u['email'] = '$name@foukamedix.app';
        u['hash'] = _hash(u['email'], demo[name]!);
        changed = true;
      }
    }
    if (changed) _prefs?.setString(_dbKey, jsonEncode(_toJson()));
  }

  void setLang(String value) {
    lang = value;
    _prefs?.setString(_langKey, value);
    notifyListeners();
  }

  // ---- Persistence ----
  Json _toJson() => {
    'users': users,
    'patients': patients,
    'appointments': appointments,
    'audit': audit,
    'counter': _counter,
  };

  void _fromJson(Json db) {
    List<Json> list(String k) => ((db[k] ?? []) as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    users = list('users');
    patients = list('patients');
    appointments = list('appointments');
    audit = list('audit');
    _counter = db['counter'] ?? patients.length;
  }

  Future<void> _save() async {
    await _prefs?.setString(_dbKey, jsonEncode(_toJson()));
    notifyListeners();
  }

  String _hash(String email, String password) => sha256
      .convert(utf8.encode('${email.toLowerCase()}:$password'))
      .toString();

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  // ---- Traceability ----
  void _log(String action, [String detail = '']) {
    audit.insert(0, {
      'time': DateTime.now().toIso8601String(),
      'user': currentUser?['name'] ?? '',
      'role': role,
      'action': action,
      'detail': detail,
    });
    if (audit.length > 500) audit.removeRange(500, audit.length);
  }

  // ---- Authentication ----
  bool login(String email, String password) {
    final mail = email.trim().toLowerCase();
    final match = users.where(
      (u) => u['email'] == mail && u['hash'] == _hash(mail, password),
    );
    if (match.isEmpty) return false;
    currentUser = match.first;
    _log('login');
    _save();
    return true;
  }

  void logout() {
    _log('logout');
    currentUser = null;
    _save();
  }

  /// Returns false when the email is already used.
  bool register(String name, String email, String password, String role) {
    final mail = email.trim().toLowerCase();
    if (users.any((u) => u['email'] == mail)) return false;
    users.add({
      'name': name.trim(),
      'email': mail,
      'hash': _hash(mail, password),
      'role': role,
    });
    _log('register', '${name.trim()} ($mail)');
    _save();
    return true;
  }

  // ---- Patients ----
  String patientName(Json p) => '${p['lastName']} ${p['firstName']}'.trim();

  Json? patientById(String id) {
    for (final p in patients) {
      if (p['id'] == id) return p;
    }
    return null;
  }

  String nextRecordNo() =>
      'DM-${DateTime.now().year}-${(_counter + 1).toString().padLeft(4, '0')}';

  void savePatient(Json p) {
    if (p['id'] == null) {
      _counter++;
      p['id'] = _newId();
      p['consultations'] ??= <dynamic>[];
      patients.insert(0, p);
      _log('patient.create', '${patientName(p)} — ${p['recordNo']}');
    } else {
      final i = patients.indexWhere((e) => e['id'] == p['id']);
      if (i >= 0) patients[i] = p;
      _log('patient.update', '${patientName(p)} — ${p['recordNo']}');
    }
    _save();
  }

  void deletePatient(Json p) {
    patients.removeWhere((e) => e['id'] == p['id']);
    appointments.removeWhere((a) => a['patientId'] == p['id']);
    _log('patient.delete', '${patientName(p)} — ${p['recordNo']}');
    _save();
  }

  void logPatientView(Json p) {
    _log('patient.view', '${patientName(p)} — ${p['recordNo']}');
    _prefs?.setString(_dbKey, jsonEncode(_toJson()));
  }

  void addConsultation(Json p, Json consultation) {
    consultation['author'] = currentUser?['name'] ?? '';
    (p['consultations'] as List).insert(0, consultation);
    _log('consult.add', '${patientName(p)} — ${p['recordNo']}');
    _save();
  }

  void addFiles(Json p, List<String> names) {
    p['files'] = [...(p['files'] ?? []), ...names];
    _log('patient.update', '${patientName(p)} — ${p['recordNo']}');
    _save();
  }

  /// Search by last name, first name, record number or birth date,
  /// combined with optional filters.
  List<Json> searchPatients(
    String query, {
    String? bloodType,
    String? department,
    String? status,
  }) {
    final tokens = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty);
    return patients.where((p) {
      if (bloodType != null && p['bloodType'] != bloodType) return false;
      if (department != null && p['department'] != department) return false;
      if (status != null && p['status'] != status) return false;
      final b = (p['birthDate'] ?? '') as String;
      final frDate = b.length == 10
          ? '${b.substring(8)}/${b.substring(5, 7)}/${b.substring(0, 4)}'
          : '';
      final text =
          '${p['lastName']} ${p['firstName']} ${p['recordNo']} $b $frDate'
              .toLowerCase();
      return tokens.every(text.contains);
    }).toList();
  }

  // ---- Appointments ----
  List<Json> appointmentsFor([String? patientId]) {
    final list = appointments
        .where((a) => patientId == null || a['patientId'] == patientId)
        .toList();
    list.sort((a, b) => (a['dateTime'] as String).compareTo(b['dateTime']));
    return list;
  }

  String _apptDetail(Json a) {
    final p = patientById(a['patientId']);
    final when = (a['dateTime'] as String)
        .substring(0, 16)
        .replaceFirst('T', ' ');
    return '${p == null ? '' : patientName(p)} — $when';
  }

  void saveAppointment(Json a) {
    if (a['id'] == null) {
      a['id'] = _newId();
      a['status'] = 'scheduled';
      appointments.add(a);
      _log('appt.add', _apptDetail(a));
    } else {
      final i = appointments.indexWhere((e) => e['id'] == a['id']);
      if (i >= 0) appointments[i] = a;
      _log('appt.update', _apptDetail(a));
    }
    _save();
  }

  void cancelAppointment(Json a) {
    a['status'] = 'cancelled';
    _log('appt.cancel', _apptDetail(a));
    _save();
  }

  // ---- Backup ----
  String exportBackup() {
    _log('backup.export');
    _save();
    return jsonEncode(_toJson());
  }

  bool restoreBackup(String text) {
    try {
      final db = jsonDecode(text) as Json;
      if (db['users'] is! List || db['patients'] is! List) return false;
      _fromJson(db);
      _log('backup.restore');
      _save();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---- Demo data ----
  void _seed() {
    Json user(String name, String mail, String pw, String role) => {
      'name': name,
      'email': mail,
      'hash': _hash(mail, pw),
      'role': role,
    };
    users = [
      user('Admin', 'admin@foukamedix.app', 'admin123', 'admin'),
      user('Dr. Karim Benali', 'doctor@foukamedix.app', 'doctor123', 'doctor'),
      user('Sara Haddad', 'assistant@foukamedix.app', 'assist123', 'assistant'),
    ];
    final now = DateTime.now();
    final year = now.year;
    patients = [
      {
        'id': 'p1',
        'recordNo': 'DM-$year-0001',
        'lastName': 'Mansouri',
        'firstName': 'Amina',
        'birthDate': '1988-03-14',
        'gender': 'Female',
        'phone': '0550 12 34 56',
        'address': '12 rue des Oliviers, Alger',
        'firstConsultation': isoDate(now.subtract(const Duration(days: 40))),
        'bloodType': 'A+',
        'allergies': ['Penicillin'],
        'chronic': ['Asthma'],
        'medication': 'Salbutamol',
        'admissionReason': 'Crise d\'asthme',
        'admissionDate': isoDate(now.subtract(const Duration(days: 2))),
        'admissionType': 'Emergency',
        'department': 'General Medicine',
        'doctor': 'Dr. Karim Benali',
        'status': 'Admitted',
        'height': '165',
        'weight': '62',
        'bloodPressure': '120/80',
        'heartRate': '78',
        'files': ['radio_thorax.pdf'],
        'consultations': [
          {
            'date': isoDate(now.subtract(const Duration(days: 2))),
            'reason': 'Difficulté respiratoire',
            'report':
                'Crise d\'asthme modérée. Traitement par bronchodilatateur.',
            'exams': 'Saturation O2 : 94 %. Radio thorax normale.',
            'author': 'Dr. Karim Benali',
          },
        ],
      },
      {
        'id': 'p2',
        'recordNo': 'DM-$year-0002',
        'lastName': 'Bouzid',
        'firstName': 'Yacine',
        'birthDate': '1962-11-02',
        'gender': 'Male',
        'phone': '0661 98 76 54',
        'address': '5 cité El Nasr, Oran',
        'firstConsultation': isoDate(now.subtract(const Duration(days: 120))),
        'bloodType': 'O+',
        'allergies': ['None'],
        'chronic': ['Diabetes', 'Hypertension'],
        'medication': 'Metformine, Amlodipine',
        'admissionReason': 'Suivi cardiologique',
        'admissionDate': isoDate(now.subtract(const Duration(days: 10))),
        'admissionType': 'Scheduled',
        'department': 'Cardiology',
        'doctor': 'Dr. Karim Benali',
        'status': 'Discharged',
        'height': '174',
        'weight': '85',
        'bloodPressure': '145/90',
        'heartRate': '84',
        'files': <String>[],
        'consultations': <dynamic>[],
      },
    ];
    _counter = 2;
    final rdv = DateTime(
      now.year,
      now.month,
      now.day,
      10,
      30,
    ).add(const Duration(days: 3));
    appointments = [
      {
        'id': 'a1',
        'patientId': 'p2',
        'dateTime': rdv.toIso8601String(),
        'reason': 'Contrôle tension',
        'status': 'scheduled',
      },
    ];
    audit = [];
  }
}
