import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'store.dart';

/// All user-visible strings: key -> [English, French].
const Map<String, List<String>> _strings = {
  // General
  'app.title': ['MediCore HMS', 'MediCore HMS'],
  'cancel': ['Cancel', 'Annuler'],
  'save': ['Save', 'Enregistrer'],
  'back': ['Back', 'Retour'],
  'pick': ['Pick', 'Choisir'],
  'all': ['All', 'Tous'],
  'yes': ['Yes', 'Oui'],
  'no': ['No', 'Non'],
  'edit': ['Edit', 'Modifier'],
  'delete': ['Delete', 'Supprimer'],
  'add': ['Add', 'Ajouter'],
  'close': ['Close', 'Fermer'],
  'required': ['Required field', 'Champ obligatoire'],
  'language': ['Language', 'Langue'],
  'offline': [
    'Works offline — data is stored on this device.',
    'Fonctionne hors connexion — les données sont stockées sur cet appareil.',
  ],

  // Auth
  'login.title': ['Login', 'Connexion'],
  'login.button': ['Login', 'Se connecter'],
  'login.register': ['Create an account', 'Créer un compte'],
  'login.error': [
    'Incorrect email or password.',
    'E-mail ou mot de passe incorrect.',
  ],
  'login.demo': [
    'Demo account: admin@medicore.app / admin123',
    'Compte de démonstration : admin@medicore.app / admin123',
  ],
  'register.title': ['Register User', 'Inscription'],
  'register.button': ['Register', "S'inscrire"],
  'register.back': ['Back to Login', 'Retour à la connexion'],
  'register.exists': [
    'An account already exists with this email.',
    'Un compte existe déjà avec cet e-mail.',
  ],
  'register.mismatch': [
    'Passwords do not match.',
    'Les mots de passe ne correspondent pas.',
  ],
  'register.short': [
    'At least 6 characters.',
    'Au moins 6 caractères.',
  ],
  'register.done': [
    'Account created. You can now log in.',
    'Compte créé. Vous pouvez vous connecter.',
  ],
  'fullName': ['Full name', 'Nom complet'],
  'email': ['Email', 'E-mail'],
  'password': ['Password', 'Mot de passe'],
  'confirmPassword': ['Confirm password', 'Confirmer le mot de passe'],
  'role': ['Role', 'Fonction'],
  'role.admin': ['Administrator', 'Administrateur'],
  'role.doctor': ['Doctor', 'Médecin'],
  'role.assistant': ['Medical assistant', 'Assistant médical'],

  // Dashboard
  'dash.title': ['MediCore HMS Dashboard', 'Tableau de bord MediCore HMS'],
  'dash.subtitle': [
    'Manage patients, admissions, and medical records.',
    'Gérez les patients, les admissions et les dossiers médicaux.',
  ],
  'dash.connected': ['Signed in as', 'Connecté en tant que'],
  'dash.patients': ['Patient List', 'Liste des patients'],
  'dash.addPatient': ['Add Patient', 'Ajouter un patient'],
  'dash.appointments': ['Appointments', 'Rendez-vous'],
  'dash.audit': ['Activity Log', "Journal d'activité"],
  'dash.backup': ['Backup & Restore', 'Sauvegarde et restauration'],
  'dash.logout': ['Logout', 'Déconnexion'],
  'stat.patients': ['Patients', 'Patients'],
  'stat.admitted': ['Admitted', 'Hospitalisés'],
  'stat.upcoming': ['Upcoming appts', 'RDV à venir'],

  // Patient list
  'patients.title': ['Patient Records', 'Dossiers des patients'],
  'patients.search': [
    'Search: name, record no., birth date',
    'Recherche : nom, prénom, n° dossier, date de naissance',
  ],
  'patients.empty': ['No patient found.', 'Aucun patient trouvé.'],
  'patients.count': ['record(s)', 'dossier(s)'],

  // Patient form
  'patient.new': ['Add Patient', 'Ajouter un patient'],
  'patient.edit': ['Edit Patient', 'Modifier le patient'],
  'sec.personal': ['Personal Information', 'Informations personnelles'],
  'sec.medical': ['Medical Information', 'Informations médicales'],
  'sec.admission': ['Admission', 'Admission'],
  'sec.vitals': ['Vital Signs', 'Constantes vitales'],
  'sec.files': ['File Upload', 'Documents médicaux'],
  'lastName': ['Last name', 'Nom'],
  'firstName': ['First name', 'Prénom'],
  'birthDate': ['Date of birth', 'Date de naissance'],
  'age': ['Age', 'Âge'],
  'years': ['years', 'ans'],
  'gender': ['Gender', 'Sexe'],
  'phone': ['Phone', 'Téléphone'],
  'address': ['Address', 'Adresse'],
  'recordNo': ['Medical record no.', 'N° de dossier médical'],
  'firstConsultation': [
    'First consultation date',
    'Date de première consultation',
  ],
  'bloodType': ['Blood Type', 'Groupe sanguin'],
  'allergies': ['Allergies', 'Allergies'],
  'chronic': ['Chronic Diseases', 'Maladies chroniques'],
  'medication': ['Current Medication', 'Traitement en cours'],
  'admissionReason': ['Admission Reason', "Motif d'admission"],
  'admissionDate': ['Admission Date', "Date d'admission"],
  'admissionType': ['Admission Type', "Type d'admission"],
  'department': ['Department', 'Service'],
  'doctor': ['Assigned Doctor', 'Médecin traitant'],
  'status': ['Status', 'Statut'],
  'height': ['Height (cm)', 'Taille (cm)'],
  'weight': ['Weight (kg)', 'Poids (kg)'],
  'bloodPressure': ['Blood Pressure', 'Tension artérielle'],
  'heartRate': ['Heart Rate (bpm)', 'Fréquence cardiaque (bpm)'],
  'upload': ['Upload Files (PDF / Images)', 'Ajouter des fichiers (PDF / Images)'],
  'noFiles': ['No document.', 'Aucun document.'],
  'patient.saved': ['Patient record saved.', 'Dossier patient enregistré.'],

  // Patient detail
  'tab.info': ['Record', 'Dossier'],
  'tab.consultations': ['Consultations', 'Consultations'],
  'tab.appointments': ['Appointments', 'Rendez-vous'],
  'tab.documents': ['Documents', 'Documents'],
  'patient.deleteAsk': [
    'Delete this patient record permanently?',
    'Supprimer définitivement ce dossier patient ?',
  ],
  'consult.add': ['Add consultation', 'Ajouter une consultation'],
  'consult.empty': ['No consultation yet.', 'Aucune consultation.'],
  'consult.date': ['Consultation date', 'Date de consultation'],
  'consult.reason': ['Reason', 'Motif'],
  'consult.report': ['Medical report', 'Compte rendu médical'],
  'consult.exams': ['Examination results', 'Résultats des examens'],
  'consult.by': ['By', 'Par'],
  'consult.denied': [
    'Only doctors can write medical reports.',
    'Seuls les médecins peuvent rédiger des comptes rendus.',
  ],
  'denied': ['Access denied for your role.', 'Accès refusé pour votre fonction.'],

  // Appointments
  'appt.title': ['Appointments', 'Rendez-vous'],
  'appt.add': ['Add appointment', 'Ajouter un rendez-vous'],
  'appt.edit': ['Edit appointment', 'Modifier le rendez-vous'],
  'appt.empty': ['No appointment.', 'Aucun rendez-vous.'],
  'appt.patient': ['Patient', 'Patient'],
  'appt.date': ['Date', 'Date'],
  'appt.time': ['Time', 'Heure'],
  'appt.reason': ['Reason', 'Motif'],
  'appt.cancel': ['Cancel appointment', 'Annuler le rendez-vous'],
  'appt.cancelAsk': ['Cancel this appointment?', 'Annuler ce rendez-vous ?'],
  'appt.cancelled': ['Cancelled', 'Annulé'],
  'appt.scheduled': ['Scheduled', 'Planifié'],
  'appt.noPatients': [
    'Register a patient first.',
    "Enregistrez d'abord un patient.",
  ],

  // Audit
  'audit.title': ['Activity Log', "Journal d'activité"],
  'audit.empty': ['No activity recorded.', 'Aucune activité enregistrée.'],
  'act.login': ['Login', 'Connexion'],
  'act.logout': ['Logout', 'Déconnexion'],
  'act.register': ['Account created', 'Compte créé'],
  'act.patient.view': ['Record viewed', 'Dossier consulté'],
  'act.patient.create': ['Patient registered', 'Patient enregistré'],
  'act.patient.update': ['Record modified', 'Dossier modifié'],
  'act.patient.delete': ['Record deleted', 'Dossier supprimé'],
  'act.consult.add': ['Consultation added', 'Consultation ajoutée'],
  'act.appt.add': ['Appointment added', 'Rendez-vous ajouté'],
  'act.appt.update': ['Appointment modified', 'Rendez-vous modifié'],
  'act.appt.cancel': ['Appointment cancelled', 'Rendez-vous annulé'],
  'act.backup.export': ['Backup exported', 'Sauvegarde exportée'],
  'act.backup.restore': ['Backup restored', 'Sauvegarde restaurée'],

  // Backup
  'backup.title': ['Backup & Restore', 'Sauvegarde et restauration'],
  'backup.info': [
    'Copy the backup text and keep it in a safe place. Paste it below to restore the data on any device.',
    'Copiez le texte de sauvegarde et conservez-le en lieu sûr. Collez-le ci-dessous pour restaurer les données sur un appareil.',
  ],
  'backup.copy': ['Copy backup', 'Copier la sauvegarde'],
  'backup.copied': ['Backup copied to clipboard.', 'Sauvegarde copiée dans le presse-papiers.'],
  'backup.paste': ['Paste a backup here', 'Collez une sauvegarde ici'],
  'backup.restore': ['Restore', 'Restaurer'],
  'backup.restoreAsk': [
    'Replace all current data with this backup?',
    'Remplacer toutes les données actuelles par cette sauvegarde ?',
  ],
  'backup.restored': ['Data restored.', 'Données restaurées.'],
  'backup.invalid': ['Invalid backup.', 'Sauvegarde invalide.'],

  // Option values (stored in English, displayed translated)
  'opt.Male': ['Male', 'Masculin'],
  'opt.Female': ['Female', 'Féminin'],
  'opt.Penicillin': ['Penicillin', 'Pénicilline'],
  'opt.Dust': ['Dust', 'Poussière'],
  'opt.Pollen': ['Pollen', 'Pollen'],
  'opt.Seafood': ['Seafood', 'Fruits de mer'],
  'opt.Peanuts': ['Peanuts', 'Arachides'],
  'opt.None': ['None', 'Aucune'],
  'opt.Diabetes': ['Diabetes', 'Diabète'],
  'opt.Hypertension': ['Hypertension', 'Hypertension'],
  'opt.Asthma': ['Asthma', 'Asthme'],
  'opt.Thyroid': ['Thyroid', 'Thyroïde'],
  'opt.Heart Disease': ['Heart Disease', 'Maladie cardiaque'],
  'opt.Emergency': ['Emergency', 'Urgence'],
  'opt.Scheduled': ['Scheduled', 'Programmée'],
  'opt.Outpatient': ['Outpatient', 'Consultation externe'],
  'opt.Transfer': ['Transfer', 'Transfert'],
  'opt.General Medicine': ['General Medicine', 'Médecine générale'],
  'opt.Cardiology': ['Cardiology', 'Cardiologie'],
  'opt.Pediatrics': ['Pediatrics', 'Pédiatrie'],
  'opt.Surgery': ['Surgery', 'Chirurgie'],
  'opt.Gynecology': ['Gynecology', 'Gynécologie'],
  'opt.Emergency Dept': ['Emergency Dept', 'Urgences'],
  'opt.Admitted': ['Admitted', 'Hospitalisé'],
  'opt.Under Observation': ['Under Observation', 'En observation'],
  'opt.Discharged': ['Discharged', 'Sorti'],
};

