import 'dart:async';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:do_an_lt/Customer/Home/class_manager.dart';
import 'package:do_an_lt/Customer/Home/news_detail.dart';
import 'package:do_an_lt/Customer/Home/schedule.dart';
import 'package:do_an_lt/Customer/Menu/customer_menu.dart';
import 'package:do_an_lt/Widget/schedule_item.dart';
import 'package:do_an_lt/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../PT/customer_pt.dart';
import '../Workout/customer_workout.dart';
import '../Nutrition/customer_nutrition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class CustomerMainPage extends StatefulWidget {
  
  const CustomerMainPage({super.key});

  @override
  _CustomerMainPageState createState() => _CustomerMainPageState();
}

class _CustomerMainPageState extends State<CustomerMainPage> {
  int _selectedIndex = 0; // Chỉ số của trang hiện tại
  String _avatarText = '';
  
  List<Widget> get _pages => [
        HomePage(
          onIndexChanged: (index) {
            setState(() {
              _selectedIndex = index; // Cập nhật state ở đây
            });
          },
        ), // Trang chủ
        PTPage(),    // Trang PT
        WorkoutPage(), // Trang Tập luyện
        NutritionPage(), // Trang Dinh dưỡng
        MenuPage(),  // Trang Menu
      ];
  
  @override
  void initState() {
    super.initState();
    _fetchCustomerName();
  }
  // Hàm lấy tên khách hàng từ Firestore
  void _fetchCustomerName() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userId = user.uid;
    final customerSnapshot = await FirebaseFirestore.instance
        .collection('customers')
        .where('userId', isEqualTo: userId)
        .get();

    if (customerSnapshot.docs.isNotEmpty) {
      final customerData = customerSnapshot.docs.first.data();
      final name = customerData['name'] as String? ?? 'Nguyen Nhat Vu';
      final initials = _getInitials(name);
      setState(() {
        _avatarText = initials; 
      });
    }
  }
}
String _getInitials(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  if (words.length == 1) {
    return words[0][0].toUpperCase();
  } else {
    return (words[0][0] + words[1][0]).toUpperCase();
  }
}
  // Hàm xử lý khi người dùng chọn một nút trong Navigation Bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cập nhật chỉ số trang hiện tại
    });
  }

  @override
Widget build(BuildContext context) {
  final items = <Widget>[
      Image.asset('assets/icons/home.png', height: 30, width: 30),
      Image.asset('assets/icons/pt.png', height: 30, width: 30),
      Image.asset('assets/icons/fire.png', height: 30, width: 30),
      Image.asset('assets/icons/nutrition.png', height: 30, width: 30),
      Image.asset('assets/icons/menu.png', height: 30, width: 30),
    ];

  return Scaffold(
    body: _pages[_selectedIndex],
    bottomNavigationBar: CurvedNavigationBar(
      backgroundColor: Colors.transparent, // Màu nền của nội dung trên body
      color: Colors.blue, // Màu của navigation bar
      buttonBackgroundColor: Colors.blueAccent, // Màu nền của nút được chọn
      height: 60,
      index: _selectedIndex,
      items: items,
      animationDuration: Duration(milliseconds: 300),
      animationCurve: Curves.easeInOut,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    ),
  );
}
}


class HomePage extends StatefulWidget {
  final Function(int) onIndexChanged; // Callback để thay đổi index

