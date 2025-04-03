import 'package:do_an_lt/guess_page.dart';
import 'package:do_an_lt/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CoachProfilePage extends StatefulWidget {
  const CoachProfilePage({super.key});

  @override
  State<CoachProfilePage> createState() => _CoachProfilePageState();
}

class _CoachProfilePageState extends State<CoachProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _coachId;

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
            colors: [red, Color.fromARGB(255, 123, 14, 14)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Logout button at top right
              Padding(
                padding: const EdgeInsets.only(top: 40, right: 16),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () => GuessPage()
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: _firestore.collection('coachs').doc(_coachId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (!snapshot.data!.exists) {
                      return const Center(child: Text('Không tìm thấy hồ sơ huấn luyện viên'));
                    }

                    final coachData = snapshot.data!.data() as Map<String, dynamic>;
                    final profilePhotos = (coachData['profilePhoto'] as List?) ?? [];
                    
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // White container
                        Container(
                          margin: const EdgeInsets.only(top: 60),
                          padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: _buildProfileContent(coachData),
                        ),
                        
                        // Profile avatar using imageUrl
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(
                              coachData['imageUrl'] ?? 
                              'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> coachData) {
    final specializations = (coachData['specializations'] as List?) ?? [];
    final profilePhotos = (coachData['profilePhoto'] as List?) ?? [];
    
    return Column(
      children: [
        // Name and specializations
        Text(
          coachData['name'] ?? 'Huấn luyện viên',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          specializations.join(', '),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        
        // Stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              coachData['averageRating']?.toString() ?? '5.0',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.people, color: Colors.blue, size: 20),
            const SizedBox(width: 4),
            const Text('45', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            const Icon(Icons.work, color: Colors.green, size: 20),
            const SizedBox(width: 4),
            Text(
              '${coachData['experienceYears'] ?? '5'} năm',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Edit profile button
        Align(
          alignment: Alignment.topRight,
          child: TextButton.icon(
            onPressed: () => _showEditProfileDialog(context),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Chỉnh sửa'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ),
        
        // Personal Info Section
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin cá nhân',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoItem(Icons.email, 'Email', coachData['email'] ?? 'Chưa có'),
                _buildInfoItem(Icons.phone, 'Số điện thoại', coachData['phoneNumber'] ?? 'Chưa có'),
                _buildInfoItem(Icons.cake, 'Tuổi', coachData['birthDate']?.toString() ?? 'Chưa có'),
                _buildInfoItem(Icons.transgender, 'Giới tính', coachData['gender'] ?? 'Chưa có'),
                _buildInfoItem(Icons.location_on, 'Địa chỉ', coachData['address'] ?? 'Chưa có'),
                _buildInfoItem(Icons.fitness_center, 'Phòng tập', coachData['gymAffiliation'] ?? 'Chưa có'),
                _buildInfoItem(Icons.access_time, 'Lịch làm việc', coachData['time'] ?? 'Chưa có'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Profile Photos Section
        if (profilePhotos.isNotEmpty) ...[
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hình ảnh hồ sơ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: profilePhotos.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _showPhotoDialog(context, profilePhotos[index]),
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(profilePhotos[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Certifications Section
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bằng cấp & Chứng chỉ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if ((coachData['certifications'] as List?)?.isEmpty ?? true)
                  const Text('Chưa có chứng chỉ nào', style: TextStyle(color: Colors.grey))
                else
                  Column(
                    children: (coachData['certifications'] as List).map((cert) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.verified, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(cert.toString())),
                        ],
                      ),
                    )).toList(),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Bio Section
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Giới thiệu bản thân',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  coachData['bio']?.toString() ?? 'Chưa có thông tin giới thiệu',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Package Prices
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gói tập luyện',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if ((coachData['packagePrices'] as List?)?.isEmpty ?? true)
                  const Text('Chưa có gói tập nào', style: TextStyle(color: Colors.grey))
                else
                  Column(
                    children: (coachData['packagePrices'] as List).map((pkg) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_money, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(pkg.toString()),
                        ],
                      ),
                    )).toList(),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Community Section
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Bài viết cộng đồng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => _showCreatePostDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Tạo bài viết mới', style: TextStyle(color: Colors.white)),
        ),

        const SizedBox(height: 20),

        // Network Section
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Mạng lưới HLV',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('coachs')
                .where('id', isNotEqualTo: _coachId)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final coaches = snapshot.data!.docs;
              if (coaches.isEmpty) {
                return const Center(child: Text('Không có HLV nào khác'));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: coaches.length,
                itemBuilder: (context, index) {
                  final coach = coaches[index].data() as Map<String, dynamic>;
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            coach['imageUrl'] ?? 
                            'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          coach['name'] ?? 'HLV',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPhotoDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Hình ảnh'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Image.network(
              imageUrl,
              fit: BoxFit.contain,
              height: 300,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final coachRef = _firestore.collection('coachs').doc(_coachId);
    
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<DocumentSnapshot>(
          future: coachRef.get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final coachData = snapshot.data!.data() as Map<String, dynamic>;
            final nameController = TextEditingController(text: coachData['name']);
            final bioController = TextEditingController(text: coachData['bio']);
            final phoneController = TextEditingController(text: coachData['phoneNumber']);
            final addressController = TextEditingController(text: coachData['address']);
            final gymController = TextEditingController(text: coachData['gymAffiliation']);

            return AlertDialog(
              title: const Text('Chỉnh sửa hồ sơ'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Họ và tên'),
                    ),
                    TextField(
                      controller: bioController,
                      decoration: const InputDecoration(labelText: 'Giới thiệu bản thân'),
                      maxLines: 3,
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Số điện thoại'),
                      keyboardType: TextInputType.phone,
                    ),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Địa chỉ'),
                    ),
                    TextField(
                      controller: gymController,
                      decoration: const InputDecoration(labelText: 'Phòng tập'),
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
                    await coachRef.update({
                      'name': nameController.text,
                      'bio': bioController.text,
                      'phoneNumber': phoneController.text,
                      'address': addressController.text,
                      'gymAffiliation': gymController.text,
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    final contentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo bài viết mới'),
        content: TextField(
          controller: contentController,
          decoration: const InputDecoration(
            hintText: 'Chia sẻ kiến thức của bạn...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (contentController.text.isNotEmpty) {
                await _firestore.collection('community_posts').add({
                  'content': contentController.text,
                  'authorId': _auth.currentUser?.uid,
                  'author': _auth.currentUser?.displayName ?? 'Huấn luyện viên',
                  'date': DateTime.now(),
                  'likes': [],
                  'comments': [],
                  'type': 'coach',
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đăng bài', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}