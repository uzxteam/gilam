import 'package:flutter/material.dart';
import 'package:gilam/menu/admin/hodimlar.dart';
import 'package:gilam/menu/admin/kirim_turi.dart';
import 'package:gilam/menu/admin/maxsulot.dart';
import 'package:gilam/menu/admin/mijozlar.dart';
import 'package:gilam/menu/admin/tariflar.dart';
import 'package:gilam/splash/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String userName = ''; // Foydalanuvchi ismi

  @override
  void initState() {
    super.initState();
    _loadUserName(); // Foydalanuvchi ismini yuklash
  }

  // SharedPreferences orqali user_name ni yuklash
  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'Admin'; // Default qiymat Admin bo'lsa
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // AppBar soyasini olib tashlash
        title: Align(
          alignment: Alignment.centerLeft, // Yozuvni chap tomonga joylashtirish
          child: Text(
            userName, // Foydalanuvchi ismi
            style: TextStyle(
              color: Colors.black, // Yozuv qora rangda
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.black, // AppBar iconlarini qora rangda qilish
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildMenuButton(
                icon: Icons.people,
                label: 'Hodimlar',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HodimlarPage()),
                  );
                },
              ),
              _buildMenuButton(
                icon: Icons.supervised_user_circle,
                label: 'Mijozlar',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MijozlarPage()),
                  );
                },
              ),
              _buildMenuButton(
                icon: Icons.category,
                label: 'Maxsulot turi',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MaxsulotTuriPage()),
                  );
                },
              ),
              _buildMenuButton(
                icon: Icons.rate_review,
                label: 'Tariflar',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => TariflarPage()),
                  );
                },
              ),
              _buildMenuButton(
                icon: Icons.attach_money,
                label: 'Kirim turi',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => KirimTuriPage()),
                  );
                },
              ),
              _buildMenuButton(
                icon: Icons.logout,
                label: 'Chiqish',
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); // SharedPreferences dagi barcha ma'lumotlarni o'chirish

                  // SplashScreen sahifasiga yo'naltirish
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => SplashScreen(), // SplashScreen sahifasini ochadi
                    ),
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  // Dizayni yaxshilangan menyu tugmasi
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Tugma orasidagi bo'shliq
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5, // Tugma soyasi uchun
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 28,
              color: Colors.white,
            ),
            SizedBox(width: 16), // Ikona va matn orasidagi bo'shliq
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
