import 'package:connectivity_plus/connectivity_plus.dart';
import 'sqlite_service.dart';
import 'firebase_service.dart';
import '../models/user_model.dart';

class SyncService {
  final SqliteService _sqliteService = SqliteService();
  final FirebaseService _firebaseService = FirebaseService();

  // ฟังก์ชันหลัก: เซฟลง SQLite ก่อน แล้วพยายามส่งขึ้น Firebase
  Future<void> saveData(String id, String name) async {
    // 1. บันทึกลงเครื่อง (SQLite) ทันที เพื่อให้ออฟไลน์ก็ใช้งานได้
    UserModel user = UserModel(id: id, name: name, isSynced: 0);
    await _sqliteService.insertUser(user);

    // 2. พยายามซิงก์ขึ้น Firebase
    await syncUnsyncedData();
  }

  // ฟังก์ชันตรวจสอบและซิงก์ข้อมูลที่ค้างอยู่
  Future<void> syncUnsyncedData() async {
    // เช็กสถานะอินเทอร์เน็ต
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      print("ออฟไลน์อยู่: ข้อมูลถูกบันทึกใน SQLite เรียบร้อยแล้ว");
      return;
    }

    // ดึงข้อมูลทั้งหมดที่ยังไม่ได้ซิงก์ (isSynced = 0)
    List<UserModel> unsyncedUsers = await _sqliteService.getUnsyncedUsers();

    for (var user in unsyncedUsers) {
      bool success = await _firebaseService.uploadUser(user);
      if (success) {
        // เมื่อส่งขึ้น Firebase สำเร็จ ให้เปลี่ยนสถานะใน SQLite เป็น 1
        await _sqliteService.markAsSynced(user.id);
        print("ซิงก์สำเร็จ: ${user.id}");
      }
    }
  }
}
