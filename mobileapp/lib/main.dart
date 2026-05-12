import 'package:flutter/material.dart';

void main() {
  runApp(const MinerApp());
}

class MinerApp extends StatelessWidget {
  const MinerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miner',
      theme: ThemeData(colorSchemeSeed: Colors.amber),
      home: const MinerHomePage(),
    );
  }
}

class MinerHomePage extends StatefulWidget {
  const MinerHomePage({super.key});

  @override
  State<MinerHomePage> createState() => _MinerHomePageState();
}

class _MinerHomePageState extends State<MinerHomePage> {
  static const String _secretWord = 'лудоманія';
  final TextEditingController _secretController = TextEditingController();

  int _coins = 0;

  @override
  void dispose() {
    _secretController.dispose();
    super.dispose();
  }

  void _mineCoin() {
    setState(() {
      _coins += 1;
    });
  }

  void _onSecretChanged(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == _secretWord) {
      _grantBonus();
    }
  }

  void _grantBonus() {
    setState(() {
      _coins += 100;
    });

    _secretController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bonus +100 coins!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Miner'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Coins'),
              const SizedBox(height: 4),
              Text(
                '$_coins',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _CoinButton(onTap: _mineCoin),
              const SizedBox(height: 24),
              TextField(
                controller: _secretController,
                onChanged: _onSecretChanged,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Secret word',
                  hintText: 'лудоманія',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Type "лудоманія" for +100.'),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinButton extends StatelessWidget {
  const _CoinButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shadowColor = Colors.black.withValues(alpha: 0.2);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        height: 140,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amber.shade400,
            border: Border.all(color: Colors.brown, width: 4),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.monetization_on,
                size: 52,
                color: Colors.brown.shade900,
              ),
              const SizedBox(height: 6),
              const Text(
                '+1',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
