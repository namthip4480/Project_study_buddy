import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_buddy/screens/login_screen.dart';
import 'package:study_buddy/screens/home_screen.dart';

void main() {
  group('Study Buddy KMITL Unit & Widget Tests', () {
    testWidgets(' LoginScreen UI Render Test', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      expect(find.text('STUDY BUDDY KMITL'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets(' HomeScreen Timer and Tab Render Test', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: HomeScreen(userName: '67030115'),
      ));

      expect(find.text('สวัสดี, 67030115 👋'), findsOneWidget);
      expect(find.text('หน้าหลัก'), findsOneWidget);
      expect(find.text('หาเพื่อนติว'), findsOneWidget);
      expect(find.text('ห้องติวกลุ่ม'), findsOneWidget);
      expect(find.text('พิกัด KMITL'), findsWidgets);
      expect(find.text('โปรไฟล์'), findsOneWidget);
    });
  });
}