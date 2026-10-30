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
  late TextEditingController _nameController;
  late TextEditingController _subjectController;

  String _email = '';
  late String _selectedFaculty;
  String _avatar = '🎓';
  bool _isLoading = true;

  final List<String> _avatars = [
    '🎓',
    '🦊',
    '🐱',
    '🐼',
    '🚀',
    '👾',
    '🍕',
    '🐻'
  ];
  final List<String> _faculties = [
    'คณะวิศวกรรมศาสตร์',
    'คณะสถาปัตยกรรม ศิลปะและการออกแบบ',
    'คณะครุศาสตร์อุตสาหกรรมและเทคโนโลยี',
    'คณะเทคโนโลยีการเกษตร',
    'คณะวิทยาศาสตร์',
    'คณะเทคโนโลยีสารสนเทศ',
    'คณะอุตสาหกรรมอาหาร',
    'คณะบริหารธุรกิจ (KMITL Business School)',
    'คณะศิลปศาสตร์',
    'คณะแพทยศาสตร์',
    'คณะทันตแพทยศาสตร์',
    'คณะพยาบาลศาสตร์',
    'คณะเทคโนโลยีนวัตกรรมบูรณาการ',
    'วิทยาลัยอุตสาหกรรมการบินนานาชาติ (IAAI)',
    'วิทยาลัยวิศวกรรมสังคีต',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _subjectController = TextEditingController(text: widget.currentSubject);
    _selectedFaculty = _faculties.contains(widget.currentFaculty)
        ? widget.currentFaculty
        : _faculties[5];
    _loadProfileFromFirestore();
  }

  Future<void> _loadProfileFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text =
                data['username']?.toString() ?? widget.currentName;
            _email = data['email']?.toString() ?? user.email ?? '';
            String fac = data['faculty']?.toString() ?? widget.currentFaculty;
            if (_faculties.contains(fac)) _selectedFaculty = fac;
            _avatar = data['avatar']?.toString() ?? '🎓';
            _subjectController.text =
                data['current_subject']?.toString() ?? widget.currentSubject;
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        debugPrint('Error loading profile: $e');
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    String newName = _nameController.text.trim();
    String newSub = _subjectController.text.trim();

    if (user != null && newName.isNotEmpty) {
      await user.updateDisplayName(newName);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': newName,
        'faculty': _selectedFaculty,
        'avatar': _avatar,
        'current_subject': newSub,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      widget.onProfileSaved(newName, _selectedFaculty, newSub);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('อัปเดตข้อมูลโปรไฟล์เรียบร้อยแล้ว! ✨'),
            backgroundColor: Colors.green),
      );
    }
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
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF5722)));
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('👤 โปรไฟล์ส่วนตัว',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E6),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFF5722), width: 2),
              ),
              child: Center(
                  child: Text(_avatar, style: const TextStyle(fontSize: 48))),
            ),
          ),
          const SizedBox(height: 12),

          // ถาดเลือกรูปโปรไฟล์อิโมจิ
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _avatars.length,
              itemBuilder: (ctx, idx) {
                final em = _avatars[idx];
                bool isSel = em == _avatar;
                return GestureDetector(
                  onTap: () => setState(() => _avatar = em),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSel
                          ? const Color(0xFFFF5722).withOpacity(0.2)
                          : Colors.grey[100],
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: isSel
                              ? const Color(0xFFFF5722)
                              : Colors.transparent),
                    ),
                    child: Text(em, style: const TextStyle(fontSize: 20)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'ชื่อนักศึกษา (Display Name)',
              prefixIcon:
                  const Icon(Icons.person_outline, color: Color(0xFFFF5722)),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),

          DropdownButtonFormField<String>(
            value: _selectedFaculty,
            decoration: InputDecoration(
              labelText: 'คณะ / วิทยาลัย (KMITL)',
              prefixIcon:
                  const Icon(Icons.school_outlined, color: Color(0xFFFF5722)),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            isExpanded: true,
            items: _faculties
                .map((f) => DropdownMenuItem(
                    value: f,
                    child: Text(f, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedFaculty = val);
            },
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _subjectController,
            decoration: InputDecoration(
              labelText: 'วิชาหลักที่กำลังเน้นอ่าน',
              prefixIcon: const Icon(Icons.menu_book_outlined,
                  color: Color(0xFFFF5722)),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                leading:
                    const Icon(Icons.email_outlined, color: Color(0xFFFF5722)),
                title: const Text('อีเมลสถาบัน',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
                subtitle: Text(_email, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _updateProfileData,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722)),
              child: const Text('บันทึกการเปลี่ยนแปลง',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text('ออกจากระบบ',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent)),
            ),
          ),
        ],
      ),
    );
  }
}
