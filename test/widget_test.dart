import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_shopping_app/presentation/widgets/quantity_stepper.dart';

void main() {
  testWidgets('QuantityStepper increments and decrements', (tester) async {
    int? lastValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuantityStepper(
            quantity: 2,
            min: 1,
            onChanged: (value) => lastValue = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(lastValue, 3);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(lastValue, 1);
  });

  testWidgets('QuantityStepper disables decrement at the minimum', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuantityStepper(quantity: 1, min: 1, onChanged: (_) {}),
        ),
      ),
    );

    final removeButton =
        tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.remove));
    expect(removeButton.onPressed, isNull);
  });
}
