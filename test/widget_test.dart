// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:queueless/models/ticket.dart';

import 'package:queueless/main.dart';

void main() {
  Ticket makeTicket(String deptId, int number) => Ticket(
    id: 't$number',
    number: number,
    departmentId: deptId,
    departmentName: 'Test',
    userName: 'John',
    joinedAt: DateTime.now(),
  );

  test('Café tickets use the C prefix', () {
    expect(makeTicket('cafe', 101).ticketCode, 'C-101');
  });

  test('Admin Office tickets use the A prefix', () {
    expect(makeTicket('admin_office', 101).ticketCode, 'A-101');
  });
}


