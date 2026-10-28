class StudySession {
  final int? id;
  final String subject;
  final int durationMinutes;
  final String date;

  StudySession({
    this.id,
    required this.subject,
    required this.durationMinutes,
    required this.date,
  });

  // แปลงวัตถุเป็น Map เพื่อบันทึกลง SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'durationMinutes': durationMinutes,
      'date': date,
    };
  }

  // แปลง Map จาก SQLite กลับมาเป็นวัตถุ Dart
  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'] as int?,
      subject: map['subject'] as String,
      durationMinutes: map['durationMinutes'] as int,
      date: map['date'] as String,
    );
  }
}