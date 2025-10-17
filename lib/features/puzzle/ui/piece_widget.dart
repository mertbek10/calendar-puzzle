import 'package:flutter/material.dart';

class PieceWidget extends StatelessWidget {
  final String code; // "A".."J"
  const PieceWidget({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    // Şimdilik sadece görsel temsil: ileride Draggable ile saracağız.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEDCC3).withOpacity(0.15),
        border: Border.all(color: Colors.white24, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        code,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
