import 'package:do_an_lt/Coach/Dashboard/coach_schedule_page.dart';
import 'package:do_an_lt/Coach/Info/coach_profile.dart';
import 'package:do_an_lt/Coach/Manager/coach_manager.dart';
import 'package:do_an_lt/Coach/Tool/coach_tools.dart';
import 'package:do_an_lt/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';   
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CoachMainPage extends StatefulWidget {
  const CoachMainPage({super.key});

  @override
  _CoachMainPageState createState() => _CoachMainPageState();
}

class _CoachMainPageState extends State<CoachMainPage> {
  int _currentIndex = 0; // Mặc định là trang chủ (index 0)

  // Danh sách các trang tương ứng với bottom navigation
  final List<Widget> _pages = [
    const CoachHomePage(),
    const CoachStudentsPage(),
    const CoachToolsPage(),
    const CoachProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60,
        color: Colors.red,
        buttonBackgroundColor: Colors.redAccent,
        backgroundColor: Colors.transparent,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          Icon(Icons.home, color: Colors.white, size: 30),
          Icon(Icons.people, color: Colors.white, size: 30),
          Icon(Icons.fitness_center, color: Colors.white, size: 30),
          Icon(Icons.person, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}

class CoachHomePage extends StatelessWidget {
  const CoachHomePage({super.key});
  Future<String> _getCoachId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');
      
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) throw Exception('User document not found');
      
      final coachId = userDoc['coachId'] as String?;
      if (coachId == null) throw Exception('Coach ID not found in user document');
      
      print('Coach ID: $coachId');
      return coachId;
    } catch (e) {
      print('Error getting coachId: $e');
      rethrow;
    }
  }
  Future<int> _getTotalStudents(String coachId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('class')
          .where('coachId', isEqualTo: coachId)
          .get();
      
      int total = 0;
      for (var doc in query.docs) {
        final members = doc['members'] as List? ?? [];
        total += members.length;
        print('Class ${doc.id} has ${members.length} members');
      }
      
      print('Total students: $total');
      return total;
    } catch (e) {
      print('Error getting total students: $e');
      return 0;
    }
  }
  Future<int> _getTotalClasses(String coachId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('class')
          .where('coachId', isEqualTo: coachId)
          .get();
      
      print('Total classes: ${query.size}');
      return query.size;
    } catch (e) {
      print('Error getting total classes: $e');
      return 0;
    }
  }
  Future<List<QueryDocumentSnapshot>> _getTodayClasses(String coachId) async {
    final now = DateTime.now();
    final today = DateFormat('EEEE').format(now).substring(0, 3); // "Mon", "Tue", etc.
    
    final query = await FirebaseFirestore.instance
        .collection('class')
        .where('coachId', isEqualTo: coachId)
        .get();

    return query.docs.where((doc) {
      final timeStr = doc['time'] as String? ?? '';
      final days = timeStr.split(' - ')[0].split(', ');
      return days.any((day) => _convertDayToEnglish(day) == today);
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
  Future<QuerySnapshot> _getCommunityPosts() async {
    return await FirebaseFirestore.instance
        .collection('communitys')
        .orderBy('date', descending: true)
        .limit(3)
        .get();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: _getCoachId(),
        builder: (context, coachIdSnapshot) {
          if (coachIdSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }         
          if (coachIdSnapshot.hasError) {
            print('Error in coachId FutureBuilder: ${coachIdSnapshot.error}');
            return Center(child: Text('Error: ${coachIdSnapshot.error}'));
          }         
          if (!coachIdSnapshot.hasData) {
            print('No coachId data available');
            return const Center(child: Text('Không tìm thấy thông tin huấn luyện viên'));
          }        
          final coachId = coachIdSnapshot.data!;
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [red, Colors.black],
                  ),
                ),
              ),         
              Column(
                children: [
                  Container(
                    height: 140,
                    padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/icons/workout.png',
                              width: 40,
                              height: 40,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'FitnessApp',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Thống kê
                              _buildSectionHeader(context,'Thống kê cá nhân'),
                              const SizedBox(height: 15),
                              FutureBuilder(
                                future: Future.wait([
                                  _getTotalStudents(coachId),
                                  _getTotalClasses(coachId),
                                  Future.value(5.0)
                                ]),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  final data = snapshot.data!;
                                  return _buildStatsSection(
                                    data[0].toString(),
                                    data[1].toString(),
                                    data[2].toStringAsFixed(1),
                                  );
                                },
                              ),                             
                              const SizedBox(height: 30),                      
                              _buildSectionHeader(context,'Lịch dạy hôm nay', showArrow: true, coachId: coachId),
                              const SizedBox(height: 15),
                              FutureBuilder<List<QueryDocumentSnapshot>>(
                                future: _getTodayClasses(coachId),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  return _buildScheduleSection(snapshot.data!);
                                },
                              ),
                              
                              const SizedBox(height: 30),
                              
                              // Thông báo
                              _buildSectionHeader(context,'Thông báo mới', showBadge: true),
                              const SizedBox(height: 15),
                              _buildNotificationsSection(),
                              
                              const SizedBox(height: 30),
                              
                              // Bài viết cộng đồng
                              _buildSectionHeader(context,'Bài viết nổi bật', showArrow: true),
                              const SizedBox(height: 15),
                              FutureBuilder<QuerySnapshot>(
                                future: _getCommunityPosts(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  return _buildCommunitySection(snapshot.data!);
                                },
                              ),
                              
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context,String title, {bool showArrow = false, bool showBadge = false, String? coachId}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (showArrow)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ),
          if (showBadge)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '3',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      TextButton(
        onPressed: () {
          if (coachId != null && title == 'Lịch dạy hôm nay') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CoachSchedulePage(coachId: coachId),
              ),
            );
          }
        },
        child: const Text(
          'Xem tất cả',
          style: TextStyle(color: Colors.blue),
        ),
      ),
    ],
  );
}

  Widget _buildStatsSection(String students, String classes, String rating) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(Icons.people, students, 'Học viên', Colors.blue),
          _buildStatItem(Icons.class_, classes, 'Khóa học', Colors.green),
          _buildStatItem(Icons.star, rating, 'Đánh giá', Colors.amber),
          _buildStatItem(Icons.access_time, '12', 'Giờ/tuần', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection(List<QueryDocumentSnapshot> classes) {
    if (classes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Hôm nay không có lịch dạy', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: classes.map((classDoc) {
        final data = classDoc.data() as Map<String, dynamic>;
        final timeParts = (data['time'] as String).split(' - ');
        final days = timeParts[0].split(', ');
        final timeRange = timeParts.length > 1 ? timeParts[1] : '';
        
        return _buildScheduleCard(
          data['name'] ?? 'Không có tên',
          timeRange,
          days.join(', '),
          data['location'] ?? 'Không có địa điểm',
          Icons.fitness_center,
          Colors.green,
          (data['members'] as List).length.toString(),
        );
      }).toList(),
    );
  }

  Widget _buildScheduleCard(
    String title,
    String time,
    String days,
    String location,
    IconData icon,
    Color color,
    String studentCount,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thời gian: $time',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Text(
                  'Thứ: $days',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Text(
                  'Địa điểm: $location',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Text(
                  'Số học viên: $studentCount',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      children: [
        _buildNotificationItem(
          'Nguyễn Văn A đã đăng ký khóa học Yoga',
          '10 phút trước',
          Icons.person_add,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildNotificationItem(
          'Hệ thống cập nhật phiên bản mới 2.0',
          'Hôm nay',
          Icons.system_update,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  Widget _buildCommunitySection(QuerySnapshot snapshot) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return _buildCommunityPost(
            data['content'] ?? 'Không có nội dung',
            data['imageUrl'] ?? 'assets/images/swim.jpg',
            data['date'],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCommunityPost(String content, String image, String date) {
  return Container(
    width: 220,
    margin: const EdgeInsets.only(right: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 8,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          child: image.startsWith('http')
              ? Image.network(
                  image,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallbackImage(),
                )
              : _buildFallbackImage(),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.length > 30 ? '${content.substring(0, 30)}...' : content,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '24',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.comment, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '5',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

Widget _buildFallbackImage() {
  return Image.asset(
    'assets/images/swim.jpg',
    height: 120,
    width: double.infinity,
    fit: BoxFit.cover,
  );
}
}