import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _subjectController = TextEditingController(text: 'Mobile App Development');

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

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedFaculty = _faculties[5]; // ค่าเริ่มต้น: คณะเทคโนโลยีสารสนเทศ
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        String email = _emailController.text.trim();
        String password = _passwordController.text.trim();

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        User? user = userCredential.user;

        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'username': _usernameController.text.trim(),
            'student_id': _studentIdController.text.trim(),
            'email': email,
            'faculty': _selectedFaculty,
            'current_subject': _subjectController.text.trim(),
            'created_at': FieldValue.serverTimestamp(),
            'last_login': FieldValue.serverTimestamp(),
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('สมัครสมาชิกสำเร็จ! กรุณาล็อกอิน')),
          );
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        String message = 'เกิดข้อผิดพลาดในการสมัครสมาชิก';
        if (e.code == 'email-already-in-use') {
          message = 'อีเมลนี้ถูกใช้งานในระบบแล้ว';
        } else if (e.code == 'weak-password') {
          message = 'รหัสผ่านค่อนข้างคาดเดาง่ายเกินไป';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ลงทะเบียนสมาชิกใหม่')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้ (Username)', prefixIcon: Icon(Icons.alternate_email)),
                validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกชื่อผู้ใช้' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(labelText: 'รหัสนักศึกษา', prefixIcon: Icon(Icons.badge)),
                validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกรหัสนักศึกษา' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedFaculty,
                decoration: const InputDecoration(labelText: 'คณะ / วิทยาลัย (KMITL)', prefixIcon: Icon(Icons.school)),
                isExpanded: true,
                items: _faculties.map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedFaculty = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'วิชาหลักที่จะเน้นอ่าน', prefixIcon: Icon(Icons.book)),
                validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกวิชาที่อ่าน' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'อีเมลสถาบัน (@kmitl.ac.th)', prefixIcon: Icon(Icons.email)),
                validator: (v) {
                  if (v == null || !v.trim().endsWith('@kmitl.ac.th')) {
                    return 'ต้องใช้อีเมล @kmitl.ac.th เท่านั้น';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'รหัสผ่าน (6 ตัวขึ้นไป)', prefixIcon: Icon(Icons.lock)),
                validator: (v) => (v == null || v.length < 6) ? 'รหัสผ่านอย่างน้อย 6 ตัว' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ยืนยันการสมัคร', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
