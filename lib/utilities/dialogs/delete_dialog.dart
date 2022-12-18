import 'package:flutter/material.dart';
import 'package:hehewhoknows/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context){
  return showGenericDialog<bool>(
    context: context,
    title: "Delete",
    content: "Are you sure you want to delete this item",
    optionsBuilder: () => {
      "No" : false,
      "Yes" : true,
    },
  ).then((value) => value ?? false);
}