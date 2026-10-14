import 'package:calculator/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('calcula 12 + 7 en la pantalla', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculadoraApp());

    expect(tester.widget<Text>(find.byKey(const Key('display'))).data, '0');

    await tester.tap(find.byKey(const Key('key-1')));
    await tester.tap(find.byKey(const Key('key-2')));
    await tester.tap(find.byKey(const Key('key-+')));
    await tester.tap(find.byKey(const Key('key-7')));
    await tester.tap(find.byKey(const Key('key-=')));
    await tester.pump();

    expect(tester.widget<Text>(find.byKey(const Key('display'))).data, '19');
    expect(
      tester.widget<Text>(find.byKey(const Key('expression'))).data,
      '12 + 7 =',
    );
  });
}
