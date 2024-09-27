import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gilam/menu/admin/adminhome.dart';
import 'package:gilam/menu/admin/adminhometest.dart';
import 'package:gilam/menu/dastavka/dastvakalogin.dart';
import 'package:gilam/menu/dastavka/dastavka.dart';
import 'package:gilam/menu/quritish/quritish.dart';
import 'package:gilam/menu/yuvish/yuvish.dart';
import 'package:gilam/menu/yuvish/yuvuvchilogin.dart';
import 'package:gilam/splash/login.dart';
import 'package:shared_preferences/shared_preferences.dart';  // SharedPreferences uchun kutubxona
import 'package:gilam/menu/zakaz/zakaz_home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus(); // Foydalanuvchi holatini tekshirish funksiyasi chaqiriladi
  }

  Future<void> _checkUserStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');  // user_id ni o'qish
    int? userStatus = prefs.getInt('user_status');  // user_status ni o'qish

    // 3 soniyadan keyin foydalanuvchini tekshirish va yo'naltirish
    Timer(Duration(seconds: 3), () {
      if (userId == null) {
        // Agar user_id bo'lmasa, LoginPage ga o'tish
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else if (userStatus == 1) {
        // Agar user_status 1 bo'lsa, ZakazHomePage ga o'tish
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ZakazHomePage()),
        );
      } else if (userStatus == 2) {
        // Agar user_status 1 bo'lsa, ZakazHomePage ga o'tish
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => YuvishPage()),
        );
      } else if (userStatus == 3) {
        // Agar user_status 1 bo'lsa, ZakazHomePage ga o'tish
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => QuritishPage()),
        );
      } else if (userStatus == 4) {
        // Agar user_status 1 bo'lsa, ZakazHomePage ga o'tish
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DastavkaPage()),
        );
      } else if (userStatus == 5) {
        // Agar user_status 1 bo'lsa, ZakazHomePage ga o'tish
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DastavkaLoginPage()),
        );
      } else if (userStatus == 6) {
        // Agar user_status 1 bo'lsa, ZakazHomePage ga o'tish
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => YuvuvchiLoginPage()),
        );
      }else {
        // Boshqa holatda, AdminHomePage ga o'tish
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminHomeTestPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Rasm markazda
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/splash.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Ekranning pastki qismida text
          Positioned(
            bottom: 30,
            right: 0,
            left: 0,
            child: Text(
              'by AlzaSoft.uz',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
