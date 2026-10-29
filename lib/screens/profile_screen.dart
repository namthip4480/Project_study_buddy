import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentFaculty;
  final String currentSubject;
  final Function(String name, String faculty, String subject) onProfileSaved;

  const ProfileScreen({
    super.key,
    required this.currentName,
    required this.currentFaculty,
    required this.currentSubject,
    required this.onProfileSaved,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _subjectController;

  String _email = '';
  String _faculty = '';
  String _studentId = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentName);
    _subjectController = TextEditingController(text: widget.currentSubject);
    _loadProfileFromFirestore();
  }

  Future<void> _loadProfileFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _usernameController.text = data['username']?.toString() ?? data['full_name']?.toString() ?? widget.currentName;
            _email = data['email']?.toString() ?? user.email ?? '';
            _faculty = data['faculty']?.toString() ?? widget.currentFaculty;
            _studentId = data['student_id']?.toString() ?? '-';
            _subjectController.text = data['current_subject']?.toString() ?? widget.currentSubject;
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        debugPrint('Error loading profile: $e');
      }
    }
    setState(() {
      _email = FirebaseAuth.instance.currentUser?.email ?? '';
      _faculty = widget.currentFaculty;
      _isLoading = false;
    });
  }

  Future<void> _saveProfileChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    String newUsername = _usernameController.text.trim();
    String newSub = _subjectController.text.trim();

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': newUsername,
        'current_subject': newSub,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    widget.onProfileSaved(newUsername, _faculty, newSub);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('บันทึกข้อมูลชื่อผู้ใช้และวิชาที่เน้นอ่านสำเร็จ! ✨'), backgroundColor: Colors.green),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)));
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('👤 โปรไฟล์ของฉัน', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                tooltip: 'ออกจากระบบ',
                onPressed: _logout,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E6),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFF5722), width: 2),
              ),
              child: const Center(child: Text('🎓', style: TextStyle(fontSize: 48))),
            ),
          ),
          const SizedBox(height: 24),

          // ช่องตั้งค่าชื่อผู้ใช้ (Username)
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'ชื่อผู้ใช้ (Username)',
              hintText: 'ตั้งชื่อผู้ใช้สำหรับใช้แชตและแสดงในแอป',
              prefixIcon: const Icon(Icons.alternate_email, color: Color(0xFFFF5722)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          // ช่องตั้งค่าวิชาที่ต้องการเน้นอ่าน
          TextField(
            controller: _subjectController,
            decoration: InputDecoration(
              labelText: 'วิชาหลักที่ต้องการอ่านในขณะนี้',
              prefixIcon: const Icon(Icons.menu_book_outlined, color: Color(0xFFFF5722)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          // ข้อมูลสถาบันและคณะ Read-only (อิงจากลงทะเบียน)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.badge, color: Color(0xFFFF5722)),
                    title: const Text('รหัสนักศึกษา', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    subtitle: Text(_studentId, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.school, color: Color(0xFFFF5722)),
                    title: const Text('สถาบัน / คณะ', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    subtitle: Text('สถาบันเทคโนโลยีพระจอมเกล้าเจ้าคุณทหารลาดกระบัง\n$_faculty', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.email, color: Color(0xFFFF5722)),
                    title: const Text('อีเมลสถาบัน', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    subtitle: Text(_email, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _saveProfileChanges,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
              child: const Text('บันทึกข้อมูลโปรไฟล์', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text('ออกจากระบบ', style: TextStyle(fontSize: 15, color: Colors.redAccent, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
            ),
          ),
        ],
      ),
    );
  }
}