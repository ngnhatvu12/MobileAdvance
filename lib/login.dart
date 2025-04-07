import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:do_an_lt/theme/colors.dart';
import 'Customer/Home/customer_main.dart'; 
import 'Coach/Dashboard/coach_main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool rememberMe = false;
  bool acceptTerms = true; // Mặc định tích chọn

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // Load thông tin đăng nhập đã lưu
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;
      if (rememberMe) {
        _usernameController.text = prefs.getString('savedEmail') ?? '';
        _passwordController.text = prefs.getString('savedPassword') ?? '';
      }
    });
  }

  // Lưu thông tin đăng nhập
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('savedEmail', _usernameController.text);
      await prefs.setString('savedPassword', _passwordController.text);
    } else {
      await prefs.setBool('rememberMe', false);
      await prefs.remove('savedEmail');
      await prefs.remove('savedPassword');
    }
  }

  Future<void> _login() async {
    if (!acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chấp nhận điều khoản dịch vụ")),
      );
      return;
    }

    String email = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập email và mật khẩu")),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Lưu thông tin đăng nhập nếu được chọn
      await _saveCredentials();

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String role = userDoc['role'];

        if (role == "customer") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CustomerMainPage()),
          );
        } else if (role == "coach") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CoachMainPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Vai trò không hợp lệ")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Người dùng không tồn tại")),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng nhập thất bại: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }

  // Hàm xử lý quên mật khẩu
  Future<void> _resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email đặt lại mật khẩu đã được gửi")),
      );
      Navigator.pop(context); // Đóng dialog quên mật khẩu
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${e.message}")),
      );
    }
  }

  // Hiển thị dialog quên mật khẩu
  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Quên mật khẩu"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Nhập email của bạn để nhận liên kết đặt lại mật khẩu"),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () => _resetPassword(emailController.text.trim()),
              child: const Text("Gửi"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
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
                SizedBox(height: 10),
                Center(
                  child: Image.asset(
                    'assets/icons/workout.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                      margin: EdgeInsets.only(top: 30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 30),
                          TextField(
                            controller: _usernameController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.3),
                              hintText: "Đăng nhập tài khoản",
                              hintStyle: TextStyle(color: Colors.white70, fontSize: 20),
                              prefixIcon: Icon(Icons.email, color: Colors.white, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          TextField(
                            controller: _passwordController,
                            style: TextStyle(color: Colors.white),
                            obscureText: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.3),
                              hintText: "Mật khẩu",
                              hintStyle: TextStyle(color: Colors.white70, fontSize: 20),
                              prefixIcon: Icon(Icons.lock, color: Colors.white, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Đăng nhập",
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
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
                    Text("Ghi nhớ đăng nhập", style: TextStyle(color: Colors.white, fontSize: 18)),
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
                    Text("Chấp nhận điều khoản dịch vụ.", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
                SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: acceptTerms ? _login : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: acceptTerms ? Colors.white : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("Đăng nhập", style: TextStyle(color: acceptTerms ? Colors.red : Colors.white, fontSize: 18)),
                  ),
                ),

                SizedBox(height: 10),

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
      ),
    );
  }
}