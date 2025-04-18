import 'package:do_an_lt/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
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
    final selectedDayName = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(_selectedDay);

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
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
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
                    color: blue.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: blue,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Nửa dưới: Hiển thị các item lịch tập
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Text(
                        'Danh sách lịch tập - $selectedDayName',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (classesForSelectedDay.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.fitness_center,
                                size: 60,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Bạn không có lịch tập vào $selectedDayName',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: classesForSelectedDay.length,
                          itemBuilder: (context, index) {
                            final cls = classesForSelectedDay[index];
                            final timeParts = cls['time'].split(' - ');
                            final days = timeParts[0];
                            final time = timeParts.length > 1 ? timeParts[1] : '';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    // Xử lý khi nhấn vào item
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        // Hình ảnh lớp học
                                        Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: NetworkImage(cls['imageUrl']),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Thông tin lớp học
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cls['name'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 16,
                                                    color: blue,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    time,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 16,
                                                    color: blue,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      cls['location'],
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[700],
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Icon mũi tên
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey[400],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}