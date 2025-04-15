import 'package:flutter/material.dart';
import 'package:flutter_academy/app/auth/view_models/auth.vm.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Text(
              "Login",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: "enter email"),
              validator: validateEmail,
            ),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(labelText: "enter password"),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            Consumer(builder: (context, ref, child) {
              return ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (await ref
                        .read(authVM)
                        .login(email: _email.text, password: _password.text)) {
                      if (ref.read(authVM).isEmailVerified) {
                        routerDelegate.replaceAllWith('dashboard');
                      } else {
                        ref.read(authVM).verifyEmailVerfication();
                        routerDelegate.push('email_verification');
                      }

                      //logged in
                    } else {
                      // error
                      debugPrint(ref.read(authVM).error);
                    }
                  }
                },
                child: const Text("Login"),
              );
            }),
            const SizedBox(height: 10.0),
            Consumer(builder: (context, ref, child) {
              return ElevatedButton(
                onPressed: () async {
                  if (await ref.read(authVM).anonymousLogin()) {
                    //logged in
                  } else {
                    // error
                    debugPrint(ref.read(authVM).error);
                  }
                },
                child: const Text("Anonymous Login"),
              );
            }),
            const SizedBox(height: 20.0),
            Wrap(children: <Widget>[
              InkWell(
                onTap: () => {routerDelegate.push('reset_password')},
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ]),
            Align(
              alignment: Alignment.topRight,
              child: Wrap(
                children: <Widget>[
                  const Text('New User? '),
                  InkWell(
                    onTap: () => {routerDelegate.push('register')},
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  const Text('.'),
                ],
              ),
            ),
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

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid email address'
        : null;
  }
}
