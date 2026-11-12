import 'package:flutter/material.dart';

/// Converts a hex string like `#31D492` into a [Color].
Color hexColor(String hex) {
  var value = hex.replaceAll('#', '').trim();
  if (value.length == 6) value = 'FF$value';
  final parsed = int.tryParse(value, radix: 16) ?? 0xFFCCCCCC;
  return Color(parsed);
}
