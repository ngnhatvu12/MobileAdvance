import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_lt/Widget/course_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'customer_main.dart'; // Import trang chủ

class ClassManager extends StatefulWidget {
  final int initialTabIndex;
  const ClassManager({Key? key, this.initialTabIndex = 0}) : super(key: key);

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
    _tabController.index = widget.initialTabIndex;
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
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
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
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Danh mục',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('class').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Không có khóa học nào.'));
                }
                final courses = snapshot.data!.docs.where((course) =>
                    !course['members'].contains(user?.uid)).toList();

                if (courses.isEmpty) {
                  return const Center(child: Text('Không có khóa học nào để đăng ký.'));
                }

                return ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return CourseItem(
                      classId: course['classId'],
                      imageUrl: course['imageUrl'],
                      name: course['name'],
                      description: course['description'],
                      location: course['location'],
                      time: course['time'],
                      members: course['members'],
                      price: course['price'],
                      goals: course['goals'],
                      benefits: course['benefits'],
                      requirements: course['requirements'],
                      isRegistered: false,
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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text(
          'Bạn cần đăng nhập để xem khóa học của mình.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('class')
          .where('members', arrayContains: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Bạn chưa đăng ký khóa học nào.'),
          );
        }

        final courses = snapshot.data!.docs;

        return ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return CourseItem(
              classId: course['classId'],
              imageUrl: course['imageUrl'],
              name: course['name'],
              description: course['description'],
              location: course['location'],
              time: course['time'],
              members: course['members'],
              price: course['price'],
              goals: course['goals'],
              benefits: course['benefits'],
              requirements: course['requirements'],
              isRegistered: true,
            );
          },
        );
      },
    );
  }
}


void main() {
  runApp(const MaterialApp(
    home: ClassManager(),
  ));
}