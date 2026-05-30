import 'package:dental_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Dental app shows dashboard, booking, and cashier', (
    tester,
  ) async {
    await tester.pumpWidget(const DentalApp());

    expect(find.text('DentalOps'), findsWidgets);
    expect(find.text('Today Appointments'), findsOneWidget);
    expect(find.text('Pending Follow Ups'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.event_available_outlined).first);
    await tester.pumpAndSettle();

    expect(find.text('New Appointment'), findsOneWidget);
    expect(find.text('Available Slots'), findsOneWidget);
    expect(find.text('Book appointment'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.point_of_sale_outlined).first);
    await tester.pumpAndSettle();

    expect(find.text('Payment Queue'), findsOneWidget);
    expect(find.text('Checkout Tools'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.work_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('New Project'), findsOneWidget);
    expect(find.text('Project Templates'), findsOneWidget);
    expect(find.text('Lab case tracking rollout'), findsOneWidget);
  });
}
