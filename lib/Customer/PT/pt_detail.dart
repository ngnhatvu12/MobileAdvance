import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_lt/Customer/PT/hired_coach_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:do_an_lt/theme/colors.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PTDetailPage extends StatefulWidget {
  final Map<String, dynamic> coachData;
  final bool isHired;

  const PTDetailPage({Key? key, required this.coachData,this.isHired = false,}) : super(key: key);

  @override
  State<PTDetailPage> createState() => _PTDetailPageState();
}

class _PTDetailPageState extends State<PTDetailPage> {
  Map<String, dynamic>? paymentIntent;
  String? selectedPackage;
  String? selectedPrice; 
  List<Map<String, String>> packagePrices = []; 
  double _averageRating = 0;
  int _totalReviews = 0;
  @override
  void initState() {
    super.initState();
    _parsePackagePrices(); 
    _loadReviews();
  }
  void _parsePackagePrices() {
    final packagePricesList = List<String>.from(widget.coachData['packagePrices'] ?? []);
    setState(() {
      packagePrices = packagePricesList.map((pkg) {
        final parts = pkg.split('/'); 
        return {
          'day': parts[0],
          'price': parts[1], 
        };
      }).toList();
    });
  }
  Future<void> _loadReviews() async {
    final reviews = await FirebaseFirestore.instance
        .collection('reviews')
        .where('coachId', isEqualTo: widget.coachData['id'])
        .get();

    if (reviews.docs.isNotEmpty) {
      double total = 0;
      for (var doc in reviews.docs) {
        total += (doc.data()['rate'] as int).toDouble();
      }
      setState(() {
        _averageRating = total / reviews.docs.length;
        _totalReviews = reviews.docs.length;
      });
    }
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
                   _buildProfileHeader(name, imageUrl, bio),
                  const SizedBox(height: 16),
                   _buildSectionCard(
                    title: 'Thông tin liên hệ',
                    children: [
                      _buildInfoItem(Icons.phone, 'Số điện thoại', phoneNumber),
                      _buildInfoItem(Icons.email, 'Email', email),
                      _buildSocialMediaButtons(),
                    ],
                  ),                
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: 'Thông tin chi tiết',
                    children: [
                      _buildInfoItem(Icons.person, 'Giới tính', gender),
                      _buildInfoItem(Icons.cake, 'Tuổi', age),
                      _buildInfoItem(Icons.location_on, 'Địa chỉ', address),
                      _buildInfoItem(Icons.work, 'Kinh nghiệm', '$experienceYears năm'),
                      _buildInfoItem(Icons.schedule, 'Thời gian', time),
                      _buildInfoItem(Icons.star, 'Kỹ năng', specializations.join(', ')),
                      _buildInfoItem(Icons.card_membership, 'Chứng chỉ', certifications.join(', ')),
                    ],
                  ),
                  const SizedBox(height: 30),
                 if (profilePhotos.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Hình ảnh',
                      child: _buildImageGallery(profilePhotos),
                    ),
                  ],
                  const SizedBox(height: 30),
                  if (!widget.isHired) ...[
                   _buildSectionCard(
                      title: 'Đánh giá',
                      children: [
                        _buildRatingSummary(),
                        const SizedBox(height: 16),
                        _buildReviewsList(),
                      ],
                    ),
                ],
                ],
              ),
            ),
          ),
          if (!widget.isHired) _buildFixedBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String name, String imageUrl, String bio) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blue.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
                radius: 60,
                backgroundColor: Colors.grey[200],
              ),
              if (!widget.isHired && _averageRating > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bio,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    Widget? child,
    List<Widget>? children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child ?? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Image.asset('assets/icons/facebook.png', width: 40, height: 40),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Image.asset('assets/icons/ins.png', width: 40, height: 40),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                images[index],
                width: 160,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _averageRating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: blue,
              ),
            ),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < _averageRating.round()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            Text(
              '$_totalReviews đánh giá',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('coachId', isEqualTo: widget.coachData['id'])
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có đánh giá nào',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          children: [
            ...snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _buildReviewItem(data);
            }).toList(),
            
            if (_totalReviews > 3)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CoachReviewsPage(
                        coachId: widget.coachData['id'],
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Xem tất cả đánh giá',
                  style: TextStyle(color: blue),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> reviewData) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('customers')
          .doc(reviewData['customerId'])
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (!userSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final userName = userData['name'] ?? 'Khách';
        final userImage = userData['imageUrl'] ?? 'https://via.placeholder.com/150';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(userImage),
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('dd/MM/yyyy').format(
                      (reviewData['rateDay'] as Timestamp).toDate(),
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < (reviewData['rate'] as int? ?? 0)
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 8),
              if (reviewData['text'] != null && 
                  reviewData['text'].toString().isNotEmpty)
                Text(
                  reviewData['text'].toString(),
                  style: const TextStyle(fontSize: 14),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFixedBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedPackage ?? 'Chọn gói tập',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_drop_down),
                onPressed: () => _showPackageDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedPackage == null ? null : _handlePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedPackage == null ? Colors.grey : blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Đăng ký ngay',
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

  void _showPackageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chọn gói tập',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...packagePrices.map((pkg) {
                final day = pkg['day'] ?? '';
                final price = pkg['price'] ?? '';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: Text(
                    day,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '$price VND',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    setState(() {
                      selectedPackage = day;
                      selectedPrice = price.replaceAll(',', '');
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 16),
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

      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: jsonResponse['client_secret'],
          merchantDisplayName: 'Fitness App',
        ),
      );

      await stripe.Stripe.instance.presentPaymentSheet();
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