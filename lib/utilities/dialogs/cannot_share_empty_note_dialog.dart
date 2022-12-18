import 'package:flutter/material.dart';
import 'package:hehewhoknows/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) async {
  return showGenericDialog(
      context: context,
      title: "Sharing",
      content: "You cannot share an empty note!",
      optionsBuilder: () => {"OK": null},
  );
}