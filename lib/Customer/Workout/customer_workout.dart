import 'package:do_an_lt/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutPage extends StatefulWidget {
  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  String? selectedWorkoutId;
  String? selectedWorkoutName;
  bool useExistingWorkout = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [blue, Colors.black], // Gradient từ xanh dương đến đen
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 200.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
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
    );
  }

  Widget _buildWorkoutList() {
    return Column(
      children: [
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Gần đây nhất',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 10),
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
                return Center(
                    child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
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
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          data['imageUrl'] != null && data['imageUrl'].isNotEmpty
                              ? data['imageUrl']
                              : 'https://via.placeholder.com/150', 
                        ),
                      ),
                      title: Text(data['name'] ?? 'Không có tên'),
                      trailing: const Icon(Icons.more_vert),
                      onTap: () {
                        setState(() {
                          selectedWorkoutId = workout.id;
                          selectedWorkoutName = data['name'];
                        });
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
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
    return Column(
      children: [
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
            Text(workoutName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
        const SizedBox(height: 10),
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
                return Center(
                    child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Không có bài tập nào.'));
              }

              return ListView.builder(
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
                                .doc(userId) // Thay bằng userId thực tế
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

                              return Column(
                                children: [
                                  // Header của bảng
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Set', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text('Weight', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text('Reps', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text('Rest', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  SizedBox(height: 10),

                                  // Hiển thị các set
                                  ...setSnapshot.data!.docs.map((set) {
                                    final setData = set.data() as Map<String, dynamic>;
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(setData['setNumber'] ?? ''),
                                        Text(setData['weight'] ?? ''),
                                        Text(setData['reps'] ?? ''),
                                        Text(setData['rest'] ?? ''),
                                      ],
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
