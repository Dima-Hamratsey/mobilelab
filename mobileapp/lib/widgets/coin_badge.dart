import 'package:flutter/material.dart';

class CoinBadge extends StatelessWidget {
  const CoinBadge({
    super.key,
    this.size = 72,
    this.icon = Icons.currency_bitcoin,
  });

  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shadowColor = Colors.black.withValues(alpha: 0.2);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.secondary,
            scheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: scheme.primary, width: 2),
      ),
      child: Icon(
        icon,
        size: size * 0.45,
        color: scheme.onPrimary,
      ),
    );
  }
}
