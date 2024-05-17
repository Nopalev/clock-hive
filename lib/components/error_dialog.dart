import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String errorMessage;
  const ErrorDialog({
    super.key,
    required this.errorMessage
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'An Error Has Occurred',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 36
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        errorMessage,
        style: const TextStyle(
            fontSize: 24
        ),
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(
              Icons.close
          ),
          onPressed: () { Navigator.of(context).pop(); },
          color: Colors.purple,//closes popup
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}