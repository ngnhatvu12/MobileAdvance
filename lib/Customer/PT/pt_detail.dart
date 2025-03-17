import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:do_an_lt/theme/colors.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PTDetailPage extends StatefulWidget {
  final Map<String, dynamic> coachData;

  const PTDetailPage({Key? key, required this.coachData}) : super(key: key);

  @override
  State<PTDetailPage> createState() => _PTDetailPageState();
}

class _PTDetailPageState extends State<PTDetailPage> {
  Map<String, dynamic>? paymentIntent;
  String? selectedPackage; // Gói được chọn
  String? selectedPrice; // Giá của gói đã chọn
  List<Map<String, String>> packagePrices = []; // Danh sách các gói

  @override
  void initState() {
    super.initState();
    _parsePackagePrices(); // Phân tích dữ liệu packagePrices khi khởi tạo
  }

  // Hàm phân tích dữ liệu packagePrices từ coachData
  void _parsePackagePrices() {
    final packagePricesList = List<String>.from(widget.coachData['packagePrices'] ?? []);
    setState(() {
      packagePrices = packagePricesList.map((pkg) {
        final parts = pkg.split('/'); // Tách chuỗi bằng dấu "/"
        return {
          'day': parts[0], // Phần trước dấu "/" là số ngày
          'price': parts[1], // Phần sau dấu "/" là giá
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final coachData = widget.coachData;
    final name = coachData['name'] ?? 'Không có tên';
    final bio = coachData['bio'] ?? 'Không có mô tả';
    final imageUrl = coachData['imageUrl'] ?? '';
    final phoneNumber = coachData['phoneNumber'] ?? 'Không có';
    final email = coachData['email'] ?? 'Không có';
    final gender = coachData['gender'] ?? 'Không xác định';
    final age = coachData['birthDate'] ?? 'Không có tuổi';
    final address = coachData['address'] ?? 'Không có địa chỉ';
    final certifications = List<String>.from(coachData['certifications'] ?? []);
    final specializations = List<String>.from(coachData['specializations'] ?? []);
    final experienceYears = coachData['experienceYears'] ?? 'Không có';
    final time = coachData['time'] ?? 'Không có';
    final profilePhotos = List<String>.from(coachData['profilePhoto'] ?? []);
    final rating = coachData['rate'] ?? 0;
    final reviews = List<String>.from(coachData['reviews'] ?? []);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Huấn luyện viên', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(name, imageUrl, bio),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Thông tin liên hệ'),
                  _buildInfoRow('Số điện thoại', phoneNumber),
                  _buildInfoRow('Email', email),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset('assets/icons/facebook.png'),
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset('assets/icons/ins.png'),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Thông tin chi tiết'),
                  _buildScrollableInfoRow('Giới tính', gender),
                  _buildScrollableInfoRow('Tuổi', age),
                  _buildScrollableInfoRow('Địa chỉ', address),
                  _buildScrollableInfoRow('Chứng chỉ', certifications.join(', ')),
                  _buildScrollableInfoRow('Kỹ năng', specializations.join(', ')),
                  _buildScrollableInfoRow('Kinh nghiệm', '$experienceYears năm'),
                  _buildScrollableInfoRow('Thời gian', time),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Hình ảnh'),
                  _buildImageSlider(profilePhotos),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Đánh giá và phản hồi'),
                  Text('⭐ $rating / 5.0', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...reviews.map((review) => _buildReviewCard(review)).toList(),
                ],
              ),
            ),
          ),
          _buildFixedBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, String imageUrl, String bio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
          radius: 80,
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          bio,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlider(List<String> images) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(images[index], height: 100),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(String review) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        review,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildFixedBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nửa trên: Chữ và nút mũi tên
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Vui lòng lựa chọn gói',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_drop_down, size: 30),
                onPressed: () {
                  _showPackageDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Nửa dưới: Nút đăng ký
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedPackage == null
                  ? null
                  : () {
                      _handlePayment();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedPackage == null ? Colors.grey : blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Đăng ký',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPackageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chọn gói tập',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...packagePrices.map((pkg) {
                final day = pkg['day'] ?? 'Không có thông tin';
                final price = pkg['price'] ?? 'Không có thông tin';
                return ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: Text(
                    day,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '$price VND',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  onTap: () {
                    setState(() {
                      selectedPackage = day; // Lưu gói được chọn
                      selectedPrice = price.replaceAll(',', ''); // Lưu giá (loại bỏ dấu phẩy)
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handlePayment() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn cần đăng nhập để thanh toán!')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer sk_test_51QHQ0IGVyUQsdJTU1qOVMdRrplEbGWsZC6fcZk9UTajsUkljyutoPhNd1uaDi8VksmDaxJc5N0F9t2j7Wp234exh00oc5Bwib3',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (double.parse(selectedPrice!) * 100).toStringAsFixed(0),
          'currency': 'vnd', // Sử dụng đồng tiền Việt Nam
        },
      );

      if (response.statusCode != 200) {
        throw 'Failed to create payment intent';
      }

      final jsonResponse = json.decode(response.body);
      paymentIntent = jsonResponse;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: jsonResponse['client_secret'],
          merchantDisplayName: 'Fitness App',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      // Lấy thời gian hiện tại
    final now = DateTime.now();
    final startDate = DateFormat('yyyy-MM-dd').format(now);

    // Tính toán endDate dựa trên số ngày trong package
    final days = int.parse(selectedPackage!.split(' ')[0]);
    final endDate = DateFormat('yyyy-MM-dd').format(now.add(Duration(days: days)));
    // Thêm document vào Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('contacts')
        .add({
          'coachId': widget.coachData['id'], // Giả sử coachData có trường 'id'
          'startDate': startDate,
          'endDate': endDate,
        });
      _showSuccessDialog();
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thanh toán thất bại: $err')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thanh toán thành công!'),
          content: const Text('Bạn đã đăng ký gói tập thành công. Hẹn gặp bạn ở phòng tập!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}