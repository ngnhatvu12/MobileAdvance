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
    // Preload images sau khi context đã sẵn sàng
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
          SizedBox(height: 40),
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
                buildWorkoutButton("CIRCUIT"),
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
            items: _imageUrls.map((url) => Image.asset(url, fit: BoxFit.cover)).toList(),
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
          )
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
    return Column(
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
    );
  }

  Widget buildWorkoutButton(String text) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white, 
            fontSize: 14, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}