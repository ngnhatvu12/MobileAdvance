import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:do_an_lt/theme/colors.dart';
import 'package:intl/intl.dart';
class NutritionPage extends StatefulWidget {
  @override
  _NutritionPageState createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> with SingleTickerProviderStateMixin {
  String _currentTab = 'Kế hoạch';
  int _selectedIndex = 0; // Mặc định vào tab đầu tiên
  final List<String> _tabs = ['Kế hoạch', 'Món ăn', 'Cộng đồng'];
  late TabController _tabController;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  bool isCreatingPlan = false;
  bool isViewingPlan = false;
  String? _selectedPlanId;
  String? _selectedPlanName;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool useExistingPlan = false;
  bool assignToTrainer = false;
  String? _imageUrl;
  bool _isNameEmpty = false;
//Trường xử lý thêm món ăn
  bool _isCreatingMeal = false;
  bool _isEditingMeal = false;
  String? _editingMealId;
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _mealGramsController = TextEditingController();
  final TextEditingController _mealCaloriesController = TextEditingController();
  final TextEditingController _mealProteinController = TextEditingController();
  final TextEditingController _mealCarbsController = TextEditingController();
  final TextEditingController _mealFatController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _mealNameController.dispose();
    _mealGramsController.dispose();
    _mealCaloriesController.dispose();
    _mealProteinController.dispose();
    _mealCarbsController.dispose();
    _mealFatController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: isCreatingPlan ? _buildCreatePlanPage() : (isViewingPlan ? _buildPlanDetailPage() : _buildMainPage()),
  );
}

Widget _buildMainPage() {
  return Container(
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
        _buildScrollableTopBar(),
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
  );
}

Widget _buildScrollableTopBar() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: _tabs.map((tab) {
        final isSelected = _tabs.indexOf(tab) == _selectedIndex;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = _tabs.indexOf(tab);
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
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
  );
}

