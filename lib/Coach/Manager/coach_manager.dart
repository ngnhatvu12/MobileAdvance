import 'package:do_an_lt/Coach/Manager/contact_customer.dart';
import 'package:do_an_lt/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CoachStudentsPage extends StatefulWidget {
  const CoachStudentsPage({super.key});

  @override
  State<CoachStudentsPage> createState() => _CoachStudentsPageState();
}

class _CoachStudentsPageState extends State<CoachStudentsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _coachId;
  int _selectedTab = 0;
  final ScrollController _tabScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _getCoachId();
  }

  Future<void> _getCoachId() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _coachId = userDoc['coachId'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_coachId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [red, Colors.black],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            SizedBox(
              height: 60, 
              child: SingleChildScrollView(
                controller: _tabScrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    _buildTabTitle('Học viên', 0),
                    const SizedBox(width: 30),
                    _buildTabTitle('Khóa học', 1),
                    const SizedBox(width: 30),
                    _buildTabTitle('Yêu cầu', 2),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: IndexedStack(
                  index: _selectedTab,
                  children: [
                    _buildStudentsTab(),
                    _buildCoursesTab(),
                    _buildRequestsTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildTabTitle(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
        _tabScrollController.animateTo(
          index * 200.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: _selectedTab == index 
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: _selectedTab == index 
                ? Colors.white 
                : Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
  Widget _buildStudentsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('class')
          .where('coachId', isEqualTo: _coachId)
          .snapshots(),
      builder: (context, classSnapshot) {
        if (!classSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final classes = classSnapshot.data!.docs;
        if (classes.isEmpty) {
          return const Center(child: Text('Không có lớp học nào'));
        }

        // Get all student IDs from all classes
        final studentIds = <String>[];
        for (var classDoc in classes) {
          final members = classDoc['members'] as List? ?? [];
          studentIds.addAll(members.whereType<String>());
        }

        if (studentIds.isEmpty) {
          return const Center(child: Text('Không có học viên nào'));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('users')
              .where(FieldPath.documentId, whereIn: studentIds)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: userSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final userDoc = userSnapshot.data!.docs[index];
                return FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('customers')
                      .doc(userDoc['customerId'])
                      .get(),
                  builder: (context, customerSnapshot) {
                    if (!customerSnapshot.hasData) {
                      return _buildStudentCardShimmer();
                    }

                    final customerData = customerSnapshot.data!.data() as Map<String, dynamic>;
                    return _buildStudentCard(userDoc.id, customerData);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
  Widget _buildStudentCardShimmer() {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 150,
                    height: 20,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: 100,
                    height: 16,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStudentCard(String userId, Map<String, dynamic> customerData) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'student-$userId',
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      customerData['imageUrl'] ?? 
                      'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerData['name'] ?? 'Học viên',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            customerData['phone']?.toString() ?? 'Chưa có số điện thoại',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.message, color: Colors.blue),
                  onPressed: () => _startChat(context, userId, customerData['name']),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Lớp đang tham gia:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            _buildStudentClasses(userId),
            const SizedBox(height: 12),
            const Text(
              'Mục tiêu tập luyện:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              customerData['goals'] ?? 'Chưa có thông tin mục tiêu',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
    void _startChat(BuildContext context, String studentId, String studentName) async {
    // Lấy thông tin học viên từ Firestore
    final studentDoc = await _firestore.collection('users').doc(studentId).get();
    final studentData = studentDoc.data() as Map<String, dynamic>;
    
    // Lấy thông tin huấn luyện viên hiện tại
    final coach = _auth.currentUser!;
    final coachDoc = await _firestore.collection('users').doc(coach.uid).get();
    final coachData = coachDoc.data() as Map<String, dynamic>;
    
    // Tạo liên hệ trong collection của huấn luyện viên
    await _firestore.collection('users')
      .doc(coach.uid)
      .collection('contacts')
      .doc(studentId)
      .set({
        'name': studentName,
        'imageUrl': studentData['imageUrl'] ?? 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
      });
    await _firestore.collection('users')
      .doc(studentId)
      .collection('contacts')
      .doc(coach.uid)
      .set({
        'name': coachData['name'] ?? 'Huấn luyện viên',
        'imageUrl': coachData['imageUrl'] ?? 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
      });
    
    // Chuyển đến trang MessengerPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoachMessengerPage(
          studentId: studentId,
          studentName: studentName,
          studentImageUrl: studentData['imageUrl'] ?? 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
        ),
      ),
    );
  }
  Widget _buildStudentClasses(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('class')
          .where('coachId', isEqualTo: _coachId)
          .where('members', arrayContains: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text('Đang tải...', style: TextStyle(fontSize: 14));
        }

        final classes = snapshot.data!.docs;
        if (classes.isEmpty) {
          return const Text('Chưa tham gia lớp nào', style: TextStyle(fontSize: 14));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: classes.map((classDoc) {
            final classData = classDoc.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${classData['name']} (Kết thúc: ${_formatDate(classData['endDate'])})',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
  Widget _buildCoursesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('class')
          .where('coachId', isEqualTo: _coachId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final classes = snapshot.data!.docs;
        if (classes.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có khóa học nào',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: classes.length,
          itemBuilder: (context, index) {
            final classData = classes[index].data() as Map<String, dynamic>;
            return _buildCourseCard(classes[index].id, classData);
          },
        );
      },
    );
  }

  Widget _buildCourseCard(String classId, Map<String, dynamic> classData) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course image with gradient overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Image.network(
                  classData['imageUrl'] ?? 
                  'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Text(
                  classData['name'] ?? 'Khóa học',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price and location row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.attach_money, size: 20, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          '${classData['price']} VND',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 20, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          classData['rental'] ?? 'Chưa có địa điểm',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // End date and members count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          'Kết thúc: ${_formatDate(classData['endDate'])}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 16, color: Colors.purple),
                        const SizedBox(width: 4),
                        Text(
                          '${(classData['members'] as List?)?.length ?? 0} học viên',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Description section
                const Text(
                  'Mô tả khóa học:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  classData['description'] ?? 'Chưa có mô tả',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _editCourse(context, classId, classData),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Chỉnh sửa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _deleteCourse(classId),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Xóa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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

  Widget _buildRequestsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('class')
          .where('coachId', isEqualTo: _coachId)
          .where('pendingRequests', isNotEqualTo: null)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final classes = snapshot.data!.docs;
        if (classes.isEmpty) {
          return const Center(child: Text('Không có yêu cầu nào'));
        }

        // Get all requests from all classes
        final requests = <Map<String, dynamic>>[];
        for (var classDoc in classes) {
          final classData = classDoc.data() as Map<String, dynamic>;
          final pendingRequests = classData['pendingRequests'] as List? ?? [];
          for (var request in pendingRequests) {
            requests.add({
              'classId': classDoc.id,
              'classData': classData,
              'userId': request,
            });
          }
        }

        if (requests.isEmpty) {
          return const Center(child: Text('Không có yêu cầu nào'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users')
                  .doc(request['userId'])
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const ListTile(title: Text('Đang tải...'));
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                return FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('customers')
                      .doc(userData['customerId'])
                      .get(),
                  builder: (context, customerSnapshot) {
                    if (!customerSnapshot.hasData) {
                      return const ListTile(title: Text('Đang tải...'));
                    }

                    final customerData = customerSnapshot.data!.data() as Map<String, dynamic>;
                    return _buildRequestCard(
                      request['classId'],
                      request['classData'],
                      request['userId'],
                      customerData,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRequestCard(
    String classId,
    Map<String, dynamic> classData,
    String userId,
    Map<String, dynamic> customerData,
  ) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yêu cầu tham gia: ${classData['name']}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    customerData['imageUrl'] ?? 
                    'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerData['name'] ?? 'Học viên',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(customerData['email'] ?? ''),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _handleRequest(classId, userId, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Chấp nhận'),
                ),
                ElevatedButton(
                  onPressed: () => _handleRequest(classId, userId, false),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Từ chối'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRequest(String classId, String userId, bool accept) async {
    final classRef = _firestore.collection('class').doc(classId);
    
    if (accept) {
      // Add to members and remove from pendingRequests
      await classRef.update({
        'members': FieldValue.arrayUnion([userId]),
        'pendingRequests': FieldValue.arrayRemove([userId]),
      });
    } else {
      // Just remove from pendingRequests
      await classRef.update({
        'pendingRequests': FieldValue.arrayRemove([userId]),
      });
    }
  }
  Future<void> _editCourse(BuildContext context, String classId, Map<String, dynamic> classData) async {
    final nameController = TextEditingController(text: classData['name']);
    final priceController = TextEditingController(text: classData['price']);
    final descController = TextEditingController(text: classData['description']);
    final benefitsController = TextEditingController(text: classData['benefits']);
    final reqController = TextEditingController(text: classData['requirements']);
    final rentalController = TextEditingController(text: classData['location']);
    final endDateController = TextEditingController(text: classData['endDate']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa khóa học'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên khóa học'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Giá'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: rentalController,
                decoration: const InputDecoration(labelText: 'Địa điểm'),
              ),
              TextField(
                controller: endDateController,
                decoration: const InputDecoration(labelText: 'Ngày kết thúc (MM/dd/yyyy)'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
              ),
              TextField(
                controller: benefitsController,
                decoration: const InputDecoration(labelText: 'Lợi ích'),
                maxLines: 3,
              ),
              TextField(
                controller: reqController,
                decoration: const InputDecoration(labelText: 'Yêu cầu'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('class').doc(classId).update({
                'name': nameController.text,
                'price': priceController.text,
                'description': descController.text,
                'benefits': benefitsController.text,
                'requirements': reqController.text,
                'location': rentalController.text,
                'endDate': endDateController.text,
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCourse(String classId) async {
    // Show confirmation dialog
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa khóa học?'),
        content: const Text('Bạn có chắc chắn muốn xóa khóa học này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await _firestore.collection('class').doc(classId).delete();
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Không có ngày kết thúc';
    try {
      final date = DateFormat('MM/dd/yyyy').parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}