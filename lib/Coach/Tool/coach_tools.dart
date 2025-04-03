import 'package:do_an_lt/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoachToolsPage extends StatefulWidget {
  const CoachToolsPage({super.key});

  @override
  State<CoachToolsPage> createState() => _CoachToolsPageState();
}

class _CoachToolsPageState extends State<CoachToolsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedTab = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
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
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    _buildTabButton(0, 'Bài tập'),
                    const SizedBox(width: 30),
                    _buildTabButton(1, 'Dinh dưỡng'),
                    const SizedBox(width: 30),
                    _buildTabButton(2, 'Báo cáo'),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedTab = index;
                    });
                  },
                  children: [
                    // Tab 1: Bài tập
                    _buildWorkoutTab(),
                    // Tab 2: Dinh dưỡng
                    _buildNutritionTab(),
                    // Tab 3: Báo cáo
                    _buildReportTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
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

  Widget _buildWorkoutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thư viện bài tập
          const Text(
            'Thư viện bài tập',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 150,
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('exercises').limit(10).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final exercises = snapshot.data!.docs;
                
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index].data() as Map<String, dynamic>;
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 10),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: Image.network(
                                  exercise['imageUrl'] ?? 'https://via.placeholder.com/150',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                exercise['name'] ?? 'Bài tập',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 25),
          
          // Tạo bài tập mới
          const Text(
            'Tạo bài tập mới',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () => _showCreateExerciseDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size(double.infinity, 50),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text('+ Tạo bài tập mới', 
              style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          
          const SizedBox(height: 25),
          
          // Bài tập đã tạo
          const Text(
            'Bài tập của bạn',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('workouts')
                .where('coachId', isEqualTo: _auth.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final workouts = snapshot.data!.docs;
              
              if (workouts.isEmpty) {
                return Center(
                  child: Text('Chưa có bài tập nào',
                    style: TextStyle(color: Colors.grey[600])),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  final workout = workouts[index].data() as Map<String, dynamic>;
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.fitness_center, color: Colors.red),
                      ),
                      title: Text(workout['name'] ?? 'Bài tập',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${workout['difficulty']} - ${workout['duration']} phút'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteWorkout(workouts[index].id),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thực đơn mẫu
          const Text(
            'Thực đơn mẫu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildMealPlanCard('Tăng cơ', '3000 kcal', Colors.blue),
              _buildMealPlanCard('Giảm mỡ', '1800 kcal', Colors.green),
              _buildMealPlanCard('Cân bằng', '2200 kcal', Colors.orange),
              _buildMealPlanCard('Duy trì', '2500 kcal', Colors.purple),
            ],
          ),
          
          const SizedBox(height: 25),
          
          // Gửi thực đơn
          const Text(
            'Gửi thực đơn cá nhân',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () => _showSendMealPlanDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size(double.infinity, 50),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text('Gửi thực đơn', 
              style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Biểu đồ tiến độ
          const Text(
            'Tiến độ học viên',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('students')
                .where('coachId', isEqualTo: _auth.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final students = snapshot.data!.docs;
              
              if (students.isEmpty) {
                return Center(
                  child: Text('Chưa có học viên nào',
                    style: TextStyle(color: Colors.grey[600])),
                );
              }
              
              return Column(
                children: [
                  // Placeholder cho biểu đồ
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('Biểu đồ tiến độ sẽ hiển thị ở đây',
                            style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Danh sách học viên
                  const Text(
                    'Danh sách học viên',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index].data() as Map<String, dynamic>;
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: Colors.red),
                          ),
                          title: Text(student['name'] ?? 'Học viên',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Mục tiêu: ${student['goal'] ?? 'Chưa có'}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.trending_up, color: Colors.red),
                            onPressed: () => _showStudentProgress(context, students[index].id),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlanCard(String title, String calories, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.restaurant, color: color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16),
            ),
            Text(
              calories,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14),
            ),
            const SizedBox(height: 10),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => _showMealPlanDetails(title),
              child: const Text('Xem chi tiết'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateExerciseDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo bài tập mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên bài tập'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              const Text('Thêm video hướng dẫn:'),
              IconButton(
                icon: const Icon(Icons.video_library, size: 40),
                onPressed: () {}, // Thêm chức năng upload video
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
              if (nameController.text.isNotEmpty) {
                await _firestore.collection('workouts').add({
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'coachId': _auth.currentUser?.uid,
                  'createdAt': DateTime.now(),
                  'difficulty': 'Trung bình',
                  'duration': 30,
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSendMealPlanDialog(BuildContext context) {
    final studentController = TextEditingController();
    final planController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gửi thực đơn'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('students')
                    .where('coachId', isEqualTo: _auth.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  
                  final students = snapshot.data!.docs;
                  
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Chọn học viên'),
                    items: students.map((doc) {
                      final student = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(student['name'] ?? 'Học viên'),
                      );
                    }).toList(),
                    onChanged: (value) {},
                  );
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: planController,
                decoration: const InputDecoration(labelText: 'Nội dung thực đơn'),
                maxLines: 5,
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
              if (planController.text.isNotEmpty) {
                // Gửi thực đơn cho học viên
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã gửi thực đơn thành công')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Gửi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMealPlanDetails(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thực đơn $title'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bữa sáng:'),
              const Text('- 2 quả trứng luộc'),
              const Text('- 1 lát bánh mì đen'),
              const SizedBox(height: 10),
              const Text('Bữa trưa:'),
              const Text('- 150g ức gà'),
              const Text('- 100g cơm gạo lứt'),
              const SizedBox(height: 10),
              const Text('Bữa tối:'),
              const Text('- 200g cá hồi'),
              const Text('- Rau xanh các loại'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showStudentProgress(BuildContext context, String studentId) {
    // Hiển thị chi tiết tiến độ học viên
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tiến độ học viên'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Placeholder cho biểu đồ chi tiết
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text('Biểu đồ chi tiết tiến độ')),
              ),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cân nặng: 70kg'),
                  Text('BMI: 22.5'),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Số buổi tập: 12'),
                  Text('Tỉ lệ hoàn thành: 85%'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWorkout(String workoutId) async {
    await _firestore.collection('workouts').doc(workoutId).delete();
  }
}