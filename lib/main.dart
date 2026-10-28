import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  // บังคับให้ Flutter Binding ทำงานเรียบร้อยก่อนเรียกใช้ Widget หรือ Database
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudyBuddyApp());
}

class StudyBuddyApp extends StatelessWidget {
  const StudyBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ชื่อแอปพลิเคชัน
      title: 'Study Buddy KMITL',
      
      // ซ่อนแถบ Debug สีแดงมุมขวาบน
      debugShowCheckedModeBanner: false,

      // กำหนด Theme สีครีม-ส้ม มินิมอล KMITL ตามแบบ Figma
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF2ED), // สีพื้นหลังครีมอ่อน
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF5722), // สีส้มหลัก KMITL
          primary: const Color(0xFFFF5722),
          surface: const Color(0xFFFAF2ED),
        ),
        
        // กำหนดสไตล์ของ AppBar ทั่วทั้งแอป
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF2ED),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        // กำหนดสไตล์ของ Input/TextField ทั่วทั้งแอป
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8DCD5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF5722), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),

        // กำหนดสไตล์ปุ่มกดหลัก (ElevatedButton)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF5722),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      // ตั้งค่าหน้าแรกสุดของแอปเป็นหน้า LoginScreen (@kmitl.ac.th)
      home: const LoginScreen(),
    );
  }
}