  const HomePage({Key? key, required this.onIndexChanged}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _avatarText = '';
  String _searchQuery = '';
  bool _sortByNewest = false;
  String _twoDigits(int n) => n.toString().padLeft(2, '0');
  final List<String> _tabs = ['Hôm nay', 'Hoạt động', 'Tin tức'];
  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }
  void _onSortByNewest() {
    setState(() {
      _sortByNewest = !_sortByNewest;
    });
  }
   void _onViewAllNewsPressed() {
    setState(() {
      _selectedIndex = 2; // Chuyển sang tab Tin tức
    });
  }
  Widget _buildRealTimeClock() {
  return StreamBuilder(
    stream: Stream.periodic(const Duration(seconds: 1)),
    builder: (context, snapshot) {
      final now = DateTime.now();
      final formattedTime = '${_getWeekday(now.weekday)}, ${now.day}/${now.month}/${now.year} '
          '${now.hour}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
      return Text(
        formattedTime,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
    },
  );
}

String _getWeekday(int weekday) {
  switch (weekday) {
    case 1:
      return 'Thứ Hai';
    case 2:
      return 'Thứ Ba';
    case 3:
      return 'Thứ Tư';
    case 4:
      return 'Thứ Năm';
    case 5:
      return 'Thứ Sáu';
    case 6:
      return 'Thứ Bảy';
    case 7:
      return 'Chủ Nhật';
    default:
      return '';
  }
}
  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 50),
            Stack(
              children: [
                _buildScrollableTopBar(),
                Positioned(
                  right: 20,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.blue.shade300,
                      radius: 25,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue.shade300,
                        radius: 25,
                        child: Text(
                          _avatarText.isNotEmpty ? _avatarText : 'NQ',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
           Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              margin: const EdgeInsets.only(top: 30),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: _buildTabContent(),
                ),
              ),
            ),
           )
          ],
        ),
      ),
    );
  }
  
  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 0: // Hôm nay
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             _buildRealTimeClock(), // Chèn đồng hồ thời gian thực
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 2.5,
              children: [
                _buildButton(
                  'Đăng ký huấn luyện viên',
                  Icons.sports_gymnastics,
                  Alignment.bottomRight,
                  () {
                    widget.onIndexChanged(1);
                  },
                ),
                _buildButton(
                  'Bắt đầu tập luyện',
                  Icons.local_fire_department,
                  Alignment.bottomLeft,
                  () {
                    widget.onIndexChanged(2);
                  },
                ),
                _buildButton(
                  'Đăng ký khóa học',
                  Icons.school,
                  Alignment.topRight,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ClassManager()),
                    );
                  },
                ),
                _buildButton(
                  'Lịch tập của tôi',
                  Icons.calendar_today,
                  Alignment.topLeft,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyTrainingSchedulePage()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.message, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Bạn có 1 tin nhắn chưa đọc',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ScheduleWidget(),
            const SizedBox(height: 30),
            // Tin tức 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tin tức',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: _onViewAllNewsPressed,
                  child: const Text('Xem tất cả',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('news').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('Không có tin tức nào.');
                }
                final news = snapshot.data!.docs;

                return SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: news.length,
                    itemBuilder: (context, index) {
  final doc = news[index];
  final title = doc['name'] ?? 'Không có tiêu đề';
  final imageUrl = doc['imageUrl'] ?? '';
  final date = doc['date'] ?? '';

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewsDetailPage(
            newsItem: {
              'id': doc.id,
              'name': title,
              'imageUrl': imageUrl,
              'date': date,
              'detail': doc['detail'],
            },
          ),
        ),
      );
    },
    child: Container(
      width: 250,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Image.network(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(
                height: 150,
                color: Colors.grey,
                child: const Center(child: Icon(Icons.error)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 10),
            child: Text(
              date,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    ),
  );
},
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            // Dinh dưỡng
            Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Chế độ dinh dưỡng',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Xem tất cả',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // StreamBuilder để lấy dữ liệu từ Firestore
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('communitys').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('Không có bài viết nào.');
            }
            final news = snapshot.data!.docs;

            return SizedBox(
              height: 220, // Chiều cao của mỗi item
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: news.length,
                itemBuilder: (context, index) {
                  final doc = news[index];
                  final content = doc['content'] ?? 'Không có nội dung';
                  final imageUrl = doc['imageUrl'] ?? '';
                  final customerId = doc['customerId'] ?? '';

                  // Lấy thông tin người đăng từ collection 'customers'
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('customers')
                        .doc(customerId)
                        .get(),
                    builder: (context, customerSnapshot) {
                      if (!customerSnapshot.hasData) {
                        return const SizedBox();
                      }
                      final customerData = customerSnapshot.data!.data() as Map<String, dynamic>?;
                      final customerName = customerData?['name'] ?? 'Ẩn danh';
                      final customerImageUrl = customerData?['imageUrl'] ?? '';

                      return Container(
                        width: 250,
                        margin: const EdgeInsets.only(right: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hình ảnh
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              child: Image.network(
                                imageUrl,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 150,
                                  color: Colors.grey,
                                  child: const Center(child: Icon(Icons.error)),
                                ),
                              ),
                            ),
                            // Nội dung
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            // Thông tin người đăng
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(customerImageUrl),
                                    radius: 15,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    customerName,
                                    style: const TextStyle(
                                      fontSize: 12,
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
                  );
                },
              ),
            );
          },
        ),
          ],
        );
      case 1: // Hoạt động
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.calendar_today, size: 80, color: Colors.blue),
              SizedBox(height: 20),
              Text('Không có gì để xem ở đây?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Không tìm thấy mục hoạt động nào',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        );
      case 2: // Tin tức
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh tìm kiếm và nút lọc
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm tin tức...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: _onSearch,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _onSortByNewest,
                  ),
                ],
              ),
            ),
            // Danh sách tin tức
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('news').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Không có tin tức nào.'));
                }

                var news = snapshot.data!.docs;

                // Lọc theo tìm kiếm
                if (_searchQuery.isNotEmpty) {
                  news = news.where((doc) {
                    final name = doc['name']?.toString().toLowerCase() ?? '';
                    return name.contains(_searchQuery.toLowerCase());
                  }).toList();
                }

                // Sắp xếp theo ngày mới nhất
                if (_sortByNewest) {
                  news.sort((a, b) {
                    final dateA = _parseDate(a['date'] ?? '');
                    final dateB = _parseDate(b['date'] ?? '');
                    return dateB.compareTo(dateA);
                  });
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: news.length,
                  itemBuilder: (context, index) {
                    final doc = news[index];
                    final title = doc['name'] ?? 'Không có tiêu đề';
                    final imageUrl = doc['imageUrl'] ?? '';
                    final date = doc['date'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsDetailPage(
                              newsItem: {
                                'id': doc.id,
                                'name': title,
                                'imageUrl': imageUrl,
                                'date': date,
                                'detail': doc['detail'],
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: Image.network(
                                imageUrl,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 150,
                                  color: Colors.grey,
                                  child: const Center(child: Icon(Icons.error)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 10),
                              child: Text(
                                date,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      default:
        return Container();
    }
  }
  DateTime _parseDate(String date) {
    final parts = date.split('/');
    if (parts.length == 3) {
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    }
    return DateTime.now();
  }
  Widget _buildButton(String text, IconData icon, Alignment alignment, VoidCallback onTap) {
    bool isLeft = alignment == Alignment.bottomLeft || alignment == Alignment.topLeft;

    return GestureDetector(
      onTap: onTap, // Thêm xử lý khi nhấn
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: isLeft ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
          children: [
            if (isLeft) Icon(icon, color: Colors.blue.shade300),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                softWrap: true,
              ),
            ),
            if (!isLeft) Icon(icon, color: Colors.blue.shade300),
          ],
        ),
      ),
    );
  }
  Widget _buildStatusCircle(String count, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color.withOpacity(0.2),
          child: Text(count, style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
  Widget _buildScrollableTopBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: _tabs.map((tab) {
            final isSelected = _tabs.indexOf(tab) == _selectedIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = _tabs.indexOf(tab);
                  });
                },
                child: Text(
                  tab,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text('Tùy chỉnh'),
            trailing: Checkbox(value: false, onChanged: (value) {}),
          ),
          ListTile(
            title: Text('Cài đặt tính năng'),
            trailing: Checkbox(value: false, onChanged: (value) {}),
          ),
          ListTile(
            title: Text('Báo cáo sự cố'),
            trailing: Checkbox(value: true, onChanged: (value) {}),
          ),
          ListTile(
            title: Text('Thông tin'),
            trailing: Checkbox(value: false, onChanged: (value) {}),
          ),
          Divider(),
          ListTile(
            title: Text('Đăng xuất'),
            onTap: () {
              // Xử lý đăng xuất
            },
          ),
        ],
      ),
    );
  }
}