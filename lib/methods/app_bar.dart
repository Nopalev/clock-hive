import 'package:flutter/material.dart';

PreferredSizeWidget appBar(String title){
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
          fontWeight: FontWeight.bold
      ),
    ),
    centerTitle: true,
  );
}