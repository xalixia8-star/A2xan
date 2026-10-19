import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaulte/data/catalog/service_catalog.dart';
import 'package:vaulte/shared/widgets/strength_meter.dart';
import 'package:vaulte/theme/app_theme.dart';

void main() {
  test('katalog layanan: id unik dan tidak kosong', () {
    final ids = kServiceCatalog.map((e) => e.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(kServiceCatalog.length, greaterThan(100));
  });

  testWidgets('StrengthMeter menampilkan label', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: const Scaffold(body: StrengthMeter(password: 'Xk9#mQ2\$vL7!pR4&zN8@')),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('Kekuatan'), findsOneWidget);
  });
}
