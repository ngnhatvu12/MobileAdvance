import 'package:curved_navigation_bar/curved_navigation_bar.dart';
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
  // Danh sách các trang tương ứng với các nút trong Navigation Bar
  final List<Widget> _pages = [
    HomePage(), // Trang chủ
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
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _avatarText = '';
  final List<String> _tabs = ['Hôm nay', 'Hoạt động', 'Tin tức'];

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
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 2.5,
              children: [
                _buildButton('Đăng ký huấn luyện viên', Icons.sports_gymnastics, Alignment.bottomRight),
                _buildButton('Bắt đầu tập luyện', Icons.local_fire_department, Alignment.bottomLeft),
                _buildButton('Đăng ký khóa học', Icons.school, Alignment.topRight),
                _buildButton('Lịch tập của tôi', Icons.calendar_today, Alignment.topLeft),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Lịch tập hôm nay',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Hôm nay bạn không có sự kiện nào.',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            // Tin tức 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tin tức',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    // Hành động khi nhấn "Xem tất cả"
                    print('Xem tất cả tin tức');
                  },
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
              onTap: () {
                // Hành động khi nhấn "Xem tất cả"
                print('Xem tất cả');
              },
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
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Khách hàng tuân thủ',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusCircle('0', 'Thấp', Colors.red),
                _buildStatusCircle('0', 'Trung bình', Colors.orange),
                _buildStatusCircle('0', 'Cao', Colors.green),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.calendar_today, color: Colors.grey),
                      SizedBox(width: 10),
                      Text('Chương trình kết thúc',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text('Không có chương trình kết thúc sớm',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _buildButton(String text, IconData icon, Alignment alignment) {
    bool isLeft = alignment == Alignment.bottomLeft || alignment == Alignment.topLeft;

    return Container(
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

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Trang Menu",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
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