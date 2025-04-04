import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_lt/Widget/course_item.dart';
import 'package:do_an_lt/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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

  _tabController.addListener(() {
    if (mounted) {
      setState(() {}); // Cập nhật UI khi tab thay đổi
    }
  });
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
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _tabController.animateTo(0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _tabController.index == 0 ? Colors.white : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Đăng ký',
                                style: TextStyle(
                                  color: _tabController.index == 0 ? Colors.white : Colors.white.withOpacity(0.6),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
class RegistrationTab extends StatefulWidget {
  @override
  _RegistrationTabState createState() => _RegistrationTabState();
}

class _RegistrationTabState extends State<RegistrationTab> {
  final PageController _bannerController = PageController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Tất cả', 'image': 'assets/images/swim.jpg', 'type': 'Tất cả'},
    {'name': 'Yoga', 'image': 'assets/images/yoga.jpeg', 'type': 'yoga'},
    {'name': 'Bơi', 'image': 'assets/images/swim.jpg', 'type': 'bơi'},
    {'name': 'Gym', 'image': 'assets/images/gym.jpg', 'type': 'gym'},
    {'name': 'Cycling', 'image': 'assets/images/cycling.jpg', 'type': 'cycling'},
    {'name': 'Karate', 'image': 'assets/images/karate.jpg', 'type': 'karate'},
  ];

  final List<String> _banners = [
    'assets/images/banner_class1.jpg',
    'assets/images/banner_class2.jpg',
    'assets/images/banner_class3.png',
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_bannerController.hasClients && mounted) {
        // Không gọi setState ở đây để tránh rebuild toàn bộ widget
        _currentBannerIndex = (_currentBannerIndex + 1) % _banners.length;
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Banner section - tách riêng state
          _BannerSection(
            banners: _banners,
            bannerController: _bannerController,
            currentBannerIndex: _currentBannerIndex,
          ),
          
          // Search section
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm khóa học...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),

          // Category title
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Khóa học',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // Category list
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category['type'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['type'];
                      });
                    },
                    child: Container(
                      width: 100,
                      margin: EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? blue : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                      )],
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10)),
                              image: DecorationImage(
                                image: AssetImage(category['image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                category['name'],
                                style: TextStyle(
                                  color: isSelected ? blue : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Course list - sử dụng AutomaticKeepAlive
          _CourseListSection(
            selectedCategory: _selectedCategory,
            searchText: _searchController.text,
          ),
        ],
      ),
    );
  }
}

// Tách riêng phần banner để quản lý state độc lập
class _BannerSection extends StatefulWidget {
  final List<String> banners;
  final PageController bannerController;
  final int currentBannerIndex;

  const _BannerSection({
    required this.banners,
    required this.bannerController,
    required this.currentBannerIndex,
  });

  @override
  __BannerSectionState createState() => __BannerSectionState();
}

class __BannerSectionState extends State<_BannerSection> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(height: 30),
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                PageView.builder(
                  controller: widget.bannerController,
                  itemCount: widget.banners.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(widget.banners[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: widget.bannerController,
                      count: widget.banners.length,
                      effect: WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: blue,
                        dotColor: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Tách riêng phần danh sách khóa học với AutomaticKeepAlive
class _CourseListSection extends StatefulWidget {
  final String selectedCategory;
  final String searchText;

  const _CourseListSection({
    required this.selectedCategory,
    required this.searchText,
  });

  @override
  __CourseListSectionState createState() => __CourseListSectionState();
}

class __CourseListSectionState extends State<_CourseListSection> 
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('class').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SliverFillRemaining(
            child: Center(child: Text('Không có khóa học nào.')),
          );
        }

        var courses = snapshot.data!.docs.where((course) {
          if (course['members'].contains(user?.uid)) {
            return false;
          }
          
          if (widget.selectedCategory != 'Tất cả') {
            final courseData = course.data() as Map<String, dynamic>;
            final courseType = courseData['type'] ?? '';
            return courseType == widget.selectedCategory;
          }
          return true;
        }).toList();

        if (widget.searchText.isNotEmpty) {
          final searchText = widget.searchText.toLowerCase();
          courses = courses.where((course) {
            return course['name'].toString().toLowerCase().contains(searchText) ||
                course['description'].toString().toLowerCase().contains(searchText);
          }).toList();
        }

        if (courses.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    widget.selectedCategory == 'Tất cả'
                        ? 'Hiện tại chưa có khóa học nào'
                        : 'Không tìm thấy khóa học ${widget.selectedCategory} phù hợp',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final course = courses[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: CourseItem(
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
                ),
              );
            },
            childCount: courses.length,
          ),
        );
      },
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