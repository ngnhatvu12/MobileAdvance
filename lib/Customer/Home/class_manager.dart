import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_lt/Widget/course_item.dart';
import 'package:do_an_lt/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'customer_main.dart';

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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Phần header với gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [blue, const Color.fromARGB(255, 1, 3, 113)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Phần header với nút back và tiêu đề
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 16, right: 16, bottom: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CustomerMainPage()),
                          );
                        },
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Quản lý khóa học',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      // Tab Đăng ký
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _tabController.animateTo(0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _tabController.index == 0 
                                    ? Colors.white 
                                    : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Đăng ký',
                                style: TextStyle(
                                  color: _tabController.index == 0 
                                    ? Colors.white 
                                    : Colors.white.withOpacity(0.6),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Tab Khóa học của tôi
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _tabController.animateTo(1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _tabController.index == 1 
                                    ? Colors.white 
                                    : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Khóa học của tôi',
                                style: TextStyle(
                                  color: _tabController.index == 1 
                                    ? Colors.white 
                                    : Colors.white.withOpacity(0.6),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Đăng ký
                RegistrationTab(),
                // Tab Khóa học của tôi
                MyCoursesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class RegistrationTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      child: Padding(
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
                filled: true,
                fillColor: Colors.grey[200],
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
            StreamBuilder<QuerySnapshot>(
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
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
          ],
        ),
      ),
    );
  }
}

class MyCoursesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text(
          'Bạn cần đăng nhập để xem khóa học của mình.',
          style: TextStyle(fontSize: 16)),
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
          padding: const EdgeInsets.all(16),
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