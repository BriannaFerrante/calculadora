import 'package:calculator/calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Calculator calc() => Calculator();

  void tap(Calculator calculator, String sequence) {
    for (final key in sequence.split(' ')) {
      calculator.input(key);
    }
  }

  test('suma dos números', () {
    final calculator = calc();
    tap(calculator, '1 + 2 =');
    expect(calculator.display, '3');
  });

  test('resta, multiplica y divide', () {
    final calculator = calc();
    tap(calculator, '9 − 4 =');
    expect(calculator.display, '5');

    tap(calculator, 'C 6 × 7 =');
    expect(calculator.display, '42');

    tap(calculator, 'C 8 ÷ 2 =');
    expect(calculator.display, '4');
  });

  test('encadena operaciones de izquierda a derecha', () {
    final calculator = calc();
    tap(calculator, '2 + 3 × 4 =');
    expect(calculator.display, '20');
  });

  test('acepta decimales y redondea el error binario', () {
    final calculator = calc();
    tap(calculator, '0 . 1 + 0 . 2 =');
    expect(calculator.display, '0.3');

    tap(calculator, 'C 1 . 5 × 2 =');
    expect(calculator.display, '3');
  });

  test('muestra error al dividir por cero', () {
    final calculator = calc();
    tap(calculator, '5 ÷ 0 =');
    expect(calculator.display, 'Error');

    tap(calculator, '9');
    expect(calculator.display, '9');
  });

  test('porcentaje simple y porcentaje sobre una suma', () {
    final calculator = calc();
    tap(calculator, '5 0 %');
    expect(calculator.display, '0.5');

    tap(calculator, 'C 2 0 0 + 1 0 % =');
    expect(calculator.display, '220');
  });

  test('cambia el signo y borra dígitos', () {
    final calculator = calc();
    tap(calculator, '1 2 ±');
    expect(calculator.display, '-12');

    tap(calculator, '⌫');
    expect(calculator.display, '-1');

    tap(calculator, 'C');
    expect(calculator.display, '0');
    expect(calculator.expression, '');
  });

  test('repite la última operación con igual', () {
    final calculator = calc();
    tap(calculator, '5 + 3 = =');
    expect(calculator.display, '11');
  });

  test('reemplaza el operador si se pulsa otro antes del operando', () {
    final calculator = calc();
    tap(calculator, '8 + − 3 =');
    expect(calculator.display, '5');
  });
}
