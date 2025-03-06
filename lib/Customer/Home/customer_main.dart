import 'package:do_an_lt/theme/colors.dart';
import 'package:flutter/material.dart';
import '../PT/customer_pt.dart';
import '../Workout/customer_workout.dart';
import '../Nutrition/customer_nutrition.dart';
class CustomerMainPage extends StatefulWidget {
  const CustomerMainPage({super.key});

  @override
  _CustomerMainPageState createState() => _CustomerMainPageState();
}

class _CustomerMainPageState extends State<CustomerMainPage> {
  int _selectedIndex = 0; // Chỉ số của trang hiện tại

  // Danh sách các trang tương ứng với các nút trong Navigation Bar
  final List<Widget> _pages = [
    HomePage(), // Trang chủ
    PTPage(),    // Trang PT
    WorkoutPage(), // Trang Tập luyện
    NutritionPage(), // Trang Dinh dưỡng
    MenuPage(),  // Trang Menu
  ];

  // Hàm xử lý khi người dùng chọn một nút trong Navigation Bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cập nhật chỉ số trang hiện tại
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Hiển thị trang tương ứng với chỉ số được chọn
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Chỉ số trang hiện tại
        onTap: _onItemTapped, // Gọi hàm xử lý khi người dùng chọn nút
        type: BottomNavigationBarType.fixed, // Cố định các nút
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'PT',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: 'Tập luyện',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Dinh dưỡng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
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
                    onTap: () {},
                    child: CircleAvatar(
                      backgroundColor: Colors.blue.shade300,
                      radius: 25,
                      child: const Text('NV', style: TextStyle(color: Colors.white, fontSize: 18)),
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
                  child: _buildTabContent(),
                ),
              ),
            ),
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