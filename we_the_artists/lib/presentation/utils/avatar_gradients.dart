import 'package:flutter/material.dart';

class AvatarGradients {
  static const List<List<Color>> gradients = [
    [Color(0xFF667eea), Color(0xFF764ba2)],
    [Color(0xFFf093fb), Color(0xFFF5576C)],
    [Color(0xFF4facfe), Color(0xFF00f2fe)],
    [Color(0xFF43e97b), Color(0xFF38f9d7)],
    [Color(0xFFfa709a), Color(0xFFfee140)],
    [Color(0xFF30cfd0), Color(0xFF330867)],
  ];

  static List<Color> getGradientForUser(String userId) {
    final index = int.tryParse(userId) ?? 0;
    return gradients[index % gradients.length];
  }
}
