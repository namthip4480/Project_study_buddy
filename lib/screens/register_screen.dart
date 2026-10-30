import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_buddy/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

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
  String _selectedAvatar = '🎓';

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
    _selectedFaculty = _faculties[5];
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'กรุณากรอกรหัสผ่าน';
    if (value.length < 8) return 'รหัสผ่านต้องมีความยาวอย่างน้อย 8 ตัวอักษร';
    if (!RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]')
        .hasMatch(value)) {
      return r'รหัสผ่านต้องมี ตัวพิมพ์ใหญ่, พิมพ์เล็ก, ตัวเลข และอักขระพิเศษ (@$!%*?&)';
    }
    return null;
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        String email = _emailController.text.trim();
        String password = _passwordController.text.trim();
        String name = _nameController.text.trim();

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        User? user = userCredential.user;

        if (user != null) {
          await user.updateDisplayName(name);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'uid': user.uid,
            'username': name,
            'email': email,
            'faculty': _selectedFaculty,
            'avatar': _selectedAvatar,
            'current_subject': 'Mobile App Development',
            'created_at': FieldValue.serverTimestamp(),
          });

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(userName: name)),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        String message = 'เกิดข้อผิดพลาดในการสมัครสมาชิก';
        if (e.code == 'email-already-in-use') {
          message = 'อีเมลนี้ถูกใช้งานในระบบแล้ว';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('เลือกรูปโปรไฟล์อิโมจิ:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _avatars.length,
                  itemBuilder: (ctx, idx) {
                    final em = _avatars[idx];
                    bool isSel = em == _selectedAvatar;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatar = em),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel
                              ? const Color(0xFFFF5722).withOpacity(0.2)
                              : Colors.grey[100],
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isSel
                                  ? const Color(0xFFFF5722)
                                  : Colors.transparent,
                              width: 2),
                        ),
                        child: Text(em, style: const TextStyle(fontSize: 22)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'ชื่อนักศึกษา (Display Name)',
                    prefixIcon: Icon(Icons.person_outline)),
                validator: (v) =>
                    v == null || v.isEmpty ? 'กรุณากรอกชื่อของคุณ' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedFaculty,
                decoration: const InputDecoration(
                    labelText: 'คณะ / วิทยาลัย (KMITL)',
                    prefixIcon: Icon(Icons.school_outlined)),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'อีเมลสถาบัน (@kmitl.ac.th)',
                    prefixIcon: Icon(Icons.email_outlined)),
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
                decoration: const InputDecoration(
                  labelText: 'รหัสผ่าน',
                  hintText: r'8+ ตัวอักษร (A-Z, a-z, 0-9, อักขระพิเศษ)',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722)),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ยืนยันการสมัครสมาชิก',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
