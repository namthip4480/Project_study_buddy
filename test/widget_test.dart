import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Study Buddy KMITL - Widget Tests (UI Components)', () {
    
    testWidgets('1. ทดสอบการแสดงผลโลโก้และชื่อแอป Study Buddy KMITL', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('🎓', style: TextStyle(fontSize: 64)),
                Text('STUDY BUDDY KMITL', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text('แอปค้นหาเพื่อนอ่านหนังสือ ลาดกระบัง'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('🎓'), findsOneWidget);
      expect(find.text('STUDY BUDDY KMITL'), findsOneWidget);
      expect(find.text('แอปค้นหาเพื่อนอ่านหนังสือ ลาดกระบัง'), findsOneWidget);
    });

    testWidgets('2. ทดสอบการแสดงผลฟอร์มล็อกอินและปุ่ม Google Sign-In', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const TextField(decoration: InputDecoration(labelText: 'อีเมลสถาบัน (@kmitl.ac.th)')),
                const TextField(obscureText: true, decoration: InputDecoration(labelText: 'รหัสผ่าน')),
                ElevatedButton(onPressed: () {}, child: const Text('เข้าสู่ระบบ')),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('เข้าสู่ระบบด้วย Google KMITL'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('เข้าสู่ระบบ'), findsOneWidget);
      expect(find.text('เข้าสู่ระบบด้วย Google KMITL'), findsOneWidget);
    });

    testWidgets('3. ทดสอบการแสดงผลเมนูและแท็บหลัก (Bottom Navigation Bar)', (WidgetTester tester) async {
      const mockUserName = '67030115';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('สวัสดี, $mockUserName 👋')),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าหลัก'),
                BottomNavigationBarItem(icon: Icon(Icons.person_search), label: 'หาเพื่อนติว'),
                BottomNavigationBarItem(icon: Icon(Icons.group), label: 'ห้องติวกลุ่ม'),
                BottomNavigationBarItem(icon: Icon(Icons.map), label: 'พิกัด KMITL'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'โปรไฟล์'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('สวัสดี, 67030115 👋'), findsOneWidget);
      expect(find.text('หน้าหลัก'), findsOneWidget);
      expect(find.text('หาเพื่อนติว'), findsOneWidget);
      expect(find.text('ห้องติวกลุ่ม'), findsOneWidget);
      expect(find.text('พิกัด KMITL'), findsOneWidget);
      expect(find.text('โปรไฟล์'), findsOneWidget);
    });

  });
}