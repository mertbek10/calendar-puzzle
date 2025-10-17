import 'package:flutter/material.dart';

class Hud extends StatelessWidget {
  final String title;
  final int elapsedSeconds;
  final int hintsLeft;
  final VoidCallback onReset;
  final VoidCallback onHint;

  const Hud({
    super.key,
    required this.title,
    required this.elapsedSeconds,
    required this.hintsLeft,
    required this.onReset,
    required this.onHint,
  });

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return "$m:$ss";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Icon(Icons.timer, color: Colors.white70, size: 18),
        const SizedBox(width: 6),
        Text(
          _fmt(elapsedSeconds),
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: hintsLeft > 0 ? onHint : null,
          icon: const Icon(Icons.tips_and_updates, size: 18),
          label: Text("İpucu ($hintsLeft)"),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text("Sıfırla"),
        ),
      ],
    );
  }
}
