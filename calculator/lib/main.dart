import 'package:flutter/material.dart';

import 'calculator.dart';

void main() {
  runApp(const CalculadoraApp());
}

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF9F0A),
          brightness: Brightness.dark,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final Calculator _calculator = Calculator();

  void _onKey(String key) {
    setState(() => _calculator.input(key));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Column(
                children: [
                  Expanded(flex: 2, child: _Display(calculator: _calculator)),
                  Expanded(
                    flex: 5,
                    child: _Keypad(
                      onKey: _onKey,
                      activeOperator: _calculator.activeOperator,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Display extends StatelessWidget {
  const _Display({required this.calculator});

  final Calculator calculator;

  @override
  Widget build(BuildContext context) {
    final isError = calculator.display == 'Error';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 28,
            child: Text(
              calculator.expression,
              key: const Key('expression'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              calculator.display,
              key: const Key('display'),
              style: TextStyle(
                color: isError ? const Color(0xFFFF453A) : Colors.white,
                fontSize: 76,
                fontWeight: FontWeight.w300,
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey, required this.activeOperator});

  final ValueChanged<String> onKey;
  final String? activeOperator;

  static const _rows = [
    ['C', '⌫', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['±', '0', '.', '='],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _rows)
          Expanded(
            child: Row(
              children: [
                for (final key in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: _CalcButton(
                        key: Key('key-$key'),
                        label: key,
                        highlighted: key == activeOperator,
                        onTap: () => onKey(key),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CalcButton extends StatelessWidget {
  const _CalcButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.highlighted,
  });

  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(label, highlighted);

    return Semantics(
      button: true,
      label: _semanticsLabel(label),
      child: Material(
        color: style.background,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Center(child: _content(style.foreground)),
        ),
      ),
    );
  }

  Widget _content(Color foreground) {
    if (label == '⌫') {
      return Icon(Icons.backspace_outlined, color: foreground, size: 26);
    }
    return Text(
      label,
      style: TextStyle(
        color: foreground,
        fontSize: 32,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  _ButtonStyle _styleFor(String key, bool isHighlighted) {
    const orange = Color(0xFFFF9F0A);
    const number = Color(0xFF2C2C2E);
    const function = Color(0xFF3A3A3C);

    if (isHighlighted) {
      return const _ButtonStyle(background: Colors.white, foreground: orange);
    }
    if (key == '=') {
      return const _ButtonStyle(background: orange, foreground: Colors.white);
    }
    if (key == '+' || key == '−' || key == '×' || key == '÷') {
      return const _ButtonStyle(background: orange, foreground: Colors.white);
    }
    if (key == 'C' || key == '⌫' || key == '%' || key == '±') {
      return const _ButtonStyle(
        background: function,
        foreground: Colors.white,
      );
    }
    return const _ButtonStyle(background: number, foreground: Colors.white);
  }

  String _semanticsLabel(String key) {
    switch (key) {
      case 'C':
        return 'Borrar todo';
      case '⌫':
        return 'Borrar';
      case '%':
        return 'Porcentaje';
      case '÷':
        return 'Dividir';
      case '×':
        return 'Multiplicar';
      case '−':
        return 'Restar';
      case '+':
        return 'Sumar';
      case '=':
        return 'Igual';
      case '±':
        return 'Cambiar signo';
      case '.':
        return 'Decimal';
      default:
        return key;
    }
  }
}

class _ButtonStyle {
  const _ButtonStyle({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
