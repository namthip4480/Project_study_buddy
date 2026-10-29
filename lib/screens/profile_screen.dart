import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late TextEditingController _emailController;
  late TextEditingController _subjectController;

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

  late String _selectedFaculty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(
      text: widget.currentName.contains('@')
          ? widget.currentName
          : '${widget.currentName.replaceAll(' ', '').toLowerCase()}@kmitl.ac.th',
    );
    _subjectController = TextEditingController(text: widget.currentSubject);
    _selectedFaculty = _faculties.contains(widget.currentFaculty)
        ? widget.currentFaculty
        : _faculties[5]; // ค่าเริ่มต้น: คณะเทคโนโลยีสารสนเทศ
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  // บันทึกข้อมูลลง SharedPreferences
  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setString('user_faculty', _selectedFaculty);
    await prefs.setString('user_subject', _subjectController.text.trim());

    widget.onProfileSaved(
      _nameController.text.trim(),
      _selectedFaculty,
      _subjectController.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกข้อมูลโปรไฟล์และเชื่อมต่อไปหน้า Home เรียบร้อยแล้ว! ✨'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('👤 โปรไฟล์ของฉัน', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('ข้อมูลบัญชีผู้ใช้สำหรับ Study Buddy KMITL', style: TextStyle(fontSize: 12, color: Colors.black45)),
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
              child: const Center(
                child: Text('🎓', style: TextStyle(fontSize: 48)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'ชื่อ - นามสกุล / ชื่อเล่น',
              prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFFF5722)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'อีเมลสถาบัน (@kmitl.ac.th)',
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFFF5722)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedFaculty,
            decoration: InputDecoration(
              labelText: 'คณะ / วิทยาลัย (KMITL)',
              prefixIcon: const Icon(Icons.school_outlined, color: Color(0xFFFF5722)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            isExpanded: true,
            items: _faculties.map((faculty) {
              return DropdownMenuItem<String>(
                value: faculty,
                child: Text(faculty, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedFaculty = val);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _subjectController,
            decoration: InputDecoration(
              labelText: 'วิชาหลักที่กำลังเน้นอ่าน',
              prefixIcon: const Icon(Icons.menu_book_outlined, color: Color(0xFFFF5722)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5722),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('บันทึกข้อมูล', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}