import 'package:flutter/material.dart';

InputDecoration dimensionInput(BuildContext context,
    {required String label, Widget? suffix}) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    suffixIcon: suffix,
  );
}
