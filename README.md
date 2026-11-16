# FOUKA Medix

Application mobile simple (Flutter) de gestion des dossiers médicaux, bilingue
**français / anglais**, qui fonctionne **sans connexion internet** : toutes les
données sont enregistrées sur l'appareil.

*A simple bilingual (French / English) Flutter mobile app for managing patient
records. It works fully offline: all data is stored on the device.*

## Fonctionnalités / Features

| | Français | English |
|---|---|---|
| A | Enregistrement des patients (nom, prénom, date de naissance, sexe, adresse, téléphone, n° de dossier, date de première consultation) | Patient registration |
| B | Dossier médical électronique : informations, admission, constantes vitales, historique des consultations, comptes rendus, résultats d'examens, documents | Electronic medical record |
| C | Recherche par nom, prénom, n° de dossier ou date de naissance, avec filtres (groupe sanguin, service, statut) | Record search and filters |
| D | Rendez-vous : ajouter, modifier la date, annuler, consulter la liste | Appointments: add, reschedule, cancel, list |
| E | Archivage numérique des documents (PDF / images) rattachés au dossier | Digital archiving of documents |
| F | Identifiant + mot de passe, niveaux d'accès par fonction, sauvegarde / restauration, journal d'activité (traçabilité) | Login, role-based access, backup / restore, audit log |

Le bouton **Français / English** en haut de chaque écran change la langue
immédiatement ; le choix est mémorisé.

### Niveaux d'accès / Access levels

| Fonction / Role | Droits / Rights |
|---|---|
| Assistant médical / Medical assistant | Patients, rendez-vous, documents |
| Médecin / Doctor | + rédaction des comptes rendus de consultation |
| Administrateur / Administrator | + suppression de dossiers, journal d'activité, sauvegarde |

## Comptes de démonstration / Demo accounts

| E-mail | Mot de passe / Password | Fonction / Role |
|---|---|---|
| `admin@foukamedix.app` | `admin123` | Administrateur |
| `doctor@foukamedix.app` | `doctor123` | Médecin |
| `assistant@foukamedix.app` | `assist123` | Assistant médical |

Deux patients et un rendez-vous d'exemple sont créés au premier lancement.

## Lancer l'application / Run the app

Nécessite Flutter 3.50 ou plus récent (`flutter upgrade`).

```bash
flutter pub get
flutter run                  # téléphone / émulateur Android
flutter run -d chrome        # navigateur
flutter build apk            # APK à installer : build/app/outputs/flutter-apk/
flutter test
```

## Structure

```
lib/
  main.dart               Application et thème
  l10n.dart               Textes français / anglais et bouton de langue
  store.dart              Données locales, authentification, rôles, traçabilité
  widgets.dart            Composants partagés
  screens/
    auth.dart             Connexion, inscription
    dashboard.dart        Tableau de bord, journal d'activité, sauvegarde
    patients.dart         Recherche, formulaire patient, dossier médical
    appointments.dart     Rendez-vous
```

## Limites (version de démonstration) / Demo limitations

- Les documents sont archivés par nom de fichier ; le contenu n'est pas copié
  dans l'application.
- Les données ne sont pas chiffrées sur l'appareil et les mots de passe sont
  simplement hachés (SHA-256) : suffisant pour une démonstration, pas pour de
  vraies données médicales.
