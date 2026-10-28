import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String currentName;
  final Function(String newName, String faculty, String subject) onProfileSaved;

  const ProfileScreen({
    super.key,
    required this.currentName,
    required this.onProfileSaved,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  final _studySubjectController = TextEditingController(text: 'Business');
  final _hardSubjectController = TextEditingController();
  final _studyStyleController = TextEditingController(text: 'อ่านแบบกลุ่ม');
  final _timeController = TextEditingController(text: 'ช่วงเย็น');
  final _goalController = TextEditingController();

  String _selectedFaculty = 'คณะเทคโนโลยีสารสนเทศ';
  String _selectedDept = 'เทคโนโลยีสารสนเทศ (IT)';
  String _selectedYear = 'ปี 3';

  final List<String> _faculties = [
    'คณะวิศวกรรมศาสตร์',
    'คณะสถาปัตยกรรม ศิลปะและการออกแบบ',
    'คณะครุศาสตร์อุตสาหกรรมและเทคโนโลยี',
    'คณะเทคโนโลยีการเกษตร',
    'คณะวิทยาศาสตร์',
    'คณะอุตสาหกรรมอาหาร',
    'คณะเทคโนโลยีสารสนเทศ',
    'คณะบริหารธุรกิจ',
  ];

  final List<String> _departments = [
    'เทคโนโลยีสารสนเทศ (IT)',
    'วิศวกรรมคอมพิวเตอร์',
    'วิทยาการคอมพิวเตอร์',
    'ครุศาสตร์วิศวกรรม',
  ];

  final List<String> _years = ['ปี 1', 'ปี 2', 'ปี 3', 'ปี 4', 'อื่นๆ'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8DCD5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF5722)),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8DCD5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF5722)),
            ),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildTextField('ชื่อ', _nameController),
            _buildDropdown('คณะ', _selectedFaculty, _faculties, (v) => setState(() => _selectedFaculty = v!)),
            _buildDropdown('สาขา', _selectedDept, _departments, (v) => setState(() => _selectedDept = v!)),
            _buildDropdown('ชั้นปี', _selectedYear, _years, (v) => setState(() => _selectedYear = v!)),
            _buildTextField('วิชาที่กำลังอ่าน', _studySubjectController),
            _buildTextField('วิชาที่อยากอ่าน', _hardSubjectController),
            _buildTextField('รูปแบบการอ่าน', _studyStyleController),
            _buildTextField('ช่วงเวลาที่สะดวก', _timeController),
            _buildTextField('เป้าหมายการอ่าน', _goalController),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // ส่งค่าโปรไฟล์กลับไปอัปเดตที่หน้า Home
                  widget.onProfileSaved(
                    _nameController.text,
                    _selectedFaculty,
                    _studySubjectController.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('บันทึกโปรไฟล์และอัปเดตข้อมูลแล้ว!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('บันทึกโปรไฟล์', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}