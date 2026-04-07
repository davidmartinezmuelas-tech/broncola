import 'dart:typed_data';
import 'package:flutter/material.dart';

class Player {
  final String name;
  final Color color;
  int drinksConsumed;
  Uint8List? avatarBytes;

  Player({
    required this.name,
    required this.color,
    this.drinksConsumed = 0,
    this.avatarBytes,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length.clamp(1, 2)).toUpperCase();
  }
}
