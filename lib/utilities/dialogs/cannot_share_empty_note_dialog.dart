import 'package:flutter/material.dart';
// lib imports
import 'package:notevault/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: "Sharing",
      content: "Note should have both a title and text..",
      optionsBuilder: () => {"OK": null});
}
