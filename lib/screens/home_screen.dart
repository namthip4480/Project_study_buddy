import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late String _displayName;
  String _currentFaculty = 'คณะเทคโนโลยีสารสนเทศ';
  String _currentSubject = 'Business Management';

  // Timer States (ระบบ Count-down)
  bool _isStudying = false;
  int _remainingSeconds = 60; // ค่าเริ่มต้น 1 นาที
  int _targetMinutes = 1;
  Timer? _timer;

  // Real-time Mock Data
  final List<Map<String, dynamic>> _buddies = [
    {
      'name': 'น้องน้ำชา 🍵',
      'faculty': 'คณะเทคโนโลยีสารสนเทศ',
      'subject': 'Business Management',
      'status': 'กำลังอ่านอยู่',
      'avatarColor': const Color(0xFFFFCC80),
      'isOnline': true,
    },
    {
      'name': 'พี่ต้นกล้า 💻',
      'faculty': 'คณะวิศวกรรมศาสตร์',
      'subject': 'Calculus II',
      'status': 'หาเพื่อนติวกลุ่ม',
      'avatarColor': const Color(0xFF90CAF9),
      'isOnline': true,
    },
    {
      'name': 'ฟ้าใส ✨',
      'faculty': 'คณะบริหารธุรกิจ',
      'subject': 'Marketing 101',
      'status': 'กำลังอ่านอยู่',
      'avatarColor': const Color(0xFFF48FB1),
      'isOnline': false,
    },
  ];

  final List<Map<String, dynamic>> _studyRooms = [
    {
      'title': 'ติวเตรียมสอบ Business Midterm 📚',
      'subject': 'Business Management',
      'location': 'หอสมุดกลาง ชั้น 3',
      'currentMembers': 3,
      'maxMembers': 5,
      'host': 'พี่หมูเด้ง',
      'tag': 'ด่วน! ต้องการอีก 2 คน',
      'requested': false,
    },
    {
      'title': 'ลุยโจทย์ Calc 2 คณะวิศวะ 📐',
      'subject': 'Calculus II',
      'location': 'ตึก HM วิศวะ',
      'currentMembers': 4,
      'maxMembers': 6,
      'host': 'ก้อง วิศวะ',
      'tag': 'สายโหด',
      'requested': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _displayName = widget.userName;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _displayName = prefs.getString('user_name') ?? widget.userName;
      _currentFaculty = prefs.getString('user_faculty') ?? 'คณะเทคโนโลยีสารสนเทศ';
      _currentSubject = prefs.getString('user_subject') ?? 'Business Management';
    });
  }

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
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isStudying = false;
          _remainingSeconds = _targetMinutes * 60;
        });

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

  void _resumeTimer() {
    _timer?.cancel();
    setState(() => _isStudying = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isStudying = false;
          _remainingSeconds = _targetMinutes * 60;
        });

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

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isStudying = false);
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isStudying = false;
      _remainingSeconds = _targetMinutes * 60;
    });
  }

  String _formatTime(int sec) {
    int m = sec ~/ 60;
    int s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _addStudyRoom(String title, String subject, String location, int maxMembers) {
    setState(() {
      _studyRooms.insert(0, {
        'title': title,
        'subject': subject,
        'location': location,
        'currentMembers': 1,
        'maxMembers': maxMembers,
        'host': _displayName,
        'tag': 'สร้างใหม่',
        'requested': false,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
      BuddyTab(userSubject: _currentSubject, buddies: _buddies),
      StudyRoomTab(rooms: _studyRooms, onCreateRoom: _addStudyRoom),
      const MapTab(),
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
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), activeIcon: Icon(Icons.grid_view_rounded), label: 'หน้าหลัก'),
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

// ---------------------------------------------------------
// 1. HOME TAB - DASHBOARD (ตัดพิกัดออกจากตัวจับเวลาแล้ว)
// ---------------------------------------------------------
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

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF7043), Color(0xFFFF5722)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF5722).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🎓', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('STUDY BUDDY KMITL', style: TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1)),
                          Text('สวัสดี, $displayName 👋', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C)), overflow: TextOverflow.ellipsis),
                          Text(currentFaculty, style: const TextStyle(fontSize: 11, color: Colors.black54), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE8DCD5)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF3ED), Color(0xFFFDE8DE)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'ขณะนี้มีเพื่อนๆ KMITL กำลังอ่านหนังสืออยู่ 42 คน 🚀',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D4037)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ตัวจับเวลา (โฟกัสเฉพาะวิชา + เวลา)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: isStudying ? const Color(0xFFFF5722).withOpacity(0.5) : const Color(0xFFE8DCD5)),
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
                Text(currentSubject, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
                const SizedBox(height: 16),

                Center(
                  child: Text(
                    formatTime(remainingSeconds),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: isStudying ? const Color(0xFFFF5722) : const Color(0xFFBDBDBD),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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
                              builder: (ctx) => StartStudyModal(onStart: onStartStudy),
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
          const SizedBox(height: 28),

          const Text('ฟีเจอร์ยอดฮิต ⚡', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildFeatureCard('หา Buddy ติว', 'แมตช์เพื่อนอ่านวิชาเดียวกัน', Icons.person_search_rounded, const Color(0xFFFFE0B2), () => onNavigateTab(1)),
              _buildFeatureCard('Study Room', 'เข้าร่วมกลุ่มอ่านหนังสือ', Icons.groups_rounded, const Color(0xFFC8E6C9), () => onNavigateTab(2)),
              _buildFeatureCard('พิกัด KMITL', 'เช็คสถานที่และสิ่งอำนวยความสะดวก', Icons.pin_drop_rounded, const Color(0xFFBBDEFB), () => onNavigateTab(3)),
              _buildFeatureCard('แก้ไขโปรไฟล์', 'ตั้งค่าคณะ/วิชาที่อ่าน', Icons.badge_rounded, const Color(0xFFE1BEE7), () => onNavigateTab(4)),
            ],
          ),
          const SizedBox(height: 16),

          // Banner Gemini AI
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E24AA), Color(0xFF5E35B1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openAIAssistant(context),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'AI ผู้ช่วยติวหนังสือ',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amberAccent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('GEMINI AI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'คลิกเพื่อวางแผนการอ่าน & สรุปบทเรียนด้วย Gemini AI',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
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

  void _openAIAssistant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AIAssistantModal(currentSubject: currentSubject),
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

// ---------------------------------------------------------
// 2. BUDDY TAB - MATCHING SYSTEM
// ---------------------------------------------------------
class BuddyTab extends StatefulWidget {
  final String userSubject;
  final List<Map<String, dynamic>> buddies;
  const BuddyTab({super.key, required this.userSubject, required this.buddies});

  @override
  State<BuddyTab> createState() => _BuddyTabState();
}

class _BuddyTabState extends State<BuddyTab> {
  String _filter = 'ทั้งหมด';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.buddies.where((b) {
      if (_filter == 'วิชาเดียวกับฉัน') {
        return b['subject'].toString().toLowerCase().contains(widget.userSubject.toLowerCase());
      }
      return true;
    }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🤝 ค้นหา Study Buddy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('กำลังอ่านวิชา: ${widget.userSubject}', style: const TextStyle(fontSize: 12, color: Color(0xFFFF5722), fontWeight: FontWeight.w600)),
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
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.sentiment_dissatisfied_rounded, size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text('ยังไม่มีเพื่อนที่อ่านวิชา "${widget.userSubject}" ในขณะนี้'),
                          const SizedBox(height: 4),
                          const Text('ลองเปลี่ยนฟิลเตอร์หรือลองชวนเพื่อนๆ ดูสิ!', style: TextStyle(fontSize: 11, color: Colors.black45)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
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
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: item['avatarColor'],
                                    child: Text(item['name'][0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                                  ),
                                  if (item['isOnline'])
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text('${item['faculty']}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: const Color(0xFFFFF0E6), borderRadius: BorderRadius.circular(6)),
                                      child: Text('📖 ${item['subject']}', style: const TextStyle(fontSize: 10, color: Color(0xFFFF5722), fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ส่งข้อความทักทายหา ${item['name']} แล้ว!')));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5722),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('ชวนติว', style: TextStyle(fontSize: 12, color: Colors.white)),
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

// ---------------------------------------------------------
// 3. STUDY ROOM TAB - ROOM CREATION & REQUEST JOIN (พร้อมช่องจำนวนคน)
// ---------------------------------------------------------
class StudyRoomTab extends StatefulWidget {
  final List<Map<String, dynamic>> rooms;
  final Function(String title, String subject, String location, int maxMembers) onCreateRoom;

  const StudyRoomTab({super.key, required this.rooms, required this.onCreateRoom});

  @override
  State<StudyRoomTab> createState() => _StudyRoomTabState();
}

class _StudyRoomTabState extends State<StudyRoomTab> {
  void _showCreateRoomModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final maxMembersCtrl = TextEditingController(text: '5'); // ช่องใส่จำนวนคน

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
            const Text('สร้างห้องติวกลุ่มใหม่ 🏫', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'หัวข้อห้องติว (เช่น ติวแคล 2 ก่อนสอบ)')),
            const SizedBox(height: 10),
            TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'ชื่อวิชา')),
            const SizedBox(height: 10),
            TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'สถานที่นัดเจอกัน')),
            const SizedBox(height: 10),
            TextField(
              controller: maxMembersCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'จำนวนคนที่ต้องการรับ (คน)'),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    int maxCount = int.tryParse(maxMembersCtrl.text) ?? 5;
                    widget.onCreateRoom(titleCtrl.text, subjectCtrl.text, locationCtrl.text, maxCount);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เปิดห้องติวกลุ่มสำเร็จ!')));
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🏫 Study Rooms', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('รวมกลุ่มติวกับเพื่อนๆ ใน KMITL', style: TextStyle(fontSize: 12, color: Colors.black45)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateRoomModal(context),
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('สร้างห้อง', style: TextStyle(fontSize: 12, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5722),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.rooms.length,
                itemBuilder: (context, index) {
                  final room = widget.rooms[index];
                  bool isFull = room['currentMembers'] >= room['maxMembers'];
                  bool isRequested = room['requested'] ?? false;

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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFFFFF0E6), borderRadius: BorderRadius.circular(6)),
                              child: Text(room['tag'], style: const TextStyle(fontSize: 10, color: Color(0xFFFF5722), fontWeight: FontWeight.bold)),
                            ),
                            Text('${room['currentMembers']}/${room['maxMembers']} คน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isFull ? Colors.red : Colors.black54)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(room['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('วิชา: ${room['subject']} · 📍 ${room['location']}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('โดย ${room['host']}', style: const TextStyle(fontSize: 11, color: Colors.black45)),
                            OutlinedButton(
                              onPressed: isFull || isRequested
                                  ? null
                                  : () {
                                      setState(() {
                                        room['requested'] = true;
                                        room['currentMembers']++;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ส่งคำขอเข้าร่วมห้อง "${room['title']}" แล้ว!')));
                                    },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: isRequested ? Colors.green : (isFull ? Colors.grey : const Color(0xFFFF5722))),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                isRequested ? 'ส่งคำขอแล้ว ⏳' : (isFull ? 'ห้องเต็มแล้ว' : 'ขอเข้าร่วมติว'),
                                style: TextStyle(color: isRequested ? Colors.green : (isFull ? Colors.grey : const Color(0xFFFF5722)), fontSize: 12),
                              ),
                            ),
                          ],
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

// ---------------------------------------------------------
// 4. MAP TAB - KMITL HOTSPOTS (เวอร์ชันคลีน ไม่มีสถานะคนแน่น/น้อย)
// ---------------------------------------------------------
class MapTab extends StatelessWidget {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context) {
    final spots = [
      {
        'name': 'หอสมุดกลาง KMITL',
        'facility': 'มีปลั๊กไฟทุกโต๊ะ · แอร์เย็นฉ่ำ · โซนอ่านเงียบสนิท',
        'rating': '4.9 ⭐',
      },
      {
        'name': 'สำนักบริการคอมพิวเตอร์',
        'facility': 'อินเทอร์เน็ตความเร็วสูง · เครื่องคอมพิวเตอร์พร้อมใช้งาน',
        'rating': '4.7 ⭐',
      },
      {
        'name': 'โรงอาหาร HM (วิศวะ)',
        'facility': 'มีร้านกาแฟ/ขนม · นั่งคุยงานกลุ่มสะดวกสบาย',
        'rating': '4.5 ⭐',
      },
      {
        'name': 'ตึกพระเทพ (IT)',
        'facility': 'Co-Working Space · ปลั๊กไฟแน่น · ที่นั่งกว้างขวาง',
        'rating': '4.8 ⭐',
      },
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📍 พิกัดอ่านหนังสือ KMITL', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('แนะนำสถานที่อ่านหนังสือและสิ่งอำนวยความสะดวกในสถาบัน', style: TextStyle(fontSize: 12, color: Colors.black45)),
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

// Modal ตั้งค่าเริ่มอ่าน
class StartStudyModal extends StatefulWidget {
  final Function(String subject, int mins) onStart;
  const StartStudyModal({super.key, required this.onStart});

  @override
  State<StartStudyModal> createState() => _StartStudyModalState();
}

class _StartStudyModalState extends State<StartStudyModal> {
  String _subject = 'Business Management';
  final _minsController = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('เริ่มจับเวลาอ่านหนังสือ 🔥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          TextField(
            controller: TextEditingController(text: _subject),
            onChanged: (v) => _subject = v,
            decoration: const InputDecoration(labelText: 'วิชาที่จะอ่าน'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _minsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'ตั้งใจอ่านกี่นาที?'),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
              onPressed: () {
                int mins = int.tryParse(_minsController.text) ?? 1;
                widget.onStart(_subject, mins);
                Navigator.pop(context);
              },
              child: const Text('ลุยเลย!', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// AI STUDY ASSISTANT MODAL (GEMINI AI)
// =========================================================
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
      if (mounted) {
        setState(() {
          _apiKey = savedKey.trim();
        });
      }
    }
  }

  void _showApiKeyDialog() {
    final keyController = TextEditingController(
      text: _apiKey == _defaultApiKey ? '' : _apiKey,
    );
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.vpn_key_rounded, color: Colors.purple),
            SizedBox(width: 8),
            Text('ตั้งค่า Gemini API Key', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _apiKey == _defaultApiKey
                  ? 'สถานะ: ใช้ API Key เริ่มต้นของระบบ (ใช้งานได้ทันที)'
                  : 'สถานะ: กำลังใช้ API Key ที่คุณระบุเอง',
              style: TextStyle(
                fontSize: 12,
                color: _apiKey == _defaultApiKey ? Colors.green.shade700 : Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              decoration: InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'วางคีย์ AIzaSy... หรือเว้นว่างเพื่อใช้คีย์ระบบ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'รับ API Key ฟรีได้จาก Google AI Studio (aistudio.google.com)',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('custom_gemini_api_key');
              if (!mounted) return;
              setState(() {
                _apiKey = _defaultApiKey;
              });
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('รีเซ็ตกลับเป็น API Key ระบบเรียบร้อยแล้ว')),
              );
            },
            child: const Text('ใช้คีย์ระบบ', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () async {
              final newKey = keyController.text.trim();
              final prefs = await SharedPreferences.getInstance();
              if (newKey.isNotEmpty) {
                await prefs.setString('custom_gemini_api_key', newKey);
              } else {
                await prefs.remove('custom_gemini_api_key');
              }
              if (!mounted) return;
              setState(() {
                _apiKey = newKey.isNotEmpty ? newKey : _defaultApiKey;
              });
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('บันทึก API Key สำเร็จ')),
              );
            },
            child: const Text('บันทึก', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _callGeminiAPI(String promptType) async {
    final subject = _subjectController.text.trim().isEmpty ? widget.currentSubject : _subjectController.text.trim();

    setState(() {
      _isLoading = true;
      _aiResponseText = '';
    });

    final apiKeyToUse = _apiKey.trim().isNotEmpty ? _apiKey.trim() : _defaultApiKey;

    try {
      if (apiKeyToUse == 'YOUR_GEMINI_API_KEY_HERE') {
        await Future.delayed(const Duration(milliseconds: 900));
        setState(() {
          _isLoading = false;
          if (promptType == 'plan') {
            _aiResponseText = '📌 แผนอ่านสอบวิชา $subject สไตล์ KMITL:\n'
                '• วันที่ 1: สรุปนิยามและ Keyword หลัก\n'
                '• วันที่ 2: ทำโจทย์ข้อสอบเก่าย้อนหลัง 5 ปี\n'
                '• วันที่ 3: จับกลุ่มติวกับเพื่อนที่หอสมุดกลาง ชั้น 3';
          } else {
            _aiResponseText = '💡 เทคนิคจำแม่นวิชา $subject:\n'
                '• ใช้เทคนิค Pomodoro 25/5 นาที\n'
                '• วาด Mind Mapping สรุปภาพรวมก่อนสอบ\n'
                '• เน้นประเด็นสำคัญที่อาจารย์เน้นย้ำในห้องเรียน';
          }
        });
        return;
      }

      final prompt = promptType == 'plan'
          ? 'ช่วยจัดตารางและแผนการอ่านหนังสือสอบวิชา $subject สำหรับนักศึกษามหาวิทยาลัยแบบสั้นกระชับ เป็นข้อๆ'
          : 'ช่วยสรุปเทคนิคการอ่านและจดจำเนื้อหาวิชา $subject ให้สอบผ่านได้เกรด A แบบสั้นกระชับ เป็นข้อๆ';

      final candidateModels = [
        'gemini-2.5-flash',
        'gemini-3.5-flash-lite',
        'gemini-flash-latest',
        'gemini-1.5-flash',
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
        throw lastError ?? Exception('ไม่สามารถเชื่อมต่อโมเดล AI ได้');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _aiResponseText = 'เกิดข้อผิดพลาดในการเชื่อมต่อ AI: $e\n\n💡 คำแนะนำ: หาก API Key ติดปัญหาหรือหมดโควต้า คุณสามารถกดปุ่มรูปกุญแจ 🔑 ด้านบนเพื่อเปลี่ยนหรือกรอก API Key ใหม่ได้ครับ';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
                    child: const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('KMITL Gemini AI Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('ประมวลผลคำตอบด้วย Gemini API จริง', style: TextStyle(fontSize: 11, color: Colors.black45)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.vpn_key_rounded, color: Colors.purple),
                    tooltip: 'ตั้งค่า / เปลี่ยน Gemini API Key',
                    onPressed: _showApiKeyDialog,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'วิชาหรือหัวข้อที่ต้องการถาม AI',
                  hintText: 'เช่น Calculus, Physics, Programming, Business',
                  prefixIcon: const Icon(Icons.book_rounded, color: Colors.purple),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _callGeminiAPI('plan'),
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: const Text('วางแผนอ่านสอบ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _callGeminiAPI('summary'),
                      icon: const Icon(Icons.tips_and_updates, size: 18, color: Colors.purple),
                      label: const Text('สรุปเทคนิคจำ', style: TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.purple, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: Colors.purple),
                        SizedBox(height: 12),
                        Text('กำลังส่งข้อมูลประมวลผลด้วย Gemini AI...', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                ),

              if (_aiResponseText.isNotEmpty && !_isLoading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: SelectableText(
                    _aiResponseText,
                    style: const TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF37474F)),
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================
// 5. PROFILE SCREEN
// =========================================================
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
        : _faculties[5];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

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
        content: Text('บันทึกข้อมูลโปรไฟล์เรียบร้อยแล้ว! ✨'),
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