import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_lt/Customer/PT/pt_detail.dart';
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
      return Center(child: Text('Liên hệ', style: TextStyle(fontSize: 18)));
    }
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

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
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

  final String address = data['address'] ?? 'Chưa có địa chỉ';

  return Container(
    decoration: BoxDecoration(
      color: Colors.white54,
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
    padding: const EdgeInsets.all(15),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // Xử lý logic khi nhấn vào thẻ
                  },
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
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return const Icon(Icons.star, color: Colors.amber, size: 18);
                        }),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '🕒 ${data['time']}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Kỹ năng: $specializationsText',
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        height: 20,
                        child: MarqueeWidget(
                          child: Text(
                            '📍 $address',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 120,
            child: ElevatedButton(
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
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Đăng ký',
                style: TextStyle(color: Colors.white),
              ),
            ),
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
