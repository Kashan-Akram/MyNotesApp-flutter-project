import 'package:flutter/material.dart';
import 'package:hehewhoknows/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hehewhoknows/services/auth/bloc/auth_event.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("We've sent you an email verification!"),
            const Text("If verification email not received, press the button below"),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          const AuthEventSendEmailVerification(),
                        );
                        //await AuthService.firebase().sendEmailVerification();
                    },
                      child: const Text("Send Email Verification"),
                    ),
                    TextButton(
                      onPressed: () async {
                        context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                        /*
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        registerRoute,
                        (route) => false,
                    );
                    */
                      },
                      child: const Text("Restart"),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
