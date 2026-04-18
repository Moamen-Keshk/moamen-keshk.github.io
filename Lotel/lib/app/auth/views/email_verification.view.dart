import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lotel_pms/app/api/widgets/adaptive_layout.widget.dart';
import 'package:lotel_pms/app/auth/view_models/auth.vm.dart';
import 'package:lotel_pms/main.dart';
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
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ResponsiveFormCard(
            maxWidth: 520,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Check your Email',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We have sent you a verification link to ${FirebaseAuth.instance.currentUser?.email}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Consumer(builder: (context, ref, child) {
                      final isEmailVerified = ref.watch(authVM).isEmailVerified;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          isEmailVerified
                              ? const Icon(
                                  IconData(0xf635, fontFamily: 'MaterialIcons'),
                                  size: 40,
                                )
                              : const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          Text(
                            isEmailVerified
                                ? 'Email Successfully Verified'
                                : 'Verifying email....',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              child:
                                  Text(isEmailVerified ? 'Continue' : 'Resend'),
                              onPressed: () {
                                if (isEmailVerified) {
                                  ref.read(routerProvider).push('');
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
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
