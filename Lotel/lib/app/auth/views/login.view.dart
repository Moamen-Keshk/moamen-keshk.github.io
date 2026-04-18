import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/app/auth/view_models/auth.vm.dart';
import 'package:lotel_pms/app/global/selected_property.global.dart';
import 'package:lotel_pms/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
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
    return ResponsiveFormCard(
      maxWidth: 520,
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
            Consumer(builder: (_, ref, child) {
              return ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final messenger = ScaffoldMessenger.of(context);
                    final router = ref.read(routerProvider);
                    // 1. Authenticate with Firebase
                    bool success = await ref
                        .read(authVM)
                        .login(email: _email.text, password: _password.text);

                    if (!mounted) return;

                    if (success) {
                      final authState = ref.read(authVM);

                      // 2. Check Firebase Email Verification
                      if (!authState.isEmailVerified) {
                        authState.verifyEmailVerfication();
                        router.push('email_verification');
                        return;
                      }

                      // 3. Sync with Python Backend for Role & Status
                      // We await this explicitly to ensure data is loaded before routing
                      final synced = await authState.syncWithBackend();
                      if (!mounted) return;
                      if (!synced) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              authState.error.isNotEmpty
                                  ? authState.error
                                  : "Failed to load your account status.",
                            ),
                          ),
                        );
                        return;
                      }
                      final initialPropertyId = authState.user?.propertyId;
                      if (initialPropertyId != null && initialPropertyId != 0) {
                        ref
                            .read(selectedPropertyVM.notifier)
                            .updateProperty(initialPropertyId);
                      }

                      if (!mounted) return;

                      // 4. Enforce Role Hierarchy & Status Rules
                      final statusId = authState.user?.accountStatusId;

                      if (statusId == 1) {
                        // 1 = Pending
                        messenger.showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Your account is Pending approval from an Admin.")));
                        // Optionally: ref.read(routerProvider).push('pending_approval_page');
                      } else if (statusId == 3) {
                        // 3 = Suspended
                        messenger.showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Your account is Suspended. Please contact management.")));
                      } else if (statusId == 4) {
                        // 4 = Cancelled
                        messenger.showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Your account has been cancelled. Please contact management.")));
                      } else if (statusId == 2) {
                        // 2 = Active -> Safe to enter the app
                        router.replaceAllWith('dashboard');
                      } else {
                        // Unknown or missing status
                        messenger.showSnackBar(
                            SnackBar(
                                content: Text(
                                    authState.error.isNotEmpty
                                        ? authState.error
                                        : "Unable to determine your account status.")));
                      }
                    } else {
                      // error: Firebase login failed
                      debugPrint(ref.read(authVM).error);
                      messenger.showSnackBar(
                          SnackBar(content: Text(ref.read(authVM).error)));
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
                onTap: () => {ref.read(routerProvider).push('reset_password')},
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
                    onTap: () => {ref.read(routerProvider).push('register')},
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
