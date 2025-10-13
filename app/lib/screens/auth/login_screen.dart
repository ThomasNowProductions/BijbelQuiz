import 'package:flutter/material.dart';
import 'package:bijbelquiz/l10n/strings_nl.dart' as strings;

class LoginScreen extends StatefulWidget {
  final VoidCallback onSwitchToSignup;

  const LoginScreen({super.key, required this.onSwitchToSignup});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.AppStrings.login),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: strings.AppStrings.email),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return strings.AppStrings.pleaseEnterEmail;
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: strings.AppStrings.password),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return strings.AppStrings.pleaseEnterPassword;
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // TODO: Implement login logic
                  }
                },
                child: Text(strings.AppStrings.login),
              ),
              TextButton(
                onPressed: widget.onSwitchToSignup,
                child: Text(strings.AppStrings.noAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
