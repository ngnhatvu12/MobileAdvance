import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ScheduleWidget extends StatefulWidget {
  @override
  _ScheduleWidgetState createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  List<Map<String, dynamic>> _todaySchedules = [];

  @override
  void initState() {
    super.initState();
    _fetchTodaySchedules();
  }

  void _fetchTodaySchedules() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final todayWeekday = _getCurrentWeekday();
    final snapshot = await FirebaseFirestore.instance.collection('class').get();

    List<Map<String, dynamic>> todaySchedules = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final members = List<String>.from(data['members'] ?? []);
      final time = data['time'] as String? ?? '';
      final name = data['name'] as String? ?? '';
      final location = data['location'] as String? ?? '';
      final benefits = data['benefits'] as String? ?? '';

      if (members.contains(user.uid) && _doesTimeContainWeekday(time, todayWeekday)) {
        final scheduleTime = _extractTime(time);
        todaySchedules.add({
          'name': name,
          'time': scheduleTime,
          'location': location,
          'benefits': benefits,
        });
      }
    }

    setState(() {
      _todaySchedules = todaySchedules;
    });
  }

  String _getCurrentWeekday() {
    final now = DateTime.now();
    const weekdays = ['Hai', 'Ba', 'Tư', 'Năm', 'Sáu', 'Bảy', 'Chủ Nhật'];
    return weekdays[now.weekday - 1];
  }

  bool _doesTimeContainWeekday(String time, String weekday) {
    return time.contains(weekday);
  }

  String _extractTime(String time) {
    final regex = RegExp(r'- (.*)');
    final match = regex.firstMatch(time);
    return match?.group(1)?.trim() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lịch tập hôm nay',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _todaySchedules.isEmpty
            ? const Text(
                'Hôm nay bạn không có sự kiện nào.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              )
            : Column(
                children: _todaySchedules.map((schedule) {
                  return Card(
                    color: Colors.blue.shade50,
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 18, color: Colors.blue),
                              const SizedBox(width: 5),
                              Text(
                                schedule['time'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 20, color: Colors.red),
                              const SizedBox(width: 5),
                              Text(
                                schedule['location'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            schedule['benefits'],
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }
}
