import 'package:do_an_lt/Customer/PT/contact_pt.dart';
import 'package:do_an_lt/Customer/PT/pt_detail.dart';
import 'package:do_an_lt/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HiredCoachDetailPage extends StatefulWidget {
  final Map<String, dynamic> coachData;
  final String contactId;

  const HiredCoachDetailPage({
    Key? key,
    required this.coachData,
    required this.contactId,
  }) : super(key: key);

  @override
  _HiredCoachDetailPageState createState() => _HiredCoachDetailPageState();
}

class _HiredCoachDetailPageState extends State<HiredCoachDetailPage> {
  int _selectedOption = 0;

  @override
  Widget build(BuildContext context) {
    final coachData = widget.coachData;
    final name = coachData['name'] ?? 'Không có tên';
    final imageUrl = coachData['imageUrl'] ?? '';
    final specializations = List<String>.from(coachData['specializations'] ?? []);
    final experienceYears = coachData['experienceYears'] ?? 'Không có';

    return Scaffold(
      backgroundColor: Colors.transparent, // Xóa background trắng mặc định
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [blue, Colors.black],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent, // Làm trong suốt để hiện gradient
              expandedHeight: 180,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Khối trắng bo góc từ padding xuống dưới cùng
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 150),
                    child: Column(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            specializations.join(', '),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Text(
                          'Kinh nghiệm: $experienceYears',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildOptionItem(Icons.info, 'Thông tin chi tiết', 0),
                        _buildOptionItem(Icons.message, 'Nhắn tin', 1),
                        _buildOptionItem(Icons.star, 'Đánh giá', 2),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 200,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _showCancelConfirmation,
                            child: const Text(
                              'Hủy gói thuê',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Avatar nằm ngoài container trắng
                  Positioned(
                    top: -60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(imageUrl),
                          radius: 60,
                        ),
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

  Widget _buildOptionItem(IconData icon, String text, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedOption = index;
        });
        
        switch(index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PTDetailPage(
                  coachData: widget.coachData,
                  isHired: true,
                ),
              ),
            );
            break;
          case 1: // Nhắn tin
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MessengerPage(
                  contactId: widget.contactId,
                  coachId: widget.coachData['id'],
                  coachName: widget.coachData['name'],
                  coachImageUrl: widget.coachData['imageUrl'],
                ),
              ),
            );
            break;
          case 2: // Đánh giá
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CoachReviewsPage(
                  coachId: widget.coachData['id'],
                ),
              ),
            );
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _selectedOption == index ? blue : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: blue),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận hủy gói'),
          content: const Text('Bạn có chắc chắn muốn hủy gói thuê huấn luyện viên này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: _cancelHire,
              child: const Text('Có', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelHire() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('contacts')
          .doc(widget.contactId)
          .delete();

      Navigator.pop(context); // Đóng dialog
      Navigator.pop(context); // Quay lại trang trước
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã hủy gói thuê thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi hủy gói: $e')),
      );
    }
  }
}

class CoachReviewsPage extends StatefulWidget {
  final String coachId;

  const CoachReviewsPage({Key? key, required this.coachId}) : super(key: key);

  @override
  _CoachReviewsPageState createState() => _CoachReviewsPageState();
}

