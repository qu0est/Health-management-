import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import 'screens/auth.dart';
import 'store.dart';
import 'widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await store.load();
  runApp(const FoukaMedixApp());
}

class FoukaMedixApp extends StatelessWidget {
  const FoukaMedixApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds with the new locale whenever the language is switched.
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => MaterialApp(
        title: 'FOUKA Medix',
        debugShowCheckedModeBanner: false,
        locale: Locale(store.lang),
        supportedLocales: const [Locale('fr'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: brandBlue,
            primary: brandBlue,
            secondary: brandRed,
            error: brandRed,
          ),
          appBarTheme: const AppBarThemeData(
            backgroundColor: brandBlue,
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
