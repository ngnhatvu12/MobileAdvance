import 'package:do_an_lt/Customer/Home/class_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe ;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:do_an_lt/theme/colors.dart';

class CourseDetail extends StatefulWidget {
  final String classId;
  final String imageUrl;
  final String name;
  final String description;
  final String location;
  final String time;
  final List<dynamic> members;
  final String price;
  final String goals;
  final String benefits;
  final String requirements;

  const CourseDetail({
    Key? key,
    required this.classId,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.location,
    required this.time,
    required this.members,
    required this.price,
    required this.goals,
    required this.benefits,
    required this.requirements,
  }) : super(key: key);

  @override
  State<CourseDetail> createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail> {
  Map<String, dynamic>? paymentIntent;
  bool _isMember = false;
  @override
  void initState() {
    super.initState();
    _checkMembership();
  }

  void _checkMembership() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && widget.members.contains(user.uid)) {
      setState(() {
        _isMember = true;
      });
    }
  }

  Future<void> makePayment() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn cần đăng nhập để thanh toán!')),
        );
        return;
      }

      // Gửi request đến Stripe để tạo payment intent
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer sk_test_51QHQ0IGVyUQsdJTU1qOVMdRrplEbGWsZC6fcZk9UTajsUkljyutoPhNd1uaDi8VksmDaxJc5N0F9t2j7Wp234exh00oc5Bwib3',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (double.parse(widget.price) * 100).toStringAsFixed(0),
          'currency': 'usd',
        },
      );

      if (response.statusCode != 200) {
        throw 'Failed to create payment intent';
      }

      final jsonResponse = json.decode(response.body);
      paymentIntent = jsonResponse;

      // Khởi tạo Payment Sheet
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: jsonResponse['client_secret'],
          merchantDisplayName: 'Yoga Courses',
        ),
      );

      // Hiển thị Payment Sheet
      await stripe.Stripe.instance.presentPaymentSheet();
      // Thêm user vào class được chọn
      await addUserToCourse(user.uid, widget.classId);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ClassManager(initialTabIndex: 1), // Tab "Khóa học của tôi"
        ),
      );
      setState(() {
        _isMember = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanh toán thành công! Bạn đã được thêm vào khóa học.')),
      );
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $err')),
      );
    }
  }

  Future<void> addUserToCourse(String userId, String classId) async {
    try {
      final courseRef = FirebaseFirestore.instance.doc('/class/$classId');
      await courseRef.update({
        'members': FieldValue.arrayUnion([userId]),
      });
      print('User $userId đã được thêm vào lớp $classId.');
    } catch (e) {
      print('Lỗi khi thêm user vào lớp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isRegistered = user != null && widget.members.contains(user.uid);

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header với gradient và nút back
                Container(
                  padding: const EdgeInsets.only(
                    top: 30, 
                    left: 16, 
                    right: 16, 
                    bottom: 20
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [blue, const Color.fromARGB(255, 1, 3, 113)],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Nội dung chi tiết
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh lớp học
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.imageUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 220,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Giá và trạng thái
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${widget.price} USD',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  if (isRegistered)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12, 
                                        vertical: 6
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.green),
                                      ),
                                      child: const Text(
                                        'Đã đăng ký',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 15),

                              // Địa điểm
                              _buildInfoRow(
                                icon: Icons.location_on,
                                iconColor: Colors.red,
                                text: widget.location,
                              ),
                              const SizedBox(height: 10),

                              // Thời gian
                              _buildInfoRow(
                                icon: Icons.access_time,
                                iconColor: Colors.blue,
                                text: widget.time,
                              ),
                              const SizedBox(height: 10),

                              // Số lượng thành viên
                              _buildInfoRow(
                                icon: Icons.people,
                                iconColor: Colors.purple,
                                text: '${widget.members.length}/20 thành viên',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Mô tả
                      _buildSection(
                        title: 'Mô tả khóa học',
                        content: widget.description,
                      ),
                      const SizedBox(height: 20),

                      // Mục tiêu
                      _buildSection(
                        title: 'Mục tiêu',
                        content: widget.goals,
                      ),
                      const SizedBox(height: 20),

                      // Lợi ích
                      _buildSection(
                        title: 'Lợi ích',
                        content: widget.benefits,
                      ),
                      const SizedBox(height: 20),

                      // Yêu cầu
                      _buildSection(
                        title: 'Yêu cầu',
                        content: widget.requirements,
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Nút thanh toán (chỉ hiển thị nếu chưa đăng ký)
          if (!isRegistered && user != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: ElevatedButton(
                onPressed: makePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'ĐĂNG KÝ NGAY',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}