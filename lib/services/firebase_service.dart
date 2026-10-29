import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ส่งข้อมูลขึ้น Firebase Firestore
  Future<bool> uploadUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'name': user.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true; // ส่งสำเร็จ
    } catch (e) {
      print("Firebase Upload Error: $e");
      return false; // ส่งไม่สำเร็จ (ไม่มีเน็ต หรือ Error)
    }
  }
}