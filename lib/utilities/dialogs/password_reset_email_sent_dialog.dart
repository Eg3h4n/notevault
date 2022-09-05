import 'package:flutter/material.dart';
import 'package:notevault/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
      context: context,
      title: "Password Reset",
      content: "Please check your email for your password reset link",
      optionsBuilder: () => {
            "OK": null,
          });
}
