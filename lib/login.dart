import 'package:do_an_lt/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:do_an_lt/guess_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;
  bool acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [blue, red], 
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    SizedBox(width: 16),
                    Text(
                      "Quay lại",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),

              Center(
                child: Image.asset(
              'assets/icons/workout.png',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              ),
              ),
              SizedBox(height: 30),

              TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.3),
                  hintText: "Đăng nhập tài khoản",
                  hintStyle: TextStyle(color: Colors.white70,fontSize: 20),
                  prefixIcon: Icon(Icons.email, color: Colors.white,size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 15),

              TextField(
                style: TextStyle(color: Colors.white),
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.3),
                  hintText: "Mật khẩu",
                  hintStyle: TextStyle(color: Colors.white70,fontSize: 20),
                  prefixIcon: Icon(Icons.lock, color: Colors.white,size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Quên mật khẩu?",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),

              Row(
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (value) {
                      setState(() {
                        rememberMe = value!;
                      });
                    },
                    activeColor: Colors.white,
                    checkColor: Colors.red,
                  ),
                  Text("Ghi nhớ đăng nhập", style: TextStyle(color: Colors.white,fontSize: 18)),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        acceptTerms = value!;
                      });
                    },
                    activeColor: Colors.white,
                    checkColor: Colors.red,
                  ),
                  Text("Chấp nhận điều khoản dịch vụ.", style: TextStyle(color: Colors.white,fontSize: 18)),
                ],
              ),

              SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý đăng nhập tại đây
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text("Đăng nhập", style: TextStyle(color: Colors.red, fontSize: 18)),
                ),
              ),

              SizedBox(height: 15),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/register");
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Nếu chưa có tài khoản vui lòng đăng ký\n",
                      style: TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: "Tại đây",
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

