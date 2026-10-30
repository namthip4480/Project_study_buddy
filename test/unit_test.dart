import 'package:flutter_test/flutter_test.dart';

// 1. Logic: ระบบคำนวณและฟอร์แมตเวลาอ่านหนังสือ
String formatTimerText(int totalSeconds) {
  if (totalSeconds < 0) return '00:00';
  int minutes = totalSeconds ~/ 60;
  int seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

// 2. Logic: ระบบตรวจสอบอีเมลสถาบัน KMITL
bool validateKmitlEmail(String email) {
  final cleanEmail = email.trim().toLowerCase();
  if (cleanEmail.isEmpty) return false;
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@kmitl\.ac\.th$');
  return emailRegex.hasMatch(cleanEmail);
}

// 3. Model: โครงสร้างข้อมูลห้องติว (StudyRoom)
class StudyRoom {
  final String id;
  final String title;
  final String subject;
  final int currentMembers;
  final int maxMembers;

  StudyRoom({
    required this.id,
    required this.title,
    required this.subject,
    required this.currentMembers,
    required this.maxMembers,
  });

  bool get isFull => currentMembers >= maxMembers;

  factory StudyRoom.fromMap(Map<String, dynamic> map, String id) {
    return StudyRoom(
      id: id,
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      currentMembers: map['current_members'] ?? 0,
      maxMembers: map['max_members'] ?? 1,
    );
  }
}

void main() {
  group('Unit Tests - Study Buddy KMITL Core Logic', () {
    
    // --- Test Group 1: Timer Calculation ---
    group('ระบบคำนวณเวลาอ่านหนังสือ (Timer Logic)', () {
      test('แปลงวินาทีเป็นรูปแบบ mm:ss ได้ถูกต้อง', () {
        expect(formatTimerText(150), '02:30');
        expect(formatTimerText(60), '01:00');
        expect(formatTimerText(0), '00:00');
        expect(formatTimerText(3599), '59:59');
      });

      test('จัดการกรณีใส่วินาทีติดลบได้ถูกต้อง', () {
        expect(formatTimerText(-10), '00:00');
      });
    });

    // --- Test Group 2: Email Validation ---
    group('ระบบตรวจสอบอีเมลนักศึกษา (@kmitl.ac.th)', () {
      test('ผ่านเมื่อใช้อีเมลสถาบันถูกต้อง', () {
        expect(validateKmitlEmail('65010001@kmitl.ac.th'), true);
        expect(validateKmitlEmail('namthip.st@kmitl.ac.th'), true);
      });

      test('ไม่ผ่านเมื่อใช้อีเมลโดเมนอื่นหรือรูปแบบไม่ถูกต้อง', () {
        expect(validateKmitlEmail('student@gmail.com'), false);
        expect(validateKmitlEmail('user@kmitl.ac.th.com'), false);
        expect(validateKmitlEmail('invalid-email'), false);
        expect(validateKmitlEmail(''), false);
      });
    });

    // --- Test Group 3: Data Model Logic ---
    group('ระบบจัดการข้อมูลห้องติว (StudyRoom Model)', () {
      test('คำนวณสถานะห้องเต็ม (isFull) ได้ถูกต้อง', () {
        final roomAvailable = StudyRoom(
          id: 'room_1',
          title: 'ติว Mobile App',
          subject: 'Mobile App Dev',
          currentMembers: 3,
          maxMembers: 5,
        );
        final roomFull = StudyRoom(
          id: 'room_2',
          title: 'ติว Calculus',
          subject: 'Calculus I',
          currentMembers: 4,
          maxMembers: 4,
        );

        expect(roomAvailable.isFull, false);
        expect(roomFull.isFull, true);
      });

      test('แปลงข้อมูล Map จาก Database เป็น StudyRoom Object ได้ถูกต้อง', () {
        final mockMap = {
          'title': 'ห้องติวหอสมุดกลาง',
          'subject': 'Database Systems',
          'current_members': 2,
          'max_members': 6,
        };

        final room = StudyRoom.fromMap(mockMap, 'room_101');

        expect(room.id, 'room_101');
        expect(room.title, 'ห้องติวหอสมุดกลาง');
        expect(room.subject, 'Database Systems');
        expect(room.currentMembers, 2);
        expect(room.maxMembers, 6);
        expect(room.isFull, false);
      });
    });

  });
}