class _CoachReviewsPageState extends State<CoachReviewsPage> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;
  DocumentSnapshot? _existingReview;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkExistingReview();
  }

  Future<void> _checkExistingReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final customerQuery = await FirebaseFirestore.instance
          .collection('customers')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (customerQuery.docs.isNotEmpty) {
        final customerId = customerQuery.docs.first.id;
        
        final reviewQuery = await FirebaseFirestore.instance
            .collection('reviews')
            .where('coachId', isEqualTo: widget.coachId)
            .where('customerId', isEqualTo: customerId)
            .limit(1)
            .get();

        if (reviewQuery.docs.isNotEmpty) {
          setState(() {
            _existingReview = reviewQuery.docs.first;
            _rating = _existingReview!['rate'] ?? 0;
            _reviewController.text = _existingReview!['text'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error checking existing review: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá huấn luyện viên'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                          Text(
                            _existingReview != null 
                                ? 'Đánh giá của bạn'
                                : 'Viết đánh giá của bạn',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (index) {
                                return IconButton(
                                  icon: Icon(
                                    index < _rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _rating = index + 1;
                                    });
                                  },
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _reviewController,
                            decoration: InputDecoration(
                              hintText: 'Nhập đánh giá của bạn...',
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            maxLines: 3,
                            minLines: 3,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              if (_existingReview != null)
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      side: BorderSide(color: Colors.red.shade400),
                                    ),
                                    onPressed: _deleteReview,
                                    child: Text(
                                      'Xóa đánh giá',
                                      style: TextStyle(
                                        color: Colors.red.shade400,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              if (_existingReview != null) const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: blue,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: _submitReview,
                                  child: Text(
                                    _existingReview != null 
                                        ? 'Cập nhật' 
                                        : 'Gửi đánh giá',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tất cả đánh giá',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reviews')
                        .where('coachId', isEqualTo: widget.coachId)
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

                      final sortedReviews = snapshot.data!.docs..sort((a, b) {
                        final aDate = (a.data() as Map<String, dynamic>)['rateDay'] as Timestamp;
                        final bDate = (b.data() as Map<String, dynamic>)['rateDay'] as Timestamp;
                        return bDate.compareTo(aDate);
                      });

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sortedReviews.length,
                        itemBuilder: (context, index) {
                          final review = sortedReviews[index];
                          final data = review.data() as Map<String, dynamic>;
                          
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('customers')
                                .doc(data['customerId'])
                                .get(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                return const Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(child: CircularProgressIndicator()),
                                  ),
                                );
                              }

                              if (!userSnapshot.hasData) {
                                return const SizedBox.shrink();
                              }

                              final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                              final userName = userData['name'] ?? 'Khách';
                              final userImage = userData['imageUrl'] ?? 'https://via.placeholder.com/150';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(userImage),
                                            radius: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  userName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  DateFormat('dd/MM/yyyy HH:mm').format(
                                                    (data['rateDay'] as Timestamp).toDate(),
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (_existingReview?.id == review.id)
                                            Icon(
                                              Icons.check_circle,
                                              color: blue,
                                              size: 20,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: List.generate(5, (i) {
                                          return Icon(
                                            i < (data['rate'] as int? ?? 0)
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 20,
                                          );
                                        }),
                                      ),
                                      const SizedBox(height: 12),
                                      if (data['text'] != null && 
                                          data['text'].toString().isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            data['text'].toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao đánh giá')),
      );
      return;
    }

    if (_reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung đánh giá')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để đánh giá')),
        );
        return;
      }

      final customerQuery = await FirebaseFirestore.instance
          .collection('customers')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (customerQuery.docs.isEmpty) {
        throw Exception('Không tìm thấy thông tin khách hàng');
      }

      final customerId = customerQuery.docs.first.id;

      if (_existingReview != null) {
        await FirebaseFirestore.instance
            .collection('reviews')
            .doc(_existingReview!.id)
            .update({
          'text': _reviewController.text,
          'rate': _rating,
          'rateDay': Timestamp.now(),
        });
      } else {
        await FirebaseFirestore.instance.collection('reviews').add({
          'coachId': widget.coachId,
          'customerId': customerId,
          'text': _reviewController.text,
          'rate': _rating,
          'rateDay': Timestamp.now(),
        });
      }

      await _updateCoachRating();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_existingReview != null 
              ? 'Đã cập nhật đánh giá thành công' 
              : 'Đã gửi đánh giá thành công'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await _checkExistingReview();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteReview() async {
    if (_existingReview == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa đánh giá này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(_existingReview!.id)
          .delete();

      await _updateCoachRating();

      setState(() {
        _existingReview = null;
        _rating = 0;
        _reviewController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa đánh giá thành công'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xóa đánh giá: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateCoachRating() async {
    final reviews = await FirebaseFirestore.instance
        .collection('reviews')
        .where('coachId', isEqualTo: widget.coachId)
        .get();

    if (reviews.docs.isEmpty) {
      await FirebaseFirestore.instance
          .collection('coachs')
          .doc(widget.coachId)
          .update({'rate': 0});
      return;
    }

    double total = 0;
    for (var doc in reviews.docs) {
      total += (doc.data()['rate'] as int).toDouble();
    }
    final averageRating = total / reviews.docs.length;

    await FirebaseFirestore.instance
        .collection('coachs')
        .doc(widget.coachId)
        .update({'rate': averageRating});
  }
}