import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'profile_screen.dart';

/// หน้าหลักของแอปพลิเคชัน ควบคุมการเปลี่ยน Tab และจัดการข้อมูลโปรไฟล์ ตัวจับเวลา
class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ตัวแปรสำหรับสลับหน้าของ BottomNavigationBar (0: หน้าหลัก, 1: หาเพื่อนติว, 2: ห้องติว, 3: พิกัด, 4: โปรไฟล์)
  int _selectedIndex = 0;

  // ตัวแปรเก็บข้อมูลผู้ใช้ที่ดึงมาจาก Firestore
  late String _displayName;
  String _currentFaculty = 'คณะเทคโนโลยีสารสนเทศ';
  String _currentSubject = 'Mobile App Development';

  // ตัวแปรควบคุมระบบจับเวลาอ่านหนังสือ
  bool _isStudying = false;
  int _remainingSeconds = 60; // เวลาที่เหลือ (วินาที)
  int _targetMinutes = 1;     // เป้าหมาย (นาที)
  Timer? _timer;

  // Instance สำหรับติดต่อฐานข้อมูล Firebase Cloud Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _displayName = widget.userName;
    _fetchUserDataFromFirestore(); // ดึงข้อมูลโปรไฟล์จาก Firestore ตาม UID ตอนล็อกอิน
  }

  /// ดึงข้อมูลผู้ใช้จริงจาก Firestore Collection 'users' ตาม UID
  Future<void> _fetchUserDataFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            // อิงตาม Username หากไม่มีให้ใช้ Full Name
            _displayName = data['username']?.toString() ?? data['full_name']?.toString() ?? widget.userName;
            _currentFaculty = data['faculty']?.toString() ?? 'คณะเทคโนโลยีสารสนเทศ';
            _currentSubject = data['current_subject']?.toString() ?? 'Mobile App Development';
          });
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
      }
    }
  }

  /// บันทึกประวัติการอ่านหนังสือลง Firestore Collection 'study_timers'
  Future<void> _saveTimerToFirestore(int actualSeconds, bool isCompleted) async {
    try {
      await _firestore.collection('study_timers').add({
        'user_name': _displayName,
        'subject': _currentSubject,
        'target_minutes': _targetMinutes,
        'actual_seconds': actualSeconds,
        'is_completed': isCompleted,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving timer to Firestore: $e');
    }
  }

  /// เริ่มจับเวลาอ่านหนังสือ
  void _startTimer(String subject, int targetMins) {
    _timer?.cancel();
    setState(() {
      _currentSubject = subject;
      _targetMinutes = targetMins;
      _remainingSeconds = targetMins * 60;
      _isStudying = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() {
          _isStudying = false;
          _remainingSeconds = _targetMinutes * 60;
        });
        _saveTimerToFirestore(_targetMinutes * 60, true);

        // แสดง Dialog แจ้งเตือนเมื่ออ่านครบเวลา
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('🎉 อ่านหนังสือสำเร็จ!'),
            content: Text('คุณอ่านหนังสือวิชา $_currentSubject ครบกำหนด $_targetMinutes นาทีเรียบร้อยแล้ว เก่งมากครับ! ✨'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('รับทราบ', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    });
  }

  /// อ่านหนังสือต่อจากเวลาที่พักไว้
  void _resumeTimer() {
    _timer?.cancel();
    setState(() => _isStudying = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() {
          _isStudying = false;
          _remainingSeconds = _targetMinutes * 60;
        });
        _saveTimerToFirestore(_targetMinutes * 60, true);

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('🎉 อ่านหนังสือสำเร็จ!'),
            content: Text('คุณอ่านหนังสือวิชา $_currentSubject ครบกำหนด $_targetMinutes นาทีเรียบร้อยแล้ว เก่งมากครับ! ✨'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('รับทราบ', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    });
  }

  /// พักการจับเวลาชั่วคราว
  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isStudying = false);
  }

  /// ยกเลิก/หยุดการจับเวลา
  void _stopTimer() {
    _timer?.cancel();
    int actualSpent = (_targetMinutes * 60) - _remainingSeconds;
    if (actualSpent > 0) {
      _saveTimerToFirestore(actualSpent, false);
    }
    setState(() {
      _isStudying = false;
      _remainingSeconds = _targetMinutes * 60;
    });
  }

  /// แปลงจำนวนวินาทีให้อยู่ในรูปแบบ mm:ss
  String _formatTime(int sec) {
    int m = sec ~/ 60;
    int s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// สร้างห้องติวใหม่ลง Firestore Collection 'study_rooms'
  Future<void> _addStudyRoom(String title, String subject, String location, int maxMembers) async {
    try {
      await _firestore.collection('study_rooms').add({
        'title': title,
        'subject': subject,
        'location': location,
        'current_members': 1,
        'max_members': maxMembers,
        'host_name': _displayName,
        'tag': 'สร้างใหม่',
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding study room: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // รายการหน้ารับของแต่ละ Tab
    final List<Widget> pages = [
      HomeTab(
        displayName: _displayName,
        currentFaculty: _currentFaculty,
        currentSubject: _currentSubject,
        targetMinutes: _targetMinutes,
        isStudying: _isStudying,
        remainingSeconds: _remainingSeconds,
        formatTime: _formatTime,
        onStartStudy: _startTimer,
        onResume: _resumeTimer,
        onPause: _pauseTimer,
        onStop: _stopTimer,
        onNavigateTab: (index) => setState(() => _selectedIndex = index),
      ),
      BuddyTab(
        userSubject: _currentSubject,
        currentUserName: _displayName,
        firestore: _firestore,
        onBackToHome: () => setState(() => _selectedIndex = 0),
      ),
      StudyRoomTab(
        firestore: _firestore,
        onCreateRoom: _addStudyRoom,
        onBackToHome: () => setState(() => _selectedIndex = 0),
      ),
      MapTab(
        onBackToHome: () => setState(() => _selectedIndex = 0),
      ),
      ProfileScreen(
        currentName: _displayName,
        currentFaculty: _currentFaculty,
        currentSubject: _currentSubject,
        onProfileSaved: (newName, faculty, subject) {
          setState(() {
            _displayName = newName;
            _currentFaculty = faculty;
            _currentSubject = subject;
          });
        },
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFFF5722),
          unselectedItemColor: const Color(0xFFA0A0A0),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'หน้าหลัก'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), activeIcon: Icon(Icons.people_alt), label: 'หาเพื่อนติว'),
            BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups), label: 'ห้องติวกลุ่ม'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'พิกัด KMITL'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'โปรไฟล์'),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// 1. HOME TAB - หน้า Dashboard หลัก ตัวจับเวลา และ AI Assistant
// =========================================================
class HomeTab extends StatelessWidget {
  final String displayName;
  final String currentFaculty;
  final String currentSubject;
  final int targetMinutes;
  final bool isStudying;
  final int remainingSeconds;
  final String Function(int) formatTime;
  final Function(String, int) onStartStudy;
  final VoidCallback onResume;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final Function(int) onNavigateTab;

  const HomeTab({
    super.key,
    required this.displayName,
    required this.currentFaculty,
    required this.currentSubject,
    required this.targetMinutes,
    required this.isStudying,
    required this.remainingSeconds,
    required this.formatTime,
    required this.onStartStudy,
    required this.onResume,
    required this.onPause,
    required this.onStop,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    bool hasStarted = remainingSeconds < targetMinutes * 60;
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth > 600 ? 32 : 20, // Responsive คำนวณขอบตามขนาดหน้าจอ
          vertical: 16,
        ),
        children: [
          // Header แสดงข้อมูลบัญชีและคณะ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF7043), Color(0xFFFF5722)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(child: Text('🎓', style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('STUDY BUDDY KMITL', style: TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1)),
                          Text('สวัสดี, @$displayName 👋', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C)), overflow: TextOverflow.ellipsis),
                          Text(currentFaculty, style: const TextStyle(fontSize: 11, color: Colors.black54), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // แถบแสดงวิชาเป้าหมายหลักที่จะเน้นอ่าน
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFCC80)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_stories, color: Color(0xFFFF5722)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('เป้าหมายวิชาที่เน้นอ่านในขณะนี้:', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      Text(currentSubject, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFFF5722))),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateTab(4), // สลับไปสลับวิชาในหน้าโปรไฟล์
                  child: const Text('เปลี่ยนวิชา', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // การ์ดจับเวลาอ่านหนังสือ (Count-down Timer)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isStudying ? const Color(0xFFFF5722) : const Color(0xFFE8DCD5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isStudying ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: isStudying ? Colors.green : Colors.orange),
                          const SizedBox(width: 6),
                          Text(
                            isStudying ? 'กำลังจับเวลาอ่านหนังสือ' : 'พร้อมเริ่มอ่านหนังสือหรือยัง?',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isStudying ? Colors.green[800] : Colors.orange[800]),
                          ),
                        ],
                      ),
                    ),
                    Text('เป้าหมาย $targetMinutes นาที', style: const TextStyle(fontSize: 11, color: Colors.black45)),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    formatTime(remainingSeconds),
                    style: TextStyle(
                      fontSize: screenWidth > 600 ? 64 : 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: isStudying ? const Color(0xFFFF5722) : const Color(0xFFBDBDBD),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ปุ่มควบคุมเวลา (เริ่ม / พัก / หยุด)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (isStudying) {
                            onPause();
                          } else if (hasStarted) {
                            onResume();
                          } else {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                              builder: (ctx) => StartStudyModal(
                                currentSubject: currentSubject,
                                onStart: onStartStudy,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5722),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          isStudying ? 'พักชั่วคราว' : (hasStarted ? 'อ่านต่อ' : 'เริ่มอ่านเลย! 🔥'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ),
                    if (hasStarted || isStudying) ...[
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: onStop,
                        tooltip: 'ยกเลิก / เริ่มนับใหม่',
                        icon: const Icon(Icons.stop_circle_outlined, color: Colors.red, size: 36),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ปุ่มทางลัดฟีเจอร์ยอดฮิต
          const Text('ฟีเจอร์ยอดฮิต ⚡', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: screenWidth > 600 ? 4 : 2, // สลับคอลัมน์อัตโนมัติตามขนาดจอ
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildFeatureCard('หา Buddy ติว', 'แมตช์เพื่อนอ่านวิชาเดียวกัน', Icons.person_search_rounded, const Color(0xFFFFE0B2), () => onNavigateTab(1)),
              _buildFeatureCard('Study Room', 'เข้าร่วมกลุ่มอ่านหนังสือ', Icons.groups_rounded, const Color(0xFFC8E6C9), () => onNavigateTab(2)),
              _buildFeatureCard('พิกัด KMITL', 'เช็คสถานที่และสิ่งอำนวยความสะดวก', Icons.pin_drop_rounded, const Color(0xFFBBDEFB), () => onNavigateTab(3)),
              _buildFeatureCard('แก้ไขโปรไฟล์', 'ตั้งค่าคณะ/วิชาที่อ่าน', Icons.badge_rounded, const Color(0xFFE1BEE7), () => onNavigateTab(4)),
            ],
          ),
          const SizedBox(height: 16),

          // แบนเนอร์ปุ่มเปิด AI Assistant (Gemini AI)
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E24AA), Color(0xFF5E35B1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (ctx) => AIAssistantModal(currentSubject: currentSubject),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('AI ผู้ช่วยติวหนังสือ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.amberAccent, borderRadius: BorderRadius.circular(6)),
                                  child: const Text('GEMINI AI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text('วางแผนการอ่าน & สรุปบทเรียนด้วย Gemini AI', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String desc, IconData icon, Color bgIcon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8DCD5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bgIcon.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: const Color(0xFFFF5722), size: 20),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C2C2C))),
            Text(desc, style: const TextStyle(fontSize: 10, color: Colors.black45), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ---------------- Modal ตั้งเวลาอ่านหนังสือ ----------------
class StartStudyModal extends StatefulWidget {
  final String currentSubject;
  final Function(String subject, int mins) onStart;
  const StartStudyModal({super.key, required this.currentSubject, required this.onStart});

  @override
  State<StartStudyModal> createState() => _StartStudyModalState();
}

class _StartStudyModalState extends State<StartStudyModal> {
  late TextEditingController _subjectController;
  late TextEditingController _minsController;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.currentSubject);
    _minsController = TextEditingController(text: '25'); // เทคนิค Pomodoro 25 นาที
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('เริ่มจับเวลาอ่านหนังสือ 🔥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context), // ปุ่มปิด Modal
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'วิชาที่จะอ่าน', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _minsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'ตั้งเป้าหมายกี่นาที?', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
              onPressed: () {
                int mins = int.tryParse(_minsController.text.trim()) ?? 1;
                String sub = _subjectController.text.trim().isEmpty ? widget.currentSubject : _subjectController.text.trim();
                widget.onStart(sub, mins);
                Navigator.pop(context);
              },
              child: const Text('ลุยเลย!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- GEMINI AI ASSISTANT MODAL ----------------
class AIAssistantModal extends StatefulWidget {
  final String currentSubject;
  const AIAssistantModal({super.key, required this.currentSubject});

  @override
  State<AIAssistantModal> createState() => _AIAssistantModalState();
}

class _AIAssistantModalState extends State<AIAssistantModal> {
  late TextEditingController _subjectController;
  bool _isLoading = false;
  String _aiResponseText = '';

  static const String _defaultApiKey = '';
  String _apiKey = _defaultApiKey;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.currentSubject);
    _loadSavedApiKey();
  }

  Future<void> _loadSavedApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString('custom_gemini_api_key');
    if (savedKey != null && savedKey.trim().isNotEmpty) {
      if (mounted) setState(() => _apiKey = savedKey.trim());
    }
  }

  Future<void> _callGeminiAPI(String promptType) async {
    final subject = _subjectController.text.trim().isEmpty ? widget.currentSubject : _subjectController.text.trim();

    setState(() {
      _isLoading = true;
      _aiResponseText = '';
    });

    final apiKeyToUse = _apiKey.trim().isNotEmpty ? _apiKey.trim() : _defaultApiKey;

    try {
      final prompt = promptType == 'plan'
          ? 'ช่วยจัดตารางและแผนการอ่านหนังสือสอบวิชา $subject สำหรับนักศึกษามหาวิทยาลัยแบบสั้นกระชับ เป็นข้อๆ'
          : 'ช่วยสรุปเทคนิคการอ่านและจดจำเนื้อหาวิชา $subject ให้สอบผ่านได้เกรด A แบบสั้นกระชับ เป็นข้อๆ';

      // รายชื่อรุ่น AI Gemini เรียงตามความพร้อมใช้งาน
      final candidateModels = [
        'gemini-1.5-flash',
        'gemini-2.5-flash',
        'gemini-pro',
      ];

      String? resultText;
      dynamic lastError;

      for (final modelName in candidateModels) {
        try {
          final model = GenerativeModel(model: modelName, apiKey: apiKeyToUse);
          final response = await model.generateContent([Content.text(prompt)]);
          if (response.text != null && response.text!.trim().isNotEmpty) {
            resultText = response.text!.trim();
            break;
          }
        } catch (err) {
          lastError = err;
          continue;
        }
      }

      if (resultText != null) {
        setState(() {
          _isLoading = false;
          _aiResponseText = resultText!;
        });
      } else {
        throw lastError ?? Exception('ไม่สามารถเชื่อมต่อ AI ได้');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _aiResponseText = 'เกิดข้อผิดพลาดในการเชื่อมต่อ AI: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 24, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('KMITL Gemini AI Assistant 🤖', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'วิชาที่ต้องการถาม AI', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _callGeminiAPI('plan'),
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: const Text('วางแผนอ่านสอบ'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _callGeminiAPI('summary'),
                      icon: const Icon(Icons.tips_and_updates, size: 18),
                      label: const Text('สรุปเทคนิคจำ'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isLoading) const Center(child: CircularProgressIndicator(color: Colors.purple)),
              if (_aiResponseText.isNotEmpty && !_isLoading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(16)),
                  child: SelectableText(_aiResponseText),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- 2. BUDDY TAB (มีปุ่มย้อนกลับ & ระบบแชต Real-time) ----------------
class BuddyTab extends StatefulWidget {
  final String userSubject;
  final String currentUserName;
  final FirebaseFirestore firestore;
  final VoidCallback onBackToHome;

  const BuddyTab({
    super.key,
    required this.userSubject,
    required this.currentUserName,
    required this.firestore,
    required this.onBackToHome,
  });

  @override
  State<BuddyTab> createState() => _BuddyTabState();
}

class _BuddyTabState extends State<BuddyTab> {
  String _filter = 'ทั้งหมด';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: widget.onBackToHome, // ปุ่มย้อนกลับไปหน้าหลัก
                ),
                const Text('🤝 ค้นหา Study Buddy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Text('วิชาของคุณ: ${widget.userSubject}', style: const TextStyle(fontSize: 12, color: Color(0xFFFF5722), fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilterChip(
                  label: const Text('ทั้งหมด'),
                  selected: _filter == 'ทั้งหมด',
                  onSelected: (val) => setState(() => _filter = 'ทั้งหมด'),
                  selectedColor: const Color(0xFFFF5722),
                  labelStyle: TextStyle(color: _filter == 'ทั้งหมด' ? Colors.white : Colors.black87),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('ตรงวิชาฉัน ✨'),
                  selected: _filter == 'วิชาเดียวกับฉัน',
                  onSelected: (val) => setState(() => _filter = 'วิชาเดียวกับฉัน'),
                  selectedColor: const Color(0xFFFF5722),
                  labelStyle: TextStyle(color: _filter == 'วิชาเดียวกับฉัน' ? Colors.white : Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: widget.firestore.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final filtered = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    String subject = data['current_subject']?.toString() ?? '';
                    if (_filter == 'วิชาเดียวกับฉัน') {
                      return subject.toLowerCase().contains(widget.userSubject.toLowerCase());
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('ไม่พบรายชื่อเพื่อนติวในระบบ'));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index].data() as Map<String, dynamic>;
                      String name = item['username']?.toString() ?? item['full_name']?.toString() ?? 'นักศึกษา';
                      String faculty = item['faculty']?.toString() ?? 'ไม่ระบุคณะ';
                      String subject = item['current_subject']?.toString() ?? 'ไม่ระบุวิชา';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE8DCD5)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFFFCC80),
                              child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('@$name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(faculty, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFFFF0E6), borderRadius: BorderRadius.circular(6)),
                                    child: Text('📖 $subject', style: const TextStyle(fontSize: 10, color: Color(0xFFFF5722), fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                            // ปุ่มกดเพื่อเปิดหน้าต่างแชตจริง
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => ChatDialog(
                                    peerName: name,
                                    currentUserName: widget.currentUserName,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
                              child: const Text('ชวนติว (แชต)', style: TextStyle(fontSize: 12, color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 3. STUDY ROOM TAB (มีปุ่มย้อนกลับ & แจ้งเตือนเมื่อกดเข้าร่วม) ----------------
class StudyRoomTab extends StatelessWidget {
  final FirebaseFirestore firestore;
  final Function(String title, String subject, String location, int maxMembers) onCreateRoom;
  final VoidCallback onBackToHome;

  const StudyRoomTab({super.key, required this.firestore, required this.onCreateRoom, required this.onBackToHome});

  void _showCreateRoomModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final maxMembersCtrl = TextEditingController(text: '5');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('สร้างห้องติวกลุ่มใหม่ 🏫', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 14),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'หัวข้อห้องติว')),
            const SizedBox(height: 10),
            TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'ชื่อวิชา')),
            const SizedBox(height: 10),
            TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'สถานที่นัดเจอกัน')),
            const SizedBox(height: 10),
            TextField(controller: maxMembersCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'จำนวนคนที่รับ')),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    int maxCount = int.tryParse(maxMembersCtrl.text) ?? 5;
                    onCreateRoom(titleCtrl.text, subjectCtrl.text, locationCtrl.text, maxCount);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('เปิดห้องเลย!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinSuccessDialog(BuildContext context, Map<String, dynamic> room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 เข้าร่วมห้องติวสำเร็จ!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('หัวข้อ: ${room['title'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('วิชา: ${room['subject'] ?? ''}'),
            Text('สถานที่นัดพบ: 📍 ${room['location'] ?? ''}'),
            Text('ผู้สร้างห้อง: @${room['host_name'] ?? ''}'),
            const SizedBox(height: 12),
            const Text('ระบบบันทึกรายชื่อของคุณเข้ากลุ่มเรียบร้อยแล้ว!', style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('รับทราบ / ปิดหน้าต่าง', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: onBackToHome, // ปุ่มย้อนกลับ
                    ),
                    const Text('🏫 Study Rooms', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateRoomModal(context),
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('สร้างห้อง', style: TextStyle(fontSize: 12, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('study_rooms').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูลห้องติว'));
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) return const Center(child: Text('ยังไม่มีห้องติวในขณะนี้'));

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final room = doc.data() as Map<String, dynamic>;

                      int currentMembers = (room['current_members'] as num?)?.toInt() ?? 1;
                      int maxMembers = (room['max_members'] as num?)?.toInt() ?? 5;
                      bool isFull = currentMembers >= maxMembers;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE8DCD5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(room['title'] ?? 'ไม่มีชื่อห้อง', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('$currentMembers/$maxMembers คน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isFull ? Colors.red : Colors.black54)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('วิชา: ${room['subject'] ?? ''} · 📍 ${room['location'] ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: isFull
                                  ? null
                                  : () async {
                                      await firestore.collection('study_rooms').doc(doc.id).update({
                                        'current_members': FieldValue.increment(1),
                                      });
                                      if (context.mounted) {
                                        _showJoinSuccessDialog(context, room);
                                      }
                                    },
                              child: Text(isFull ? 'ห้องเต็มแล้ว' : 'ขอเข้าร่วมติว'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 4. MAP TAB (พิกัด KMITL มีปุ่มย้อนกลับ) ----------------
class MapTab extends StatelessWidget {
  final VoidCallback onBackToHome;
  const MapTab({super.key, required this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    final spots = [
      {'name': 'หอสมุดกลาง KMITL', 'facility': 'มีปลั๊กไฟทุกโต๊ะ · แอร์เย็นฉ่ำ · โซนอ่านเงียบสนิท', 'rating': '4.9 ⭐'},
      {'name': 'สำนักบริการคอมพิวเตอร์', 'facility': 'อินเทอร์เน็ตความเร็วสูง · เครื่องคอมพิวเตอร์พร้อมใช้งาน', 'rating': '4.7 ⭐'},
      {'name': 'โรงอาหาร HM (วิศวะ)', 'facility': 'มีร้านกาแฟ/ขนม · นั่งคุยงานกลุ่มสะดวกสบาย', 'rating': '4.5 ⭐'},
      {'name': 'ตึกพระเทพ (IT)', 'facility': 'Co-Working Space · ปลั๊กไฟแน่น · ที่นั่งกว้างขวาง', 'rating': '4.8 ⭐'},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: onBackToHome, // ปุ่มย้อนกลับ
                ),
                const Text('📍 พิกัดอ่านหนังสือ KMITL', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 48),
              child: Text('แนะนำสถานที่อ่านหนังสือและสิ่งอำนวยความสะดวกในสถาบัน', style: TextStyle(fontSize: 12, color: Colors.black45)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: spots.length,
                itemBuilder: (context, index) {
                  final s = spots[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8DCD5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: const Color(0xFFFFF0E6), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.location_on_rounded, color: Color(0xFFFF5722)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(s['rating']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(s['facility']!, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 5. REAL-TIME CHAT DIALOG (โต้ตอบส่งแชตได้จริง) ----------------
class ChatDialog extends StatefulWidget {
  final String peerName;
  final String currentUserName;

  const ChatDialog({
    super.key,
    required this.peerName,
    required this.currentUserName,
  });

  @override
  State<ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  final TextEditingController _msgController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // สร้าง Chat Room ID ที่ตรงกันสำหรับคู่สนทนาทั้งสองฝ่าย
  String get _chatRoomId {
    List<String> ids = [widget.currentUserName, widget.peerName]..sort();
    return ids.join('_');
  }

  // ฟังก์ชันส่งข้อความแชตลง Firestore
  void _sendMessage() async {
    String text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();

    await _firestore
        .collection('chats')
        .doc(_chatRoomId)
        .collection('messages')
        .add({
      'sender': widget.currentUserName,
      'text': text,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 450,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFFF5722),
                      radius: 16,
                      child: Text(
                        widget.peerName.isNotEmpty ? widget.peerName[0] : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'แชตกับ @${widget.peerName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),

            // สตรีมดึงข้อความแชตแบบ Real-time
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .doc(_chatRoomId)
                    .collection('messages')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('ยังไม่มีข้อความ ทักทายเพื่อนชวนติวได้เลย! 👋', style: TextStyle(color: Colors.black45, fontSize: 12)),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      bool isMe = data['sender'] == widget.currentUserName;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFFFF5722) : const Color(0xFFF1F1F1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            data['text'] ?? '',
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // ช่องกรอกข้อความและปุ่มส่ง
            Padding(
              padding: const EdgeInsets.only(top: 8.0), // แก้ไขเป็น EdgeInsets.only เรียบร้อยครับ
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: 'พิมพ์ข้อความ...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: Color(0xFFFF5722)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}