// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pagavel/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Buimport 'package:flutter/material.dart';
    // import 'package:flutter_test/flutter_test.dart';
    //
    // import 'package:cadastro_contas/main.dart'; // importa seu app
    //
    // void main() {
    //   testWidgets('verifica se o botão de adicionar está na tela', (WidgetTester tester) async {
    //     // Carrega o widget do app
    //     await tester.pumpWidget(ContasApp());
    //
    //     // Verifica se o FloatingActionButton com o ícone de adicionar está presente
    //     expect(find.byIcon(Icons.add), findsOneWidget);
    //   });
    // }
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
