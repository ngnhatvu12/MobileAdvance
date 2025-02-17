import 'package:do_an_lt/Theme/Colors.dart';
import 'package:flutter/material.dart';

class GuessPage extends StatelessWidget {
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
  clipBehavior: Clip.none, // Cho phép container con nằm ngoài phạm vi của Stack
  children: [
    // Container màu đỏ với bo tròn góc dưới
    Container(
      width: double.infinity,
      height: 200, 
      padding: EdgeInsets.only(top: 100, bottom: 40), // Tăng bottom để có không gian chồng lên
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Text(
            "Kính chào quý khách hàng !",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
    
    // Container chứa nút đăng nhập & đăng ký, đặt chồng lên viền dưới
    Positioned(
      left: 20, // Canh lề trái theo mép màn hình
      right: 20, // Canh lề phải theo mép màn hình
      bottom: -50, // Đẩy container xuống dưới một chút để đè lên viền
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildLoginButton(Icons.login, "Đăng nhập", context),
            buildLoginButton(Icons.edit, "Đăng ký", context),
          ],
        ),
      ),
    ),
  ],
),
            SizedBox(height: 50),

            // 🔵 DANH SÁCH CHỨC NĂNG
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  buildFeatureButton(Icons.calendar_today, "Đặt lịch tập luyện"),
                  buildFeatureButton(Icons.person, "Đặt lịch HLV"),
                  buildFeatureButton(Icons.event, "Lịch học"),
                  buildFeatureButton(Icons.shopping_cart, "Mua dịch vụ"),
                  buildFeatureButton(Icons.card_membership, "Mở thẻ tập"),
                ],
              ),
            ),

            SizedBox(height: 20),

            // 🔥 NÚT CÁC BÀI TẬP
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                buildWorkoutButton("GYM"),
                buildWorkoutButton("CYCLING"),
                buildWorkoutButton("BƠI"),
                buildWorkoutButton("CIRCUIT"),
                buildWorkoutButton("DANCE"),
                buildWorkoutButton("GROUP X"),
              ],
            ),

            SizedBox(height: 20),

            // 🖼️ BANNER QUẢNG CÁO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Image.network(
                "https://via.placeholder.com/300x100", // Thay bằng ảnh banner thực tế
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 🎯 NÚT ĐĂNG NHẬP / ĐĂNG KÝ
  Widget buildLoginButton(IconData icon, String text, BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (text == "Đăng nhập") {
            Navigator.pushNamed(context, "/login");
          } else {
            Navigator.pushNamed(context, "/register");
          }
        },
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.red),
            SizedBox(height: 5),
            Text(text, style: TextStyle(color: Colors.black, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // 🛠️ CÁC CHỨC NĂNG (ĐẶT LỊCH, MUA DỊCH VỤ,...)
  Widget buildFeatureButton(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(height: 5),
        Text(
          text,
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 💪 CÁC NÚT TẬP LUYỆN (GYM, CYCLING,...)
  Widget buildWorkoutButton(String text) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
