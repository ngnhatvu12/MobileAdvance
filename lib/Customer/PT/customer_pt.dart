import 'package:do_an_lt/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PTPage extends StatefulWidget {
  @override
  _PTPageState createState() => _PTPageState();
}
class _PTPageState extends State<PTPage> {
  int _selectedIndex = 0;
  String _searchQuery = ''; 
  final List<String> _tabs = ['Liên hệ', 'Đăng ký PT'];
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
      case 0:
      return Center(
          child: Column(
            
          ),
        );
      case 1:
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Tìm kiếm tên huấn luyện viên',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onChanged: (value) {
            // Cập nhật logic tìm kiếm tại đây
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Danh sách',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('coachs').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Không có huấn luyện viên nào.'));
            }

            // Lọc danh sách huấn luyện viên dựa trên tìm kiếm
            final filteredCoaches = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final name = data['ho ten'].toString().toLowerCase();
              return name.contains(_searchQuery.toLowerCase());
            }).toList();

            if (filteredCoaches.isEmpty) {
              return Center(child: Text('Không tìm thấy huấn luyện viên nào.'));
            }

            return ListView(
              children: filteredCoaches.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(data['anh']),
                        radius: 30,
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['ho ten'], style: TextStyle(fontSize: 18)),
                          Text(data['so dien thoai'], style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    ],
  );
    default:
        return Container();
    }
  }
   Future<String> _getImageUrl(String userId) async {
    final ref = FirebaseStorage.instance.ref().child('users/$userId/profile.jpg');
    return await ref.getDownloadURL();
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