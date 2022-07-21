import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hehewhoknows/constants/routes.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({Key? key}) : super(key: key);

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
      ),
      body: Column(
        children: [
          const Text("We've sent you an email verification"),
          const Text("If verification email not received, press the button below"),
          TextButton(onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;
            await user!.sendEmailVerification();
          },
            child: const Text("Resend Email Verification"),
          ),
          TextButton(onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
            );
          },
              child: const Text("Restart"),
          )
        ],
      ),
    );
  }
}
