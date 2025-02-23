import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class GuessPage extends StatefulWidget {
  const GuessPage({super.key});

  @override
  _GuessPageState createState() => _GuessPageState();
}

class _GuessPageState extends State<GuessPage> {

  // Danh sách ảnh
  final _imageUrls = [
    Image.asset('assets/images/banner_1.jpg'),
    Image.asset('assets/images/banner_2.jpg'),
    Image.asset('assets/images/banner_1.jpg'),
  ];
    int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔴 HEADER (Chào khách hàng)
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  padding: EdgeInsets.only(top: 100, bottom: 40),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/gif_1.gif"), 
                      fit: BoxFit.cover, 
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Kính chào quý khách hàng !",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                  
                // 🔥 Nút đăng nhập & đăng ký (to hơn, nằm giữa)
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
        // Đăng nhập (bên trái)
        Expanded(
          child: InkWell( // 👉 Dùng InkWell để có hiệu ứng nhấn
            onTap: () {
              Navigator.pushNamed(context, "/login");
            },
            borderRadius: BorderRadius.circular(10), // Bo góc khi nhấn
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 10), // Tạo khoảng bấm dễ hơn
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, color: Colors.red, size: 40),
                  SizedBox(height: 5),
                  Text("Đăng nhập", style: TextStyle(color: Colors.red, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),

        // Đường kẻ dọc
        Container(
          width: 3,
          color: Colors.black12,
          height: 60,
        ),

        // Đăng ký (bên phải)
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, "/register");
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, color: Colors.red, size: 40),
                  SizedBox(height: 5),
                  Text("Đăng ký", style: TextStyle(color: Colors.red, fontSize: 16)),
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
                crossAxisCount: 3, // Mỗi hàng 3 nút
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.5, // Cân đối kích thước
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
              autoPlayAnimationDuration: const Duration(milliseconds: 2),
              autoPlayInterval: const Duration(seconds: 2),
              enlargeCenterPage: true,
              aspectRatio: 2.0,
              onPageChanged: (index, reason) {
               setState(() {
                 _currentIndex = index;
               });
               },
               ),
               items: _imageUrls,
               ),  
            SizedBox(height: 10),   
            AnimatedSmoothIndicator(activeIndex: _currentIndex,
             count: _imageUrls.length,
             effect: WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              spacing: 10,
              dotColor: Colors.grey.shade200,
              activeDotColor: Colors.grey.shade900,
              paintStyle: PaintingStyle.fill,
             ),)
          ],
        ),
      ),
    );
  }

  // 🛠️ Các chức năng (đều nhau, tự xuống dòng)
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
          width: 80, // Định giới hạn chiều rộng để text tự xuống dòng
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  // 💪 Các nút tập luyện (vuông, cùng kích thước)
  Widget buildWorkoutButton(String text) {
    return Container(
      width: 100,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
