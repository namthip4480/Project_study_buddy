class UserModel {
  final String id;
  final String name;
  final int isSynced; // 0 = ออฟไลน์ (ยังไม่ซิงก์), 1 = ออนไลน์ (ซิงก์แล้ว)

  UserModel({
    required this.id,
    required this.name,
    this.isSynced = 0,
  });

  // แปลงจาก Object เป็น Map เพื่อลง SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isSynced': isSynced,
    };
  }

  // แปลงจาก Map ใน SQLite กลับเป็น Object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      isSynced: map['isSynced'] ?? 0,
    );
  }
}