Widget _buildTabContent() {
  switch (_selectedIndex) {
    case 0:
      return _buildPlanTab();
    case 1:
      return _buildMealTab();
    case 2:
      return _buildCommunityTab();
    default:
      return Center(child: Text('Không có dữ liệu'));
  }
}

  Widget _buildPlanTab() {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Tìm kiếm...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Gần đây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {},
            ),
          ],
        ),
      ),
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('nutritions')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Không có kế hoạch nào.'));
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final nutrition = snapshot.data!.docs[index];
                final data = nutrition.data() as Map<String, dynamic>;
                return InkWell(
                  onTap: () {
                    setState(() {
                      isViewingPlan = true;
                      _selectedPlanId = nutrition.id;
                      _selectedPlanName = data['name'];
                    });
                  },
                  child: Card(
                    margin: EdgeInsets.all(10),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Hình ảnh vuông bo góc
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              data['imageUrl'] ?? 'https://via.placeholder.com/150', // URL ảnh mặc định nếu không có
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16), // Khoảng cách giữa ảnh và text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? 'Không có tên',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  data['description'] ?? 'Không có mô tả',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              isCreatingPlan = true;
            });
          },
          child: Text('Tạo kế hoạch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            backgroundColor: Colors.blueAccent,
          ),
        ),
      ),
    ],
  );
}
 Widget _buildPlanDetailPage() {
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [blue, Colors.black],
        ),
      ),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('nutritions')
            .doc(_selectedPlanId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('Không tìm thấy kế hoạch'));
          }

          final planData = snapshot.data!.data() as Map<String, dynamic>;
          final createdAt = (planData['createdAt'] as Timestamp).toDate();
          final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

          // Cập nhật giá trị controller nếu có dữ liệu mới
          if (!_nameController.text.isNotEmpty) {
            _nameController.text = planData['name'] ?? '';
            _descriptionController.text = planData['description'] ?? '';
            _imageUrl = planData['imageUrl'];
          }

          return Column(
            children: [
              // Phần header với nút back và tên kế hoạch
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () {
                        setState(() {
                          isViewingPlan = false;
                          _selectedPlanId = null;
                          _selectedPlanName = null;
                          _nameController.clear();
                          _descriptionController.clear();
                        });
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Chi tiết kế hoạch',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Khối nội dung chính với background trắng
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  margin: EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      // Tab chuyển đổi
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () => setState(() => _currentTab = 'Kế hoạch'),
                              child: Text(
                                'Kế hoạch',
                                style: TextStyle(
                                  color: _currentTab == 'Kế hoạch' ? blue : Colors.grey,
                                  fontSize: 20,
                                  fontWeight: _currentTab == 'Kế hoạch' ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(() => _currentTab = 'Chi tiết'),
                              child: Text(
                                'Chi tiết',
                                style: TextStyle(
                                  color: _currentTab == 'Chi tiết' ? blue : Colors.grey,
                                  fontSize: 20,
                                  fontWeight: _currentTab == 'Chi tiết' ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Nội dung tab
                      Expanded(
                        child: _currentTab == 'Chi tiết'
                            ? SingleChildScrollView(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Ảnh kế hoạch
                                    GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        height: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.grey[200],
                                          image: _imageUrl != null
                                            ? DecorationImage(
                                                image: NetworkImage(_imageUrl!),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                        ),
                                        child: _imageUrl == null
                                          ? Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                                                  Text('Thêm ảnh', style: TextStyle(color: Colors.grey)),
                                                ],
                                              ),
                                            )
                                          : null,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    
                                    // Tên kế hoạch
                                    TextField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        labelText: 'Tên kế hoạch',
                                        border: OutlineInputBorder(),
                                        errorText: _isNameEmpty ? 'Vui lòng nhập tên' : null,
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _isNameEmpty = value.isEmpty;
                                        });
                                      },
                                    ),
                                    SizedBox(height: 20),
                                    
                                    // Mô tả
                                    TextField(
                                      controller: _descriptionController,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        labelText: 'Mô tả',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    
                                    // Ngày tạo
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Ngày tạo:',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            dateFormat.format(createdAt),
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    
                                    // Các tùy chọn
                                    SwitchListTile(
                                      title: Text('Sử dụng kế hoạch có sẵn'),
                                      value: useExistingPlan,
                                      onChanged: (value) => setState(() => useExistingPlan = value),
                                    ),
                                    SwitchListTile(
                                      title: Text('Giao cho huấn luyện viên'),
                                      value: assignToTrainer,
                                      onChanged: (value) => setState(() => assignToTrainer = value),
                                    ),
                                    SizedBox(height: 20),
                                    
                                    // Nút lưu
                                    ElevatedButton(
                                      onPressed: _updatePlan,
                                      child: Text('Lưu thay đổi', style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: blue,
                                        padding: EdgeInsets.symmetric(vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    
                                    // Nút xóa
                                    TextButton(
                                      onPressed: _deletePlan,
                                      child: Text('Xóa kế hoạch', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    _buildMealTable('Bữa sáng'),
                                    _buildMealTable('Bữa trưa'),
                                    _buildMealTable('Bữa tối'),
                                    _buildMealTable('Ăn vặt'),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

Future<void> _pickImage() async {
}

Future<void> _updatePlan() async {
  if (_nameController.text.isEmpty) {
    setState(() => _isNameEmpty = true);
    return;
  }

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('nutritions')
        .doc(_selectedPlanId)
        .update({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'imageUrl': _imageUrl,
          'useExistingPlan': useExistingPlan,
          'assignToTrainer': assignToTrainer,
        });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cập nhật kế hoạch thành công')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Có lỗi xảy ra: $e')),
    );
  }
}

Future<void> _deletePlan() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Xác nhận xóa'),
      content: Text('Bạn có chắc chắn muốn xóa kế hoạch này?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Hủy'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Xóa', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('nutritions')
          .doc(_selectedPlanId)
          .delete();

      setState(() {
        isViewingPlan = false;
        _selectedPlanId = null;
        _selectedPlanName = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa kế hoạch')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra: $e')),
      );
    }
  }
}
  Widget _buildMealTable(String mealType) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên bữa và nút 3 chấm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mealType,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    // Xử lý khi nhấn nút 3 chấm
                  },
                ),
              ],
            ),
            // Đường kẻ ngăn cách
            Divider(color: Colors.grey),
            // Tổng calo
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('nutritions')
                  .doc(_selectedPlanId)
                  .collection(mealType)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tổng calo'),
                          Text('0 kcal'),
                        ],
                      ),
                      SizedBox(height: 10),
                      Center(child: Text('Hiện chưa có món ăn nào.')),
                    ],
                  );
                }
                // Tính tổng calo
                int totalCalories = 0;
                snapshot.data!.docs.forEach((doc) {
                  final meal = doc.data() as Map<String, dynamic>;
                  totalCalories += meal['calories'] as int;
                });
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tổng calo'),
                        Text('$totalCalories kcal'),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Hiển thị các món ăn
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final meal = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(meal['name'] ?? 'Không có tên'),
                            subtitle: Text('${meal['grams']}g - ${meal['calories']} kcal'),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            // Nút thêm món ăn/thức uống
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showAddMealDialog(mealType);
                },
                child: Text('Thêm món ăn/thức uống'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showAddMealDialog(String mealType) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddMealPage(
        userId: userId,
        mealType: mealType,
        planId: _selectedPlanId!,
      ),
    ),
  );
}
  //XU LY CHO TRANG DO AN
  Widget _buildMealTab() {
    if (_isCreatingMeal) {
      return _buildCreateMealPage();
    } else {
      return _buildEmptyMealTab();
    }
  }

  Widget _buildEmptyMealTab() {
  String _searchQuery = ''; // Biến lưu truy vấn tìm kiếm
  String _selectedCategory = 'Tất cả'; // Biến lưu danh mục được chọn

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('foods')
        .doc(userId)
        .collection('userFoods')
        .orderBy('createdAt', descending: true)
        .limit(20) // Giới hạn số lượng món ăn
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hiện tại chưa có bất kỳ món ăn nào',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isCreatingMeal = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text(
                  'Tạo món ăn',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }

      final meals = snapshot.data!.docs;
      final filteredMeals = meals.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'].toString().toLowerCase();
        final type = data['type'] ?? '';

        // Kiểm tra danh mục
        final matchesCategory = _selectedCategory == 'Tất cả' || type == _selectedCategory;

        // Kiểm tra tìm kiếm
        final matchesSearch = name.contains(_searchQuery.toLowerCase());

        return matchesCategory && matchesSearch;
      }).toList();

      return Column(
        children: [
          // Thanh tìm kiếm và nút lọc
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm món ăn...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () {
                  },
                ),
              ],
            ),
          ),
          // Danh mục
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Tất cả', 'Bữa sáng', 'Bữa trưa', 'Bữa tối', 'Bữa phụ'].map((category) {
                final isSelected = category == _selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 10),
          // Danh sách món ăn
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredMeals.length,
              itemBuilder: (context, index) {
                final meal = filteredMeals[index].data() as Map<String, dynamic>;
                return _buildMealItem(meal, filteredMeals[index].id);
              },
            ),
          ),
          // Nút "Tạo món ăn" cố định ở bên dưới
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isCreatingMeal = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                minimumSize: Size(double.infinity, 50), // Chiều rộng tối đa
              ),
              child: Text(
                'Tạo món ăn',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      );
    },
  );
}
   
  Widget _buildMealItem(Map<String, dynamic> meal, String mealId) {
  return Card(
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hàng đầu tiên: Ảnh và tên món ăn
          Row(
            children: [
              // Ảnh món ăn
              if (meal['imageUrl'] != null && meal['imageUrl'].isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    meal['imageUrl'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(width: 20),
              // Tên món ăn
              Expanded(
                child: Text(
                  meal['name'] ?? 'Không có tên',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Nút 3 chấm
              PopupMenuButton<String>(
                onSelected: (value) {
                  _handleMealAction(value, mealId, meal);
                },
                itemBuilder: (BuildContext context) {
                  return {'Chỉnh sửa', 'Xóa'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          // Text "Thông tin món ăn"
          Text(
            'Thông tin món ăn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5),
          // Bảng thông tin dinh dưỡng
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Carbs
                Column(
                  children: [
                    Text(
                      'Carbs',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${meal['carbs']}g',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // Fat
                Column(
                  children: [
                    Text(
                      'Fat',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${meal['fat']}g',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // Protein
                Column(
                  children: [
                    Text(
                      'Protein',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${meal['protein']}g',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Grams',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${meal['grams']}g',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Calories',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${meal['calories']} kcal',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          )         
        ],
      ),
    ),
  );
}
  void _handleMealAction(String action, String mealId, Map<String, dynamic> meal) {
    if (action == 'Chỉnh sửa') {
      _editMeal(mealId, meal);
    } else if (action == 'Xóa') {
      _deleteMeal(mealId);
    }
  }

  void _editMeal(String mealId, Map<String, dynamic> meal) {
    // Điền dữ liệu vào form chỉnh sửa
    _mealNameController.text = meal['name'];
    _mealGramsController.text = meal['grams'].toString();
    _mealCaloriesController.text = meal['calories'].toString();
    _mealProteinController.text = meal['protein'].toString();
    _mealCarbsController.text = meal['carbs'].toString();
    _mealFatController.text = meal['fat'].toString();

    setState(() {
      _isCreatingMeal = true;
      _isEditingMeal = true;
      _editingMealId = mealId;
    });
  }

  void _deleteMeal(String mealId) async {
    try {
      await FirebaseFirestore.instance
          .collection('foods')
          .doc(userId)
          .collection('userFoods')
          .doc(mealId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Món ăn đã được xóa thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa món ăn: $e')),
      );
    }
  }

  Widget _buildCreateMealPage() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            setState(() {
              _isCreatingMeal = false;
              _isEditingMeal = false;
              _editingMealId = null;
              _mealNameController.clear();
              _mealGramsController.clear();
              _mealCaloriesController.clear();
              _mealProteinController.clear();
              _mealCarbsController.clear();
              _mealFatController.clear();
            });
          },
        ),
        title: Text(_isEditingMeal ? 'Chỉnh sửa món ăn' : 'Tạo món ăn mới', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _mealNameController,
                decoration: InputDecoration(
                  labelText: 'Tên món ăn',
                  errorText: _mealNameController.text.isEmpty ? 'Vui lòng nhập tên món ăn' : null,
                ),
              ),                          
              SizedBox(height: 16),
              TextField(
                controller: _mealGramsController,
                decoration: InputDecoration(
                  labelText: 'Số lượng gram',
                  errorText: _mealGramsController.text.isEmpty ? 'Vui lòng nhập số lượng gram' : null,
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _mealCaloriesController,
                decoration: InputDecoration(
                  labelText: 'Tổng calories',
                  errorText: _mealCaloriesController.text.isEmpty ? 'Vui lòng nhập tổng calories' : null,
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _mealProteinController,
                decoration: InputDecoration(
                  labelText: 'Protein (g)',
                  errorText: _mealProteinController.text.isEmpty ? 'Vui lòng nhập lượng protein' : null,
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _mealCarbsController,
                decoration: InputDecoration(
                  labelText: 'Carbs (g)',
                  errorText: _mealCarbsController.text.isEmpty ? 'Vui lòng nhập lượng carbs' : null,
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _mealFatController,
                decoration: InputDecoration(
                  labelText: 'Fat (g)',
                  errorText: _mealFatController.text.isEmpty ? 'Vui lòng nhập lượng fat' : null,
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createMeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text(
                  _isEditingMeal ? 'Cập nhật món ăn' : 'Tạo món ăn',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createMeal() async {
    if (_mealNameController.text.isEmpty ||
        _mealGramsController.text.isEmpty ||
        _mealCaloriesController.text.isEmpty ||
        _mealProteinController.text.isEmpty ||
        _mealCarbsController.text.isEmpty ||
        _mealFatController.text.isEmpty) {
      setState(() {}); // Cập nhật UI để hiển thị lỗi
      return;
    }

    try {
      final mealData = {
        'name': _mealNameController.text,
        'grams': int.parse(_mealGramsController.text),
        'calories': int.parse(_mealCaloriesController.text),
        'protein': int.parse(_mealProteinController.text),
        'carbs': int.parse(_mealCarbsController.text),
        'fat': int.parse(_mealFatController.text),
        'createdAt': DateTime.now(),
      };

      if (_isEditingMeal) {
        await FirebaseFirestore.instance
            .collection('foods')
            .doc(userId)
            .collection('userFoods')
            .doc(_editingMealId)
            .update(mealData);
      } else {
        await FirebaseFirestore.instance
            .collection('foods')
            .doc(userId)
            .collection('userFoods')
            .add(mealData);
      }

      setState(() {
        _isCreatingMeal = false;
        _isEditingMeal = false;
        _editingMealId = null;
        _mealNameController.clear();
        _mealGramsController.clear();
        _mealCaloriesController.clear();
        _mealProteinController.clear();
        _mealCarbsController.clear();
        _mealFatController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditingMeal ? 'Món ăn đã được cập nhật!' : 'Món ăn đã được tạo thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }
 Widget _buildCommunityTab() {
  final contentController = TextEditingController();
  final imageUrlController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;

  return Column(
    children: [
      // Phần tạo bài viết mới (Sticky ở trên cùng)
      Material(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: currentUser?.photoURL != null
                        ? NetworkImage(currentUser!.photoURL!)
                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: contentController,
                      decoration: InputDecoration(
                        hintText: 'Bạn đang nghĩ gì?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.green),
                    onPressed: () {
                      // Thêm chức năng chọn ảnh
                    },
                  ),
                  const Text('Ảnh', style: TextStyle(color: Colors.grey)),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      if (contentController.text.isNotEmpty && currentUser != null) {
                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser.uid)
                            .get();

                        if (userDoc.exists) {
                          final userData = userDoc.data() as Map<String, dynamic>;
                          final customerId = userData['customerId'];

                          await FirebaseFirestore.instance.collection('communitys').add({
                            'content': contentController.text,
                            'imageUrl': imageUrlController.text.isNotEmpty 
                                ? imageUrlController.text 
                                : null,
                            'date': DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                            'timestamp': FieldValue.serverTimestamp(),
                            'customerId': customerId,
                            'likes': [],
                            'comments': [],
                          });
                          
                          contentController.clear();
                          imageUrlController.clear();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: const Text('Đăng'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      
      // Danh sách bài viết
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('communitys')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            }
            
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.forum, size: 60, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có bài viết nào',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy là người đầu tiên chia sẻ!',
                      style: TextStyle(
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.only(top: 8),
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final post = snapshot.data!.docs[index];
                final data = post.data() as Map<String, dynamic>;
                
                return _buildPostCard(post.id, data);
              },
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildPostCard(String postId, Map<String, dynamic> data) {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('customers')
        .doc(data['customerId'])
        .get(),
    builder: (context, userSnapshot) {
      if (userSnapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
        return const SizedBox();
      }

      final userData = userSnapshot.data!.data() as Map<String, dynamic>;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final likes = List<String>.from(data['likes'] ?? []);
      final isLiked = currentUserId != null && likes.contains(currentUserId);
      final comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bài viết
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  userData['imageUrl'] ?? 'https://via.placeholder.com/150'
                ),
              ),
              title: Text(
                userData['name'] ?? 'Người dùng',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                data['date'] ?? '',
                style: TextStyle(
                  color: Colors.grey[600], 
                  fontSize: 12,
                ),
              ),
              trailing: currentUserId == userData['userId']
                  ? PopupMenuButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Xóa bài viết'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          _confirmDeletePost(postId);
                        }
                      },
                    )
                  : null,
            ),
            
            // Nội dung bài viết
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                data['content'] ?? '',
                style: const TextStyle(fontSize: 15),
              ),
            ),
            
            // Hình ảnh (nếu có)
            if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    data['imageUrl'].toString(),
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: Colors.grey[200],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.broken_image, 
                                size: 50, 
                                color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                'Không thể tải hình ảnh',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 250,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            
            // Thống kê like và comment
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (likes.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.thumb_up, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          likes.length.toString(),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  const Spacer(),
                  if (comments.isNotEmpty)
                    Text(
                      '${comments.length} bình luận',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            
            // Divider
            const Divider(height: 1, thickness: 0.5),
            
            // Nút hành động
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      icon: Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        color: isLiked ? Colors.blue : Colors.grey[600],
                        size: 20,
                      ),
                      label: Text(
                        'Thích',
                        style: TextStyle(
                          color: isLiked ? Colors.blue : Colors.grey[600],
                        ),
                      ),
                      onPressed: () {
                        _toggleLike(postId, currentUserId ?? '');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(
                        Icons.comment_outlined, 
                        color: Colors.grey,
                        size: 20,
                      ),
                      label: const Text(
                        'Bình luận', 
                        style: TextStyle(color: Colors.grey),
                      ),
                      onPressed: () {
                        _showCommentsDialog(postId, data['content'] ?? '');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _confirmDeletePost(String postId) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bài viết này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('communitys')
                  .doc(postId)
                  .delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa bài viết')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

Future<void> _toggleLike(String postId, String userId) async {
  if (userId.isEmpty) return;

  final postRef = FirebaseFirestore.instance.collection('communitys').doc(postId);
  final post = await postRef.get();

  if (post.exists) {
    final likes = List<String>.from(post['likes'] ?? []);
    
    if (likes.contains(userId)) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([userId])
      });
    }
  }
}

void _showCommentsDialog(String postId, String postContent) {
  final commentController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Bình luận',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Nội dung bài viết gốc
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      postContent,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
            
            // Danh sách bình luận
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('communitys')
                    .doc(postId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final comments = List<Map<String, dynamic>>.from(
                    snapshot.data!['comments'] ?? []
                  );
                  
                  if (comments.isEmpty) {
                    return const Center(
                      child: Text('Chưa có bình luận nào'),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('customers')
                            .doc(comment['customerId'])
                            .get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const SizedBox();
                          }
                          
                          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                          
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(
                                    userData['imageUrl'] ?? 'https://via.placeholder.com/150'
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userData['name'] ?? 'Người dùng',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(comment['text'] ?? ''),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment['date'] ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            
            // Ô nhập bình luận
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'Viết bình luận...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () async {
                        if (commentController.text.isNotEmpty) {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            final userDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .get();
                            
                            if (userDoc.exists) {
                              final userData = userDoc.data() as Map<String, dynamic>;
                              final customerId = userData['customerId'];
                              
                              final newComment = {
                                'customerId': customerId,
                                'text': commentController.text,
                                'date': DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                              };
                              
                              await FirebaseFirestore.instance
                                  .collection('communitys')
                                  .doc(postId)
                                  .update({
                                    'comments': FieldValue.arrayUnion([newComment])
                                  });
                              
                              commentController.clear();
                            }
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

  Widget _buildCreatePlanPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo kế hoạch'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              isCreatingPlan = false;
            });
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên kế hoạch
              Text('Tên kế hoạch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Nhập tên kế hoạch',
                  border: OutlineInputBorder(),
                  errorText: _isNameEmpty ? 'Tên kế hoạch là bắt buộc' : null,
                ),
              ),
              SizedBox(height: 20),

              // Sử dụng kế hoạch có sẵn
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sử dụng kế hoạch có sẵn', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: useExistingPlan,
                    onChanged: (value) {
                      setState(() {
                        useExistingPlan = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Gửi kế hoạch cho huấn luyện viên
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Gửi kế hoạch cho huấn luyện viên', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: assignToTrainer,
                    onChanged: (value) {
                      setState(() {
                        assignToTrainer = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Upload ảnh
              Text('Ảnh kế hoạch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Xử lý upload ảnh
                },
                child: Text('Tải lên ảnh'),
              ),
              SizedBox(height: 20),

              // Thông tin kế hoạch
              Text('Thông tin kế hoạch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Nhập thông tin kế hoạch',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Nút tạo
              ElevatedButton(
                onPressed: _createNutritionPlan,
                child: Text('Tạo kế hoạch'),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tạo kế hoạch dinh dưỡng
  void _createNutritionPlan() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _isNameEmpty = true;
      });
      return;
    }

    final String name = _nameController.text.trim();
    final String description = _descriptionController.text.trim();
    final DateTime now = DateTime.now();

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('nutritions')
          .add({
        'name': name,
        'description': description,
        'imageUrl': _imageUrl,
        'createdAt': now,
        'useExistingPlan': useExistingPlan,
        'assignToTrainer': assignToTrainer,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo kế hoạch thành công')),
      );

      // Quay lại trang chính
      setState(() {
        isCreatingPlan = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
    }
  }
}
class AddMealPage extends StatefulWidget {
  final String userId;
  final String mealType;
  final String planId;

  const AddMealPage({
    Key? key,
    required this.userId,
    required this.mealType,
    required this.planId,
  }) : super(key: key);

  @override
  _AddMealPageState createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn món ăn'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('foods')
            .doc(widget.userId)
            .collection('userFoods')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Không có món ăn nào.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final meal = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(meal['name'] ?? 'Không có tên'),
                  subtitle: Text('${meal['grams']}g - ${meal['calories']} kcal'),
                  onTap: () {
                    _addMealToPlan(meal);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _addMealToPlan(Map<String, dynamic> meal) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('nutritions')
          .doc(widget.planId)
          .collection(widget.mealType)
          .add(meal);

      // Quay lại trang trước sau khi thêm món ăn thành công
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi thêm món ăn: $e')),
      );
    }
  }
}