import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_lt/Customer/PT/pt_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:do_an_lt/theme/colors.dart';

class PTPage extends StatefulWidget {
  @override
  _PTPageState createState() => _PTPageState();
}

class _PTPageState extends State<PTPage> {
  int _selectedIndex = 1; // Mặc định vào tab "Đăng ký PT"
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  final List<String> _tabs = ['Liên hệ', 'Đăng ký PT'];
  final List<String> _categories = ['Tất cả', 'Giảm cân', 'Tăng cơ', 'Sức bền'];

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
            _buildScrollableTopBar(),
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

  Widget _buildScrollableTopBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = _tabs.indexOf(tab) == _selectedIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = _tabs.indexOf(tab);
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
    );
  }

  Widget _buildTabContent() {
    if (_selectedIndex == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildCategoryFilter(),
          const SizedBox(height: 20),
          Expanded(child: _buildCoachGrid()),
        ],
      );
    } else {
       return _buildContactTab();
    }
  }
  Widget _buildContactTab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Vui lòng đăng nhập để xem liên hệ.'));
    }

    return Column(
      children: [
        _buildContactSearchBar(),
        const SizedBox(height: 10),
        _buildContactHeader(),
        const SizedBox(height: 10),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('contacts')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Không có liên hệ nào.'));
              }

              final contacts = snapshot.data!.docs;

              return ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index].data() as Map<String, dynamic>;
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('coachs')
                        .doc(contact['coachId'])
                        .get(),
                    builder: (context, coachSnapshot) {
                      if (coachSnapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(
                          title: Text('Đang tải...'),
                        );
                      }
                      if (coachSnapshot.hasError) {
                        return ListTile(
                          title: Text('Lỗi: ${coachSnapshot.error}'),
                        );
                      }
                      if (!coachSnapshot.hasData || !coachSnapshot.data!.exists) {
                        return const ListTile(
                          title: Text('Huấn luyện viên không tồn tại.'),
                        );
                      }

                      final coachData = coachSnapshot.data!.data() as Map<String, dynamic>;
                      final endDate = DateTime.parse(contact['endDate']);
                      final daysRemaining = endDate.difference(DateTime.now()).inDays;

                      return _buildContactItem(
                        imageUrl: coachData['imageUrl'],
                        name: coachData['name'],
                        daysRemaining: daysRemaining,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
  Widget _buildContactSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Tìm kiếm tên hoặc email...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }
  Widget _buildContactHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'A đến Z',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Xử lý logic lọc
            },
          ),
        ],
      ),
    );
  }
  Widget _buildContactItem({
  required String imageUrl,
  required String name,
  required int daysRemaining,
}) {
  return Card(
    elevation: 4, // Độ đổ bóng
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15), // Bo góc
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Khoảng cách giữa các item
    child: Padding(
      padding: const EdgeInsets.all(12), // Khoảng cách bên trong
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 30, // Kích thước avatar
          ),
          const SizedBox(width: 16), // Khoảng cách giữa avatar và text
          // Thông tin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4), // Khoảng cách giữa tên và ngày
                Text(
                  'Kết thúc trong $daysRemaining ngày',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Nút tin nhắn
          IconButton(
            icon: const Icon(Icons.message, color: blue), // Màu icon
            onPressed: () {
              // Xử lý logic nhắn tin
            },
          ),
        ],
      ),
    ),
  );
}
  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Tìm kiếm tên huấn luyện viên...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCoachGrid() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('coachs').snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text('Không có huấn luyện viên nào.'));
      }

      final filteredCoaches = snapshot.data!.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'].toString().toLowerCase();
        final specializations = List<String>.from(data['specializations'] ?? []);
        final matchesCategory = _selectedCategory == 'Tất cả' || specializations.contains(_selectedCategory);
        return name.contains(_searchQuery.toLowerCase()) && matchesCategory;
      }).toList();

      if (filteredCoaches.isEmpty) {
        return const Center(child: Text('Không tìm thấy huấn luyện viên.'));
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: filteredCoaches.length,
        itemBuilder: (context, index) {
          final data = filteredCoaches[index].data() as Map<String, dynamic>;
          return _buildCoachCard(data);
        },
      );
    },
  );
}

 Widget _buildCoachCard(Map<String, dynamic> data) {
  final List<dynamic>? specializations = data['specializations'];
  final String specializationsText = (specializations != null && specializations.isNotEmpty)
      ? specializations.join(', ')
      : 'Chưa có kỹ năng';
  final String time = data['time'] ?? 'null';
  final String address = data['address'] ?? 'Chưa có địa chỉ';

  // Lấy gói đầu tiên từ packagePrices
  final List<dynamic>? packagePrices = data['packagePrices'];
  final String firstPackage = (packagePrices != null && packagePrices.isNotEmpty)
      ? packagePrices[0] // Lấy gói đầu tiên
      : 'Chưa có gói';

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey.shade300, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Khoảng cách giữa các item
    padding: const EdgeInsets.all(15),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phần 30% bên trái: Avatar và tên
        Container(
          width: MediaQuery.of(context).size.width * 0.3, // 30% chiều rộng
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(data['imageUrl']),
                radius: 40,
              ),
              const SizedBox(height: 10),
              Text(
                data['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              // Đánh giá 5/5 sao
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return const Icon(Icons.star, color: Colors.amber, size: 16);
                }),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10), // Khoảng cách giữa 2 phần
        // Phần 70% bên phải: Thông tin và nút đăng ký
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thời gian
              SizedBox(
                height: 20,
                child: MarqueeWidget(
                  child: Text(
                '🕒 $time',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
                ),
              ),
              const SizedBox(height: 5),
              // Kỹ năng
              Text(
                'Kỹ năng: $specializationsText',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 5),
              // Địa chỉ
              SizedBox(
                height: 20,
                child: MarqueeWidget(
                  child: Text(
                    '📍 $address',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Gói đầu tiên và nút đăng ký
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Hiển thị gói đầu tiên
                  Text(
                    firstPackage,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Nút đăng ký
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PTDetailPage(coachData: data),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                    child: const Text(
                      'Đăng ký',
                      style: TextStyle(color: Colors.white),
                    ),
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
class MarqueeWidget extends StatefulWidget {
  final Widget child;
  final double scrollDuration; // Thời gian cuộn (giây)

  const MarqueeWidget({
    Key? key,
    required this.child,
    this.scrollDuration = 8.0,
  }) : super(key: key);

  @override
  _MarqueeWidgetState createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.scrollDuration.toInt()),
    )..repeat();

    _animationController.addListener(() {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _animationController.value * _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
