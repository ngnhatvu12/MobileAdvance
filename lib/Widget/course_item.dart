import 'package:do_an_lt/Customer/Home/course_detail.dart';
import 'package:flutter/material.dart';

class CourseItem extends StatelessWidget {
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
   final bool isRegistered; 
  const CourseItem({
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
    required this.isRegistered,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey,
                  child: const Center(child: Icon(Icons.error)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.red),
                const SizedBox(width: 5),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.blueAccent),
                const SizedBox(width: 5),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thành viên: ${members.length}/20',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Chuyển sang trang chi tiết khóa học
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetail(
                          classId: classId,
                          imageUrl: imageUrl,
                          name: name,
                          description: description,
                          location: location,
                          time: time,
                          members: members,
                          price: price,
                          goals: goals,
                          benefits: benefits,
                          requirements: requirements,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRegistered ? Colors.green : Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isRegistered ? 'Xem chi tiết' : 'Đăng ký \$$price'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}