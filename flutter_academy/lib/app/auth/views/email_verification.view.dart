import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_academy/app/auth/view_models/auth.vm.dart';
import 'package:flutter_academy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({super.key});

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  @override
  void dispose() {
    // TODo: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 35),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'Check your Email',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: Text(
                    'We have sent you a verification link on ${FirebaseAuth.instance.currentUser?.email}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Consumer(builder: (context, ref, child) {
                final isEmailVerified = ref.watch(authVM).isEmailVerified;
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      isEmailVerified
                          ? const Center(
                              child: Icon(IconData(0xf635,
                                  fontFamily: 'MaterialIcons')))
                          : const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: isEmailVerified
                            ? const Center(
                                child: Text(
                                  'Email Successfully Verified',
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : const Center(
                                child: Text(
                                  'Verifying email....',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                      ),
                      const SizedBox(height: 57),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: ElevatedButton(
                          child: isEmailVerified
                              ? const Text('Continue')
                              : const Text('Resend'),
                          onPressed: () {
                            if (isEmailVerified) {
                              routerDelegate.go('/');
                            } else {
                              try {
                                FirebaseAuth.instance.currentUser
                                    ?.sendEmailVerification();
                              } catch (e) {
                                debugPrint('$e');
                              }
                            }
                          },
                        ),
                      )
                    ]);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
