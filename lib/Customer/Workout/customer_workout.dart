import 'package:do_an_lt/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutPage extends StatefulWidget {
  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> with SingleTickerProviderStateMixin {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  String? selectedWorkoutId;
  String? selectedWorkoutName;
  bool useExistingWorkout = false;
  late TabController _tabController;
  bool _isWorkoutStarted = false;
   int _currentStreak = 0;
  int _totalWorkouts = 0;
  int _experiencePoints = 0;
  int _userLevel = 1;
  double _expProgress = 0.0;
  bool _workedOutToday = false;
  List<String> _achievements = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  Future<void> _loadUserProgress() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _currentStreak = data['streak'] ?? 0;
        _totalWorkouts = data['totalWorkouts'] ?? 0;
        _experiencePoints = data['experiencePoints'] ?? 0;
        _userLevel = data['userLevel'] ?? 1;
        _expProgress = (_experiencePoints % 10) / 10.0;
        _achievements = List<String>.from(data['achievements'] ?? []);
        _workedOutToday = data['lastWorkoutDate'] != null && 
            _isSameDay(DateTime.now(), (data['lastWorkoutDate'] as Timestamp).toDate());
      });
    }
  }
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  Future<void> _updateWorkoutCompletion() async {
    final now = DateTime.now();
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    
    // Get current user data
    final userDoc = await userRef.get();
    final data = userDoc.data() as Map<String, dynamic>;
    final lastWorkoutDate = data['lastWorkoutDate'] != null 
        ? (data['lastWorkoutDate'] as Timestamp).toDate() 
        : null;
    
    // Calculate new streak
    int newStreak = _currentStreak;
    if (lastWorkoutDate == null || !_isSameDay(now, lastWorkoutDate)) {
      // Check if yesterday to maintain streak
      if (lastWorkoutDate != null && now.difference(lastWorkoutDate).inDays == 1) {
        newStreak++;
      } else {
        newStreak = 1; // Reset streak if not consecutive
      }
    }
    
    // Calculate experience
    int newExp = _experiencePoints + 1;
    int newLevel = _userLevel;
    List<String> newAchievements = List.from(_achievements);
    
    // Check for level up
    if (newExp >= newLevel * 10) {
      newExp = 0;
      newLevel++;
      
      // Add level achievements
      if (newLevel >= 5 && !newAchievements.contains('level_5')) {
        newAchievements.add('level_5');
      }
      if (newLevel >= 10 && !newAchievements.contains('level_10')) {
        newAchievements.add('level_10');
      }
    }
    
    // Check for streak achievements
    if (newStreak >= 7 && !newAchievements.contains('streak_7')) {
      newAchievements.add('streak_7');
    }
    if (newStreak >= 30 && !newAchievements.contains('streak_30')) {
      newAchievements.add('streak_30');
    }
    
    // Update Firestore
    await userRef.update({
      'lastWorkoutDate': now,
      'streak': newStreak,
      'totalWorkouts': _totalWorkouts + 1,
      'experiencePoints': newExp,
      'userLevel': newLevel,
      'achievements': newAchievements,
    });
    
    setState(() {
      _currentStreak = newStreak;
      _totalWorkouts++;
      _experiencePoints = newExp;
      _userLevel = newLevel;
      _expProgress = (newExp % 10) / 10.0;
      _achievements = newAchievements;
      _workedOutToday = true;
    });
  }

  // Add this new widget method for the progress header
  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [blue, const Color.fromARGB(255, 2, 5, 165)],
        ),
      ),
      child: Column(
        children: [
          // Streak counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                icon: Icons.local_fire_department,
                value: '$_currentStreak ngày',
                label: 'Chuỗi tập luyện',
                color: Colors.orange,
              ),
              _buildStatItem(
                icon: Icons.fitness_center,
                value: '$_totalWorkouts',
                label: 'Tổng buổi tập',
                color: Colors.green,
              ),
              _buildStatItem(
                icon: Icons.star,
                value: 'Lv. $_userLevel',
                label: 'Cấp độ',
                color: Colors.yellow,
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // Experience bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kinh nghiệm: $_experiencePoints/${_userLevel * 10} XP',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    'Cấp ${_userLevel}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              LinearProgressIndicator(
                value: _expProgress,
                backgroundColor: Colors.grey[800],
                color: Colors.lightBlueAccent,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),
          
          // Achievements preview
          if (_achievements.isNotEmpty) ...[
            const SizedBox(height: 15),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _achievements.map((achievement) {
                  IconData icon;
                  Color color;
                  String tooltip;
                  
                  switch (achievement) {
                    case 'streak_7':
                      icon = Icons.emoji_events;
                      color = Colors.amber;
                      tooltip = '7 ngày liên tiếp';
                      break;
                    case 'streak_30':
                      icon = Icons.emoji_events;
                      color = Colors.deepOrange;
                      tooltip = '30 ngày liên tiếp';
                      break;
                    case 'level_5':
                      icon = Icons.star;
                      color = Colors.blue;
                      tooltip = 'Đạt cấp 5';
                      break;
                    case 'level_10':
                      icon = Icons.star;
                      color = Colors.purple;
                      tooltip = 'Đạt cấp 10';
                      break;
                    default:
                      icon = Icons.check_circle;
                      color = Colors.green;
                      tooltip = 'Thành tựu';
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Tooltip(
                      message: tooltip,
                      child: Icon(icon, color: color, size: 30),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          
          // Daily workout status
          if (_workedOutToday) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: Colors.green, size: 16),
                  SizedBox(width: 5),
                  Text(
                    'Đã hoàn thành hôm nay',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String value, required String label, required Color color}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [blue, Colors.black],
        ),
      ),
      child: Column(
        children: [
          _buildProgressHeader(), // Thêm phần header tiến độ ở đây
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 0.0), // Giảm khoảng cách từ 200 xuống 20
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: selectedWorkoutId == null
                      ? _buildWorkoutList()
                      : _buildExercisePage(selectedWorkoutId!, selectedWorkoutName!),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildWorkoutList() {
  return Column(
    children: [
      // Thanh tìm kiếm
      TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      const SizedBox(height: 20),
      // Tiêu đề và nút lọc
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Gần đây nhất',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      const SizedBox(height: 10),
      // Danh sách bài tập
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('workouts')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Không có bài tập nào.'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final workout = snapshot.data!.docs[index];
                final data = workout.data() as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      setState(() {
                        selectedWorkoutId = workout.id;
                        selectedWorkoutName = data['name'];
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Ảnh hình vuông bo góc
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              data['imageUrl'] != null && data['imageUrl'].isNotEmpty
                                  ? data['imageUrl']
                                  : 'https://via.placeholder.com/150',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Tên bài tập
                          Expanded(
                            child: Text(
                              data['name'] ?? 'Không có tên',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Nút more_vert
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {},
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
      // Nút thêm bài tập
      Positioned(
        bottom: 20,
        right: 20,
        child: FloatingActionButton(
          onPressed: () => _showCreateWorkoutDialog(),
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    ],
  );
}

  Widget _buildExercisePage(String workoutId, String workoutName) {
  return _isWorkoutStarted 
      ? _buildWorkoutInProgressView(workoutId, workoutName)
      : Column(
          children: [
            // Nút trở về, tên bài tập và nút thùng rác
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      selectedWorkoutId = null;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    workoutName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteWorkout(workoutId),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // TabBar để chuyển qua lại giữa "Bài tập" và "Chi tiết"
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Bài tập'),
                Tab(text: 'Chi tiết'),
              ],
            ),
            const SizedBox(height: 10),

            // Nội dung tương ứng với từng tab
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExercisesTab(workoutId),
                  _buildDetailsTab(workoutId),
                ],
              ),
            ),
          ],
        );
}
  Widget _buildWorkoutInProgressView(String workoutId, String workoutName) {
  return Column(
    children: [
      // Thanh tiêu đề
      Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _isWorkoutStarted = false;
                });
              },
            ),
            Expanded(
              child: Center(
                child: Text(
                  workoutName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),

      // Danh sách bài tập với set
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('workouts')
              .doc(workoutId)
              .collection('exercises')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            return ListView.builder(
              itemCount: snapshot.data?.docs.length ?? 0,
              itemBuilder: (context, index) {
                final exercise = snapshot.data!.docs[index];
                final data = exercise.data() as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'] ?? 'No name',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        // Hiển thị các sets
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('workouts')
                              .doc(workoutId)
                              .collection('exercises')
                              .doc(exercise.id)
                              .collection('sets')
                              .snapshots(),
                          builder: (context, setSnapshot) {
                            if (setSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final sets = setSnapshot.data?.docs ?? [];

                            return Column(
                              children: [
                                // Tiêu đề các cột
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Set', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const Text('Weight', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const Text('Reps', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const Text('Rest', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const Text('✓', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                
                                // Danh sách các set
                                ...sets.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final set = entry.value;
                                  final setData = set.data() as Map<String, dynamic>;
                                  final isCompleted = setData['completed'] ?? false;
                                  final bgColor = isCompleted ? Colors.lightGreen[100] : Colors.transparent;
                                  
                                  return Container(
                                    color: bgColor,
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(setData['weight'] ?? '', style: const TextStyle(fontSize: 16)),
                                        Text(setData['reps'] ?? '', style: const TextStyle(fontSize: 16)),
                                        Text(setData['rest'] ?? '', style: const TextStyle(fontSize: 16)),
                                        Checkbox(
                                          value: isCompleted,
                                          onChanged: (value) {
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(userId)
                                                .collection('workouts')
                                                .doc(workoutId)
                                                .collection('exercises')
                                                .doc(exercise.id)
                                                .collection('sets')
                                                .doc(set.id)
                                                .update({'completed': value});
                                            
                                            if (value == true) {
                                              _updateWorkoutCompletion();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          },
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
    ],
  );
}


  Widget _buildExercisesTab(String workoutId) {
  return Column(
    children: [
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('workouts')
              .doc(workoutId)
              .collection('exercises')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
            }
            
            return Column(
              children: [
                // Danh sách bài tập
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final exercise = snapshot.data!.docs[index];
                        final data = exercise.data() as Map<String, dynamic>;

                        return Card(
                          margin: EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tên bài tập
                                Text(
                                  data['name'] ?? 'Không có tên',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),

                                // Hiển thị các sets
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .collection('workouts')
                                      .doc(workoutId)
                                      .collection('exercises')
                                      .doc(exercise.id)
                                      .collection('sets')
                                      .snapshots(),
                                  builder: (context, setSnapshot) {
                                    if (setSnapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }
                                    if (setSnapshot.hasError) {
                                      return Center(child: Text('Đã xảy ra lỗi: ${setSnapshot.error}'));
                                    }
                                    if (!setSnapshot.hasData || setSnapshot.data!.docs.isEmpty) {
                                      return Center(child: Text('Không có set nào.'));
                                    }

                                    final sets = setSnapshot.data!.docs;

                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text('Set', style: TextStyle(fontWeight: FontWeight.bold)),
                                            SizedBox(width: 45),
                                            Text('Weight', style: TextStyle(fontWeight: FontWeight.bold)),
                                            SizedBox(width: 60),
                                            Text('Reps', style: TextStyle(fontWeight: FontWeight.bold)),
                                            SizedBox(width: 80),
                                            Text('Rest', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        ...sets.map((set) {
                                          final setData = set.data() as Map<String, dynamic>;
                                          final setNumber = sets.indexOf(set) + 1;
                                          final weightController = TextEditingController(text: setData['weight']);
                                          final repsController = TextEditingController(text: setData['reps']);
                                          final restController = TextEditingController(text: setData['rest']);

                                          return Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    setNumber.toString(),
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    width: 80,
                                                    child: TextField(
                                                      controller: weightController,
                                                      decoration: InputDecoration(
                                                        labelText: 'Weight',
                                                        border: OutlineInputBorder(),
                                                      ),
                                                      onChanged: (value) {
                                                        FirebaseFirestore.instance
                                                            .collection('users')
                                                            .doc(userId)
                                                            .collection('workouts')
                                                            .doc(workoutId)
                                                            .collection('exercises')
                                                            .doc(exercise.id)
                                                            .collection('sets')
                                                            .doc(set.id)
                                                            .update({'weight': value});
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 80,
                                                    child: TextField(
                                                      controller: repsController,
                                                      decoration: InputDecoration(
                                                        labelText: 'Reps',
                                                        border: OutlineInputBorder(),
                                                      ),
                                                      onChanged: (value) {
                                                        FirebaseFirestore.instance
                                                            .collection('users')
                                                            .doc(userId)
                                                            .collection('workouts')
                                                            .doc(workoutId)
                                                            .collection('exercises')
                                                            .doc(exercise.id)
                                                            .collection('sets')
                                                            .doc(set.id)
                                                            .update({'reps': value});
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 80,
                                                    child: TextField(
                                                      controller: restController,
                                                      decoration: InputDecoration(
                                                        labelText: 'Rest',
                                                        border: OutlineInputBorder(),
                                                      ),
                                                      onChanged: (value) {
                                                        FirebaseFirestore.instance
                                                            .collection('users')
                                                            .doc(userId)
                                                            .collection('workouts')
                                                            .doc(workoutId)
                                                            .collection('exercises')
                                                            .doc(exercise.id)
                                                            .collection('sets')
                                                            .doc(set.id)
                                                            .update({'rest': value});
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                            ],
                                          );
                                        }).toList(),

                                        // Nút thêm set
                                        Center(
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              final newSetNumber = sets.length + 1;
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(userId)
                                                  .collection('workouts')
                                                  .doc(workoutId)
                                                  .collection('exercises')
                                                  .doc(exercise.id)
                                                  .collection('sets')
                                                  .add({
                                                'setNumber': newSetNumber.toString(),
                                                'weight': '80kg',
                                                'reps': '10',
                                                'rest': '00:30',
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            ),
                                            child: Text('Thêm Set'),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Expanded(
                    child: Center(
                      child: Text('Không có bài tập nào'),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            // Nút thêm bài tập
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showAddExerciseDialog(workoutId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Thêm bài tập', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(width: 10), // Khoảng cách giữa 2 nút

            // Nút bắt đầu tập luyện
            Expanded(
  child: ElevatedButton(
    onPressed: () {
      setState(() {
        _isWorkoutStarted = true;
      });
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(vertical: 16),
    ),
    child: Text('Bắt đầu tập luyện', 
        style: TextStyle(color: Colors.white, fontSize: 16)),
  ),
),
          ],
        ),
      ),
    ],
  );
}

// Hàm hiển thị popup thêm bài tập
void _showAddExerciseDialog(String workoutId) {
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  final repsController = TextEditingController();
  final restController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Thêm bài tập'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Tên bài tập',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: weightController,
                    decoration: InputDecoration(
                      labelText: 'Weight',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: repsController,
                    decoration: InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: restController,
                    decoration: InputDecoration(
                      labelText: 'Rest',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  weightController.text.isNotEmpty &&
                  repsController.text.isNotEmpty &&
                  restController.text.isNotEmpty) {
                // Thêm bài tập vào Firestore
                final exerciseRef = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('workouts')
                    .doc(workoutId)
                    .collection('exercises')
                    .add({
                  'name': nameController.text,
                });

                // Thêm set vào Firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('workouts')
                    .doc(workoutId)
                    .collection('exercises')
                    .doc(exerciseRef.id)
                    .collection('sets')
                    .add({
                  'weight': weightController.text,
                  'reps': repsController.text,
                  'rest': restController.text,
                });

                Navigator.pop(context);
              }
            },
            child: Text('Tạo'),
          ),
        ],
      );
    },
  );
}

  Widget _buildDetailsTab(String workoutId) {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(workoutId)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
      }
      if (!snapshot.hasData || !snapshot.data!.exists) {
        return const Center(child: Text('Không tìm thấy bài tập.'));
      }

      final workoutData = snapshot.data!.data() as Map<String, dynamic>;
      final name = workoutData['name'] ?? 'Không có tên';
      final imageUrl = workoutData['imageUrl'] ?? '';
      final date = workoutData['date'] != null
          ? (workoutData['date'] as Timestamp).toDate().toString()
          : 'Không có ngày tạo';

      // Đặt giá trị hiện tại vào các ô nhập liệu
      _nameController.text = name;
      _imageUrlController.text = imageUrl;

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ô nhập tên
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên bài tập',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Ô nhập hình ảnh
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: 'URL hình ảnh',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Hiển thị hình ảnh
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),

            // Ngày tạo
            Text(
              'Ngày tạo: $date',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Nút Lưu
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('workouts')
                        .doc(workoutId)
                        .update({
                      'name': _nameController.text,
                      'imageUrl': _imageUrlController.text,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cập nhật thành công!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi khi cập nhật: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  'Lưu',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
  void _deleteWorkout(String workoutId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .doc(workoutId)
          .delete();

      setState(() {
        selectedWorkoutId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bài tập đã được xóa thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa bài tập: $e')),
      );
    }
  }
  void _showCreateWorkoutDialog() {
    final TextEditingController _nameController = TextEditingController();
    String? selectedExistingWorkoutId;
    bool showError = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.fitness_center),
                  SizedBox(width: 10),
                  Text('Tạo luyện tập'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Tên bài luyện tập',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SwitchListTile(
                    title: Text('Sử dụng bài tập có sẵn?'),
                    value: useExistingWorkout,
                    onChanged: (bool value) {
                      setState(() {
                        useExistingWorkout = value;
                        selectedExistingWorkoutId = null;
                        showError = false;
                      });
                    },
                  ),
                  if (useExistingWorkout)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('workouts')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text('No workouts available');
                        }
                        return DropdownButtonFormField<String>(
                          items: snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(data['name'] ?? 'Unnamed workout'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedExistingWorkoutId = value;
                              showError = false;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Chọn bài luyện tập',
                            errorText: showError ? 'Please select a valid workout.' : null,
                          ),
                        );
                      },
                    ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    if (useExistingWorkout && selectedExistingWorkoutId == null) {
                      setState(() => showError = true);
                      return;
                    }
                    await _createWorkout(_nameController.text, selectedExistingWorkoutId);
                    Navigator.pop(context);
                  },
                  child: Text('Tạo'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  Future<void> _createWorkout(String name, String? existingWorkoutId) async {
    if (name.isEmpty) return;

    final newWorkoutRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .add({'name': name, 'date': FieldValue.serverTimestamp()});

    if (existingWorkoutId != null) {
      final exercises = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .doc(existingWorkoutId)
          .collection('exercises')
          .get();

      for (var exercise in exercises.docs) {
        final newExerciseRef = await newWorkoutRef.collection('exercises').add(exercise.data());
        final sets = await exercise.reference.collection('sets').get();

        for (var set in sets.docs) {
          await newExerciseRef.collection('sets').add(set.data());
        }
      }
    }
  }
}
