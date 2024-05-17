import 'dart:async';

import 'package:flutter/material.dart';

Future<dynamic> errorDialog(context, String errorMessage){
  return showDialog(
      context: context,
      barrierDismissible: false, // disables popup to close if tapped outside popup (need a button to close)
      builder: (BuildContext context) {
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
          //buttons?
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
  );
}