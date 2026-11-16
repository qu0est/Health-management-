import 'package:material_ui/material_ui.dart';

import '../l10n.dart';
import '../store.dart';
import '../widgets.dart';
import 'dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;

  void _login() {
    if (store.login(_email.text, _password.text)) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } else {
      setState(() => _error = 'login.error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('login.title')),
        actions: const [LangButton()],
      ),
      body: PageBody(
        children: [
          Icon(Icons.local_hospital,
              size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text('MediCore HMS',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          TextField(
            key: const Key('email'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: context.tr('email')),
          ),
          gap,
          TextField(
            key: const Key('password'),
            controller: _password,
            obscureText: true,
            onSubmitted: (_) => _login(),
            decoration: InputDecoration(labelText: context.tr('password')),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(context.tr(_error!),
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          gap,
          FilledButton(
            key: const Key('loginButton'),
            onPressed: _login,
            child: Text(context.tr('login.button')),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RegisterScreen())),
            child: Text(context.tr('login.register')),
          ),
          const SizedBox(height: 24),
          Text(context.tr('login.demo'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(context.tr('offline'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _role = 'assistant';

  void _register() {
    if (!_form.currentState!.validate()) return;
    if (!store.register(_name.text, _email.text, _password.text, _role)) {
      toast(context, context.tr('register.exists'));
      return;
    }
    toast(context, context.tr('register.done'));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? context.tr('required') : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('register.title')),
        actions: const [LangButton()],
      ),
      body: Form(
        key: _form,
        child: PageBody(
          children: [
            TextFormField(
              controller: _name,
              validator: required,
              decoration: InputDecoration(labelText: context.tr('fullName')),
            ),
            gap,
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: required,
              decoration: InputDecoration(labelText: context.tr('email')),
            ),
            gap,
            OptionDropdown(
              label: context.tr('role'),
              value: _role,
              options: roles,
              display: (r) => context.tr('role.$r'),
              onChanged: (v) => setState(() => _role = v!),
            ),
            gap,
            TextFormField(
              controller: _password,
              obscureText: true,
              validator: (v) => (v == null || v.length < 6)
                  ? context.tr('register.short')
                  : null,
              decoration: InputDecoration(labelText: context.tr('password')),
            ),
            gap,
            TextFormField(
              controller: _confirm,
              obscureText: true,
              validator: (v) => v != _password.text
                  ? context.tr('register.mismatch')
                  : null,
              decoration:
                  InputDecoration(labelText: context.tr('confirmPassword')),
            ),
            gap,
            FilledButton(
                onPressed: _register,
                child: Text(context.tr('register.button'))),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('register.back')),
            ),
          ],
        ),
      ),
    );
  }
}
