import 'package:flutter/material.dart';
import 'package:respira_mty/l10n/app_localizations.dart';
import '../models/sima_error.dart';

Future<void> showSimaErrorDialog(BuildContext context, SimaError error) {
  final loc = AppLocalizations.of(context)!;
  final isSimaDown = error.isSimaDown;

  final title = isSimaDown ? loc.simaDownTitle : loc.networkErrorTitle;
  final body = isSimaDown ? loc.simaDownBody : loc.networkErrorBody;
  final icon =
      isSimaDown ? Icons.cloud_off_outlined : Icons.wifi_off_outlined;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(icon, size: 32, color: Colors.orangeAccent),
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(loc.okButton),
        ),
      ],
    ),
  );
}