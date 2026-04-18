import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/app/auth/view_models/auth.vm.dart';
import 'package:lotel_pms/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  // ---> NEW: Controller for the Invite Code <---
  final TextEditingController _inviteCode = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _inviteCode.dispose(); // Dispose the new controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveFormCard(
      maxWidth: 520,
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Text(
              "Register",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: "enter name"),
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Can\'t be empty';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: "enter email"),
              validator: validateEmail,
            ),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(labelText: "enter password"),
              obscureText: true,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Can\'t be empty';
                }
                if (text.length < 6) {
                  return 'Too short, minimum 6 characters';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _confirmPassword,
              decoration: const InputDecoration(labelText: "confirm password"),
              obscureText: true,
              validator: (text) {
                if (text != _password.text) {
                  return 'Not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 10.0),
            TextFormField(
              controller: _inviteCode,
              decoration: const InputDecoration(
                labelText: "Invite Code (Optional)",
                helperText: "Enter the code emailed to you by your manager.",
              ),
            ),
            const SizedBox(height: 20.0),
            Consumer(builder: (_, ref, child) {
              return ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final authState = ref.read(authVM);

                    bool success = await authState.register(
                      name: _name.text.trim(),
                      email: _email.text.trim(),
                      password: _password.text,
                      inviteCode: _inviteCode.text.trim(),
                    );

                    if (!mounted) return;

                    if (success) {
                      ref.read(routerProvider).push('email_verification');
                    } else {
                      debugPrint(authState.error);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text(authState.error),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text("Register"),
              );
            }),
          ],
        ),
      ),
    );
  }

  String? validateEmail(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value != null && value.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid email address'
        : null;
  }
}
