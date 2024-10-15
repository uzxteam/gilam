import 'dart:convert'; // JSON konvertatsiya qilish uchun
import 'package:flutter/material.dart';
import 'package:gilam/splash/splash.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences uchun

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = ''; // Xatolik xabarini ko'rsatish uchun

  Future<void> _login(BuildContext context) async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // API'ga so'rov yuborish
    var url = Uri.parse('https://visualai.uz/apidemo/user_check.php');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_username': username,
        'user_password': password,
      }),
    );

    // API javobini qayta ishlash
    var data = jsonDecode(response.body);
    if (data['error'] == false) {
      // Foydalanuvchi topildi, ma'lumotlarni saqlash
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', data['data']['id']);
      await prefs.setString('user_name', data['data']['user_name']);
      await prefs.setString('user_username', data['data']['user_username']);
      await prefs.setInt('user_status', data['data']['user_status']);
      await prefs.setInt('user_admin', data['data']['user_admin']);

      // SplashScreen sahifasiga yo'naltirish
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    } else {
      // Xatolik xabarini ko'rsatish
      setState(() {
        errorMessage = data['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Klaviatura balandligini aniqlash uchun
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - keyboardHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Kengligi to'liq bo'lishi uchun
              children: [
                // Rasm yuqorida kichikroq ko'rinishi uchun
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/splash.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                // Username input field
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    labelText: 'Username',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Password input field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                // Zamonaviy Saqlash button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent, // Tugma rangi
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Yuvarlak tugma
                    ),
                  ),
                  onPressed: () => _login(context), // Saqlash tugmasi bosilganda login
                  child: Text(
                    'Kirish',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Xatolik xabarini ko'rsatish
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
