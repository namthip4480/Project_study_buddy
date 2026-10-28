import 'dart:async';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/study_session.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  final TextEditingController _subjectController =
      TextEditingController(text: 'อ่านเตรียมสอบ KMITL');

  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds++);
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() => _seconds = 0);
  }

  Future<void> _saveSession() async {
    if (_seconds == 0) return;
    final minutes = (_seconds / 60).ceil();
    final newSession = StudySession(
      subject: _subjectController.text,
      durationMinutes: minutes,
      date: DateTime.now().toString().split(' ')[0],
    );

    await DatabaseHelper.instance.insertSession(newSession);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึกเวลาอ่านหนังสือเรียบร้อย ($minutes นาที)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _resetTimer();
    }
  }

  String _formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final mins = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$mins:$secs';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Timer')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'หัวข้อ/วิชาที่กำลังอ่าน',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Center(
                child: Text(
                  _formatTime(_seconds),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? 'พัก' : 'เริ่ม'),
                ),
                OutlinedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  label: const Text('รีเซ็ต'),
                ),
                FilledButton.icon(
                  onPressed: _seconds > 0 ? _saveSession : null,
                  icon: const Icon(Icons.save),
                  label: const Text('บันทึก'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 