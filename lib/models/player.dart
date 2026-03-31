import 'dart:typed_data';
import 'package:flutter/material.dart';

class Player {
  final String name;
  final Color color;
  int position;
  int drinksConsumed;
  Uint8List? avatarBytes;

  Player({
    required this.name,
    required this.color,
    this.position = 0,
    this.drinksConsumed = 0,
    this.avatarBytes,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length.clamp(1, 2)).toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color.toARGB32(),
        'position': position,
        'drinksConsumed': drinksConsumed,
        'avatarBytes': avatarBytes,
      };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'] as String? ?? '',
      color: Color(json['color'] as int? ?? Colors.white.toARGB32()),
      position: json['position'] as int? ?? 0,
      drinksConsumed: json['drinksConsumed'] as int? ?? 0,
      avatarBytes: json['avatarBytes'] as Uint8List?,
    );
  }
}
