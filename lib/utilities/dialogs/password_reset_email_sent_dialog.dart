import 'package:flutter/material.dart';
import 'package:hehewhoknows/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context){
  return showGenericDialog(
      context: context,
      title: "Password Reset",
      content: "We have sent you a password reset link through email. Please check your email inbox.",
      optionsBuilder: () => {
        "OK": null,
      },
  );
}