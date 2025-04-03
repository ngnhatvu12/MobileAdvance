import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CoachSchedulePage extends StatefulWidget {
  final String coachId;

  const CoachSchedulePage({super.key, required this.coachId});

  @override
  _CoachSchedulePageState createState() => _CoachSchedulePageState();
}

class _CoachSchedulePageState extends State<CoachSchedulePage> {
  DateTime _selectedDate = DateTime.now();
  final PageController _pageController = PageController(initialPage: 7);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(7); // Scroll đến ngày hiện tại
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<List<QueryDocumentSnapshot>> _getClassesByDate(DateTime date) async {
  final dayOfWeek = DateFormat('EEEE').format(date).substring(0, 3);
  final formattedDate = DateFormat('MM/dd/yyyy').format(date);
  final query = await FirebaseFirestore.instance
      .collection('class')
      .where('coachId', isEqualTo: widget.coachId)
      .get();
  return query.docs.where((doc) {
    final data = doc.data() as Map<String, dynamic>;
    final startDate = data['startDate'] as String;
    final endDate = data['endDate'] as String;
    final timeStr = data['time'] as String;
    final days = timeStr.split(' - ')[0].split(', ');
    final currentDate = DateFormat('dd/MM/yyyy').parse(DateFormat('dd/MM/yyyy').format(date));
    final start = DateFormat('dd/MM/yyyy').parse(startDate);
    final end = DateFormat('dd/MM/yyyy').parse(endDate);

    final isWithinDateRange = currentDate.isAfter(start.subtract(const Duration(days: 1))) &&
                              currentDate.isBefore(end.add(const Duration(days: 1)));
    final isMatchingDay = days.any((day) => _convertDayToEnglish(day) == dayOfWeek);
    return isWithinDateRange && isMatchingDay;
  }).toList();
}


  String _convertDayToEnglish(String day) {
    switch (day) {
      case 'Hai': return 'Mon';
      case 'Ba': return 'Tue';
      case 'Tư': return 'Wed';
      case 'Năm': return 'Thu';
      case 'Sáu': return 'Fri';
      case 'Bảy': return 'Sat';
      case 'CN': return 'Sun';
      default: return day;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch dạy'),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          // Lịch 7 ngày
          SizedBox(
            height: 100,
            child: PageView.builder(
              controller: _pageController,
              itemCount: 14, // 7 ngày trước + 7 ngày sau
              onPageChanged: (index) {
                setState(() {
                  _selectedDate = DateTime.now().add(Duration(days: index - 7));
                });
              },
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index - 7));
                final isSelected = date.day == _selectedDate.day && 
                                  date.month == _selectedDate.month && 
                                  date.year == _selectedDate.year;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          DateFormat('MMM').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Nút chuyển ngày
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ],
            ),
          ),

          // Danh sách lớp học
          Expanded(
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _getClassesByDate(_selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                final classes = snapshot.data ?? [];

                if (classes.isEmpty) {
                  return const Center(
                    child: Text('Không có lớp học nào vào ngày này'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final classData = classes[index].data() as Map<String, dynamic>;
                    final timeParts = (classData['time'] as String).split(' - ');
                    final timeRange = timeParts.length > 1 ? timeParts[1] : '';

                    return _buildClassItem(
                      imageUrl: classData['imageUrl'],
                      className: classData['name'],
                      time: timeRange,
                      location: classData['location'],
                      members: (classData['members'] as List).length,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassItem({
    required String imageUrl,
    required String className,
    required String time,
    required String location,
    required int members,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 150,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  className,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '$members học viên',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}