const genders = ['Male', 'Female'];
const bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
const allergyOptions = ['Penicillin', 'Dust', 'Pollen', 'Seafood', 'Peanuts', 'None'];
const chronicOptions = [
  'Diabetes',
  'Hypertension',
  'Asthma',
  'Thyroid',
  'Heart Disease',
  'None',
];
const admissionTypes = ['Emergency', 'Scheduled', 'Outpatient', 'Transfer'];
const departments = [
  'General Medicine',
  'Cardiology',
  'Pediatrics',
  'Surgery',
  'Gynecology',
  'Emergency Dept',
];
const statuses = ['Admitted', 'Under Observation', 'Discharged'];
const roles = ['assistant', 'doctor', 'admin'];

extension Tr on BuildContext {
  String get lang => Localizations.localeOf(this).languageCode;

  /// Translates [key] into the current app language.
  String tr(String key) {
    final entry = _strings[key];
    if (entry == null) return key;
    return lang == 'fr' ? entry[1] : entry[0];
  }

  /// Translates a stored option value (falls back to the raw value).
  String opt(String value) {
    final entry = _strings['opt.$value'];
    if (entry == null) return value;
    return lang == 'fr' ? entry[1] : entry[0];
  }

  /// Formats an ISO date (yyyy-MM-dd) for display.
  String date(String? iso) {
    final d = DateTime.tryParse(iso ?? '');
    return d == null ? '' : DateFormat.yMMMd(lang).format(d);
  }

  String dateTime(String? iso) {
    final d = DateTime.tryParse(iso ?? '');
    return d == null ? '' : DateFormat.yMMMd(lang).add_Hm().format(d);
  }
}

/// FR/EN switch shown in every app bar.
class LangButton extends StatelessWidget {
  const LangButton({super.key});

  @override
  Widget build(BuildContext context) {
    final fr = context.lang == 'fr';
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton.icon(
        key: const Key('langButton'),
        onPressed: () => store.setLang(fr ? 'en' : 'fr'),
        icon: const Icon(Icons.language),
        label: Text(fr ? 'English' : 'Français'),
      ),
    );
  }
}
