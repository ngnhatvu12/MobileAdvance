import 'package:do_an_lt/Customer/PT/customer_pt.dart';
import 'package:flutter/material.dart';
import 'package:do_an_lt/theme/colors.dart';

class PTDetailPage extends StatelessWidget {
  final Map<String, dynamic> coachData;

  const PTDetailPage({Key? key, required this.coachData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    final packagePrices = List<String>.from(coachData['packagePrices'] ?? []);

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
      body: SingleChildScrollView(
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
                    width: 50, // Điều chỉnh kích thước theo ý muốn
                    height: 50,
                    child: Image.asset('assets/icons/facebook.png'),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                 icon: SizedBox(
                  width: 50, // Điều chỉnh kích thước theo ý muốn
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
      bottomNavigationBar: _buildBottomBar(context, packagePrices),
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
            child: MarqueeWidget(
              child: Text(value, style: const TextStyle(fontSize: 16)),
            ),
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

  Widget _buildBottomBar(BuildContext context, List<String> packages) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          _showPackageDialog(context, packages);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: const Text(
          'Chọn gói và thanh toán',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showPackageDialog(BuildContext context, List<String> packages) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: packages.map((pkg) => ListTile(title: Text(pkg))).toList(),
        );
      },
    );
  }
}
