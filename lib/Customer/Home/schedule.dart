import 'package:do_an_lt/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Thêm dòng này
import 'package:table_calendar/table_calendar.dart';

class MyTrainingSchedulePage extends StatefulWidget {
  const MyTrainingSchedulePage({Key? key}) : super(key: key);

  @override
  _MyTrainingSchedulePageState createState() => _MyTrainingSchedulePageState();
}

class _MyTrainingSchedulePageState extends State<MyTrainingSchedulePage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _classes = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo locale cho tiếng Việt
    initializeDateFormatting('vi_VN', null).then((_) {
      _fetchClasses();
    });
  }

  Future<void> _fetchClasses() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore.collection('class').get();
    print('🔥 Dữ liệu từ Firestore (${snapshot.docs.length} lớp học):');

    final classes = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final members = List<String>.from(data['members'] ?? []);
      final containsUser = members.contains(user.uid);
      return containsUser;
    }).toList();

    setState(() {
      _classes = classes.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  List<Map<String, dynamic>> _getClassesForSelectedDay() {
    final selectedDayName = DateFormat('EEEE', 'vi_VN').format(_selectedDay).toLowerCase();
    final Map<String, String> dayMap = {
      'thứ hai': 'Hai',
      'thứ ba': 'Ba',
      'thứ tư': 'Tư',
      'thứ năm': 'Năm',
      'thứ sáu': 'Sáu',
      'thứ bảy': 'Bảy',
      'chủ nhật': 'CN',
    };
    final selectedDayShort = dayMap[selectedDayName] ?? '';

    print('📅 Ngày được chọn: $_selectedDay ($selectedDayShort)');

    final filteredClasses = _classes.where((cls) {
      try {
        final startDate = DateFormat('dd/MM/yyyy').parse(cls['startDate']);
        final endDate = DateFormat('dd/MM/yyyy').parse(cls['endDate']);
        final time = cls['time'] as String;
        final days = time.split(' - ')[0].split(', ').map((e) => e.trim()).toList();

        final isWithinDateRange = _selectedDay.isAfter(startDate.subtract(const Duration(days: 1))) &&
                                  _selectedDay.isBefore(endDate.add(const Duration(days: 1)));

        final isDayMatch = days.contains(selectedDayShort);

        return isWithinDateRange && isDayMatch;
      } catch (e) {
        return false;
      }
    }).toList();

    return filteredClasses;
  }

  @override
  Widget build(BuildContext context) {
    final classesForSelectedDay = _getClassesForSelectedDay();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [blue, Colors.black],
          ),
        ),
        child: Column(
          children: [
            // Phần header với nút trở lại và tiêu đề
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30,),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Lịch tập của tôi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Nửa trên: Hiển thị lịch
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
            // Nửa dưới: Hiển thị các item lịch tập hoặc thông báo không có lịch tập
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: classesForSelectedDay.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 60,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Hôm nay bạn không có lịch tập nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: classesForSelectedDay.length,
                        itemBuilder: (context, index) {
                          final cls = classesForSelectedDay[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    cls['imageUrl'],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cls['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        cls['time'].split(' - ')[1],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        cls['location'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}