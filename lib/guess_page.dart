import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_lt/Customer/Home/news_detail.dart';
import 'package:flutter/material.dart';
import 'package:do_an_lt/theme/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class GuessPage extends StatefulWidget {
  const GuessPage({super.key});

  @override
  _GuessPageState createState() => _GuessPageState();
}

class _GuessPageState extends State<GuessPage> {
  final List<String> _imageUrls = [
    'assets/images/banner_1.jpg',
    'assets/images/banner_2.jpg',
    'assets/images/banner_1.jpg',
  ];
  final List<String> _tutorialImages = [
    'assets/images/banner_1.jpg',
    'assets/images/banner_1.jpg',
    'assets/images/banner_1.jpg',
  ];
  
  int _currentIndex = 0;
  bool _showTutorial = true;
  late PageController _tutorialPageController;
  int _currentTutorialPage = 0;

  @override
  void initState() {
    super.initState();
    _tutorialPageController = PageController();
    _showTutorial = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var imageUrl in _imageUrls) {
      precacheImage(AssetImage(imageUrl), context);
    }
    for (var tutorialImage in _tutorialImages) {
      precacheImage(AssetImage(tutorialImage), context);
    }
  }

  @override
  void dispose() {
    _tutorialPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildMainContent(),
          if (_showTutorial) _buildTutorialOverlay(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [blue, red],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/workout.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "FitnessApp",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Kính chào quý khách",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: -60,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(context, "/login"),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login, color: blue, size: 40),
                                SizedBox(height: 5),
                                Text("Đăng nhập", style: TextStyle(color: Colors.black, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(width: 3, color: Colors.black12, height: 60),
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(context, "/register"),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit, color: Colors.red, size: 40),
                                SizedBox(height: 5),
                                Text("Đăng ký", style: TextStyle(color: Colors.black, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 100),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 20, 
              runSpacing: 20, 
              alignment: WrapAlignment.center,
              children: [
                buildFeatureButton(Icons.calendar_today, "Đặt lịch tập luyện"),
                buildFeatureButton(Icons.person, "Đặt lịch HLV"),
                buildFeatureButton(Icons.event, "Lịch học"),
                buildFeatureButton(Icons.card_membership, "Mở thẻ tập"),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text('Khóa học',style: TextStyle( fontSize: 22,fontWeight: FontWeight.bold,),),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.5,
              children: [
                buildWorkoutButton("GYM"),
                buildWorkoutButton("CYCLING"),
                buildWorkoutButton("BƠI"),
                buildWorkoutButton("YOGA"),
                buildWorkoutButton("DANCE"),
                buildWorkoutButton("GROUP X"),
              ],
            ),
          ),
          SizedBox(height: 30),
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              height: 200,
              autoPlayCurve: Curves.fastOutSlowIn,
              autoPlayAnimationDuration: Duration(milliseconds: 600),
              autoPlayInterval: Duration(seconds: 2),
              enlargeCenterPage: true,
              aspectRatio: 2.0,
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
            items: _imageUrls.map((url) => ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(url, fit: BoxFit.cover),
              )).toList(),
          ),
          SizedBox(height: 10),
          AnimatedSmoothIndicator(
            activeIndex: _currentIndex,
            count: _imageUrls.length,
            effect: WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              spacing: 10,
              dotColor: Colors.grey.shade200,
              activeDotColor: Colors.grey.shade900,
              paintStyle: PaintingStyle.fill,
            ),
          ),
          SizedBox(height: 30),
          NewsSection(),
        ],
      ),
    );
  }

  Widget _buildTutorialOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.grey),
                      onPressed: () => setState(() => _showTutorial = false),
                    ),
                  ),
                  SizedBox(
                    height: 500,
                    child: PageView(
                      controller: _tutorialPageController,
                      onPageChanged: (index) => setState(() => _currentTutorialPage = index),
                      children: [
                        _buildTutorialPage(
                          icon: Icons.fitness_center,
                          image: _tutorialImages[0],
                          title: 'Chào mừng đến với FitnessApp',
                          description: 'Ứng dụng giúp bạn quản lý tập luyện, dinh dưỡng và kết nối với huấn luyện viên cá nhân',
                        ),
                        _buildTutorialPage(
                          icon: Icons.calendar_today,
                          image: _tutorialImages[1],
                          title: 'Đặt lịch tập & Huấn luyện viên',
                          description: 'Dễ dàng đặt lịch tập tại phòng gym hoặc với huấn luyện viên cá nhân theo thời gian biểu của bạn',
                        ),
                        _buildTutorialPage(
                          icon: Icons.restaurant_menu,
                          image: _tutorialImages[2],
                          title: 'Bài tập & Dinh dưỡng',
                          description: 'Theo dõi chế độ tập luyện và dinh dưỡng hàng ngày để đạt mục tiêu fitness của bạn',
                        ),
                      ],
                    ),
                  ),
                  SmoothPageIndicator(
                    controller: _tutorialPageController,
                    count: 3,
                    effect: WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 10,
                      dotColor: Colors.grey.shade300,
                      activeDotColor: blue,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: _currentTutorialPage == 0 
                    ? MainAxisAlignment.center 
                    : MainAxisAlignment.spaceEvenly,
                children: [
                  if (_currentTutorialPage > 0)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      onPressed: () => _tutorialPageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: Text('Trở lại', style: TextStyle(color: Colors.white)),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    onPressed: () {
                      if (_currentTutorialPage < 2) {
                        _tutorialPageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        setState(() => _showTutorial = false);
                      }
                    },
                    child: Text(
                      _currentTutorialPage == 2 ? 'Đã hiểu' : 'Tiếp tục',
                      style: TextStyle(color: Colors.white),
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

  Widget _buildTutorialPage({
    required IconData icon,
    required String image,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: blue),
          SizedBox(height: 20),
          Image.asset(
            image,
            height: 150,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => 
              Container(height: 150, color: Colors.grey[200]),
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildFeatureButton(IconData icon, String text) {
    return GestureDetector(
      onTap: () => _showLoginRequiredDialog(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWorkoutButton(String type) {
    return GestureDetector(
      onTap: () => _navigateToClassList(context,type),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            type,
            style: TextStyle(
              color: Colors.white, 
              fontSize: 14, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Yêu cầu đăng nhập"),
        content: Text("Bạn cần đăng nhập để sử dụng tính năng này"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: blue),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/login");
            },
            child: Text("Đăng nhập", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  void _navigateToClassList(BuildContext context, String type) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ClassListPage(workoutType: type.toLowerCase()),
    ),
  );
}
}
class ClassListPage extends StatelessWidget {
  final String workoutType;

  const ClassListPage({Key? key, required this.workoutType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lớp $workoutType'.toUpperCase()),
        backgroundColor: blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('class')
            .where('type', isEqualTo: workoutType)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Không có lớp học nào'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              return _buildClassItem(context,doc);
            },
          );
        },
      ),
    );
  }

  Widget _buildClassItem(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              data['imageUrl'],
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey[200],
                child: Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(data['time']),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text(data['location']),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${data['price']} USD',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: blue,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                      ),
                      onPressed: () {
                        _showLoginRequiredDialog(context);
                      },
                      child: Text(
                        'Xem chi tiết',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Yêu cầu đăng nhập"),
        content: Text("Bạn cần đăng nhập để xem chi tiết lớp học"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: blue),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/login");
            },
            child: Text("Đăng nhập", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
class NewsSection extends StatefulWidget  {
  const NewsSection({super.key});

  @override
  _NewsSectionState createState() => _NewsSectionState();
}

class _NewsSectionState extends State<NewsSection> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tin tức',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('news').limit(3).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('Không có tin tức nào.');
              }
              final news = snapshot.data!.docs;

              return SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: news.length,
                  itemBuilder: (context, index) {
                    final doc = news[index];
                    final title = doc['name'] ?? 'Không có tiêu đề';
                    final imageUrl = doc['imageUrl'] ?? '';
                    final date = doc['date'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsDetailPage(
                              newsItem: {
                                'id': doc.id,
                                'name': title,
                                'imageUrl': imageUrl,
                                'date': date,
                                'detail': doc['detail'],
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 250,
                        margin: EdgeInsets.only(right: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              child: Image.network(
                                imageUrl,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 120,
                                  color: Colors.grey[200],
                                  child: Center(child: Icon(Icons.error)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10, bottom: 10),
                              child: Text(
                                date,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}