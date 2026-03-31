import 'package:flutter_test/flutter_test.dart';
import 'package:school_attendance/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SchoolAttendanceApp());
    expect(find.text('EduAttend'), findsWidgets);
  });
}
