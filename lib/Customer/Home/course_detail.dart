import 'package:do_an_lt/Customer/Home/class_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: jsonResponse['client_secret'],
        merchantDisplayName: 'Yoga Courses',
      ),
    );

    // Hiển thị Payment Sheet
    await Stripe.instance.presentPaymentSheet();
    // Thêm user vào class được chọn
    await addUserToCourse(user.uid, widget.classId);
     Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ClassManager(initialTabIndex: 1), // Tab "Khóa học của tôi"
      ),
    );
    setState(() {
      widget.members.add(user.uid); // Cập nhật UI
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey,
                      child: const Center(child: Icon(Icons.error)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tên khóa học
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Mô tả khóa học
                Text(
                  widget.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Mục tiêu khóa học
                const Text(
                  'Mục tiêu khóa học:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.goals,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Lợi ích khóa học
                const Text(
                  'Lợi ích khóa học:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.benefits,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Yêu cầu
                const Text(
                  'Yêu cầu:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.requirements,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Địa điểm
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 20, color: Colors.red),
                    const SizedBox(width: 10),
                    Text(
                      widget.location,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Thời gian
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 20, color: Colors.blueAccent),
                    const SizedBox(width: 10),
                    Text(
                      widget.time,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Số lượng thành viên
                Text(
                  'Thành viên: ${widget.members.length}/20',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              onPressed: makePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Thanh toán ${widget.price} USD'),
            ),
          ),
        ],
      ),
    );
  }
}
