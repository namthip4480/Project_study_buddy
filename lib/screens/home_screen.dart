import 'dart:async';
import 'package:flutter/material.dart';
import 'profile_screen.dart';

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

  // Timer States
  bool _isStudying = false;
  int _secondsRead = 0;
  Timer? _timer;
  String _studyLocation = 'หอสมุดกลาง KMITL';
  int _targetMinutes = 45;

  // Real-time Data Store
  final List<Map<String, dynamic>> _buddies = [
    {
      'name': 'น้องน้ำชา 🍵',
      'faculty': 'คณะเทคโนโลยีสารสนเทศ',
      'subject': 'Business Management',
      'location': 'หอสมุดกลาง ชั้น 2',
      'status': 'กำลังอ่านอยู่',
      'avatarColor': const Color(0xFFFFCC80),
      'isOnline': true,
    },
    {
      'name': 'พี่ต้นกล้า 💻',
      'faculty': 'คณะวิศวกรรมศาสตร์',
      'subject': 'Calculus II',
      'location': 'สำนักคอมพิวเตอร์',
      'status': 'หาเพื่อนติวกลุ่ม',
      'avatarColor': const Color(0xFF90CAF9),
      'isOnline': true,
    },
    {
      'name': 'ฟ้าใส ✨',
      'faculty': 'คณะบริหารธุรกิจ',
      'subject': 'Marketing 101',
      'location': 'HM คณะวิศวะ',
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
    },
    {
      'title': 'ลุยโจทย์ Calc 2 คณะวิศวะ 📐',
      'subject': 'Calculus II',
      'location': 'ตึก HM วิศวะ',
      'currentMembers': 4,
      'maxMembers': 6,
      'host': 'ก้อง วิศวะ',
      'tag': 'สายโหด',
    },
  ];

  @override
  void initState() {
    super.initState();
    _displayName = widget.userName;
  }

  void _startTimer(String subject, String location, int targetMins) {
    _timer?.cancel();
    setState(() {
      _currentSubject = subject;
      _studyLocation = location;
      _targetMinutes = targetMins;
      _isStudying = true;
      _secondsRead = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsRead++);
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
      _secondsRead = 0;
    });
  }

  String _formatTime(int sec) {
    int m = sec ~/ 60;
    int s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _addStudyRoom(String title, String subject, String location) {
    setState(() {
      _studyRooms.insert(0, {
        'title': title,
        'subject': subject,
        'location': location,
        'currentMembers': 1,
        'maxMembers': 5,
        'host': _displayName,
        'tag': 'สร้างใหม่',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeTab(
        displayName: _displayName,
        currentSubject: _currentSubject,
        studyLocation: _studyLocation,
        targetMinutes: _targetMinutes,
        isStudying: _isStudying,
        secondsRead: _secondsRead,
        formatTime: _formatTime,
        onStartStudy: _startTimer,
        onPause: _pauseTimer,
        onStop: _stopTimer,
        onNavigateTab: (index) => setState(() => _selectedIndex = index),
      ),
      BuddyTab(userSubject: _currentSubject, buddies: _buddies),
      StudyRoomTab(rooms: _studyRooms, onCreateRoom: _addStudyRoom),
      const MapTab(),
      ProfileScreen(
        currentName: _displayName,
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
// 1. HOME TAB - MODERN DASHBOARD
// ---------------------------------------------------------
class HomeTab extends StatelessWidget {
  final String displayName;
  final String currentSubject;
  final String studyLocation;
  final int targetMinutes;
  final bool isStudying;
  final int secondsRead;
  final String Function(int) formatTime;
  final Function(String, String, int) onStartStudy;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final Function(int) onNavigateTab;

  const HomeTab({
    super.key,
    required this.displayName,
    required this.currentSubject,
    required this.studyLocation,
    required this.targetMinutes,
    required this.isStudying,
    required this.secondsRead,
    required this.formatTime,
    required this.onStartStudy,
    required this.onPause,
    required this.onStop,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('STUDY BUDDY KMITL', style: TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1)),
                      Text('สวัสดี, $displayName 👋', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
                    ],
                  ),
                ],
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
                Text('📍 $studyLocation', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 16),

                Center(
                  child: Text(
                    formatTime(secondsRead),
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
                          } else if (secondsRead > 0) {
                            onPause();
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
                          isStudying ? 'พักชั่วคราว' : (secondsRead > 0 ? 'อ่านต่อ' : 'เริ่มอ่านเลย! 🔥'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                    if (secondsRead > 0) ...[
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: onStop,
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
              _buildFeatureCard('พิกัด KMITL', 'เช็คที่นั่งว่าง ปลั๊กไฟ', Icons.pin_drop_rounded, const Color(0xFFBBDEFB), () => onNavigateTab(3)),
              _buildFeatureCard('แก้ไขโปรไฟล์', 'ตั้งค่าคณะ/วิชาที่อ่าน', Icons.badge_rounded, const Color(0xFFE1BEE7), () => onNavigateTab(4)),
            ],
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
                                      child: Text('📖 ${item['subject']} · 📍 ${item['location']}', style: const TextStyle(fontSize: 10, color: Color(0xFFFF5722), fontWeight: FontWeight.bold)),
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
                                child: const Text('ชวนติว', style: TextStyle(fontSize: 12)),
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
// 3. STUDY ROOM TAB - ROOM CREATION & JOINING
// ---------------------------------------------------------
class StudyRoomTab extends StatelessWidget {
  final List<Map<String, dynamic>> rooms;
  final Function(String title, String subject, String location) onCreateRoom;

  const StudyRoomTab({super.key, required this.rooms, required this.onCreateRoom});

  void _showCreateRoomModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final locationCtrl = TextEditingController();

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
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    onCreateRoom(titleCtrl.text, subjectCtrl.text, locationCtrl.text);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เปิดห้องติวกลุ่มสำเร็จ!')));
                  }
                },
                child: const Text('เปิดห้องเลย!'),
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
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('สร้างห้อง', style: TextStyle(fontSize: 12)),
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
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
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
                            Text('${room['currentMembers']}/${room['maxMembers']} คน', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
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
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เข้าร่วมห้อง "${room['title']}" เรียบร้อย!')));
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFFF5722)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('จองที่นั่งร่วมติว', style: TextStyle(color: Color(0xFFFF5722), fontSize: 12)),
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
// 4. MAP TAB - KMITL HOTSPOTS
// ---------------------------------------------------------
class MapTab extends StatelessWidget {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context) {
    final spots = [
      {
        'name': 'หอสมุดกลาง KMITL',
        'status': '🟢 ว่างเยอะ',
        'facility': 'มีปลั๊กไฟทุกโต๊ะ · แอร์เย็น · โซนเงียบสนิท',
        'rating': '4.9 ⭐',
      },
      {
        'name': 'สำนักบริการคอมพิวเตอร์',
        'status': '🟡 ปานกลาง',
        'facility': 'อินเทอร์เน็ตความเร็วสูง · เครื่องคอมพิวเตอร์พร้อม',
        'rating': '4.7 ⭐',
      },
      {
        'name': 'โรงอาหาร HM (วิศวะ)',
        'status': '🔴 คนแน่น',
        'facility': 'มีร้านกาแฟ/ขนม · คุยงานกลุ่มสะดวก',
        'rating': '4.5 ⭐',
      },
      {
        'name': 'ตึกพระเทพ (IT)',
        'status': '🟢 ว่าง',
        'facility': 'Co-Working Space · ปลั๊กไฟแน่น',
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
            const Text('เช็คสถานะที่นั่งและสิ่งอำนวยความสะดวกแบบ Real-time', style: TextStyle(fontSize: 12, color: Colors.black45)),
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
                              Text(s['status']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(s['facility']!, style: const TextStyle(fontSize: 10, color: Colors.black54)),
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
  final Function(String subject, String location, int mins) onStart;
  const StartStudyModal({super.key, required this.onStart});

  @override
  State<StartStudyModal> createState() => _StartStudyModalState();
}

class _StartStudyModalState extends State<StartStudyModal> {
  String _subject = 'Business Management';
  String _location = 'หอสมุดกลาง KMITL';
  final _minsController = TextEditingController(text: '45');

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
              onPressed: () {
                int mins = int.tryParse(_minsController.text) ?? 45;
                widget.onStart(_subject, _location, mins);
                Navigator.pop(context);
              },
              child: const Text('ลุยเลย!'),
            ),
          ),
        ],
      ),
    );
  }
}