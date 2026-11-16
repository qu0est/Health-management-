import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medicore_hms/main.dart';
import 'package:medicore_hms/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'medicore_lang': 'fr'});
    await initializeDateFormatting();
    await store.load();
  });

  testWidgets('language switch, login and patient search', (tester) async {
    await tester.pumpWidget(const FoukaMedixApp());
    expect(find.text('Se connecter'), findsOneWidget);

    // Switch French -> English.
    await tester.tap(find.byKey(const Key('langButton')));
    await tester.pumpAndSettle();
    expect(find.text('Se connecter'), findsNothing);
    expect(find.text('Create an account'), findsOneWidget);

    // Wrong password is rejected.
    await tester.enterText(
      find.byKey(const Key('email')),
      'admin@foukamedix.app',
    );
    await tester.enterText(find.byKey(const Key('password')), 'wrong');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();
    expect(find.text('Incorrect email or password.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('password')), 'admin123');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();
    expect(find.text('FOUKA Medix Dashboard'), findsOneWidget);

    // Dashboard follows the language too.
    await tester.tap(find.byKey(const Key('langButton')));
    await tester.pumpAndSettle();
    expect(find.text('Liste des patients'), findsOneWidget);

    await tester.tap(find.byKey(const Key('dash.patients')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search')), 'mansouri');
    await tester.pumpAndSettle();
    expect(find.text('1 dossier(s)'), findsOneWidget);
  });

  test('search, roles and audit trail', () {
    expect(store.searchPatients('0002').single['lastName'], 'Bouzid');
    expect(store.searchPatients('14/03/1988').single['firstName'], 'Amina');
    expect(store.searchPatients('', bloodType: 'O+').length, 1);

    expect(store.login('assistant@foukamedix.app', 'assist123'), isTrue);
    expect(store.canWriteReports, isFalse);
    expect(store.canAdminister, isFalse);
    expect(store.audit.first['action'], 'login');

    final backup = store.exportBackup();
    store.deletePatient(store.patients.first);
    expect(store.patients.length, 1);
    expect(store.restoreBackup(backup), isTrue);
    expect(store.patients.length, 2);
    expect(store.restoreBackup('not json'), isFalse);
  });
}
