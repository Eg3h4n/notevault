import 'package:flutter/material.dart';
// lib imports
import 'package:notevault/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog(
    context: context,
    title: "An error occured",
    content: text,
    optionsBuilder: () => {"OK": null},
  );
}
