import 'package:flutter/material.dart';
import 'customer_main.dart'; // Import trang chủ

class ClassManager extends StatefulWidget {
  const ClassManager({Key? key}) : super(key: key);

  @override
  _ClassManagerState createState() => _ClassManagerState();
}

class _ClassManagerState extends State<ClassManager>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CustomerMainPage()),
            );
          },
        ),
        title: const Text('Quản lý khóa học'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Đăng ký'),
            Tab(text: 'Khóa học của tôi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Đăng ký
          RegistrationTab(),
          // Tab Khóa học của tôi
          MyCoursesTab(),
        ],
      ),
    );
  }
}

// Widget cho tab Đăng ký
class RegistrationTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Thanh tìm kiếm
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm khóa học...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Tiêu đề danh mục
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Danh mục',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          // Danh sách danh mục
          Expanded(
            child: ListView(
              children: [
                CategoryItem('Công nghệ thông tin'),
                CategoryItem('Kinh doanh'),
                CategoryItem('Ngoại ngữ'),
                CategoryItem('Thiết kế'),
                // Thêm các danh mục khác nếu cần
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget cho mỗi mục danh mục
class CategoryItem extends StatelessWidget {
  final String categoryName;

  const CategoryItem(this.categoryName);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(categoryName),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Xử lý khi nhấn vào danh mục
        },
      ),
    );
  }
}

// Widget cho tab Khóa học của tôi
class MyCoursesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Danh sách khóa học đã đăng ký sẽ hiển thị ở đây',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ClassManager(),
  ));
}