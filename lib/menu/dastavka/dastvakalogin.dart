import 'package:flutter/material.dart';
import 'package:gilam/menu/admin/dastavgabiriktirish.dart';
import 'package:gilam/menu/dastavka/dastavka.dart';
import 'package:gilam/menu/dastavka/lidadd.dart';
import 'package:gilam/menu/zakaz/zakaz_home.dart';
import 'package:gilam/splash/splash.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences kutubxonasini import qilish
import 'package:flutter/services.dart';

class DastavkaLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dastavka Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, // Debug bannerini o'chirish
      home: Scaffold(
        appBar: AppBar(
          title: Text('Dastavka Login'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout), // Logout ikonkasi
              onPressed: () async {
                // SharedPreferences ma'lumotlarini tozalash
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // SplashScreen-ga yo'naltirish
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SplashScreen()),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LidAddPage()),
                  );
                },
                child: Card(
                  color: Colors.blueAccent,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    height: 150,
                    child: Center(
                      child: Text(
                        'Zakazlar',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ZakazHomePage()),
                  );
                },
                child: Card(
                  color: Colors.blueAccent,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    height: 150,
                    child: Center(
                      child: Text(
                        'Zakaz Olish',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DastavkaPage()),
                  );
                },
                child: Card(
                  color: Colors.green,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    height: 150,
                    child: Center(
                      child: Text(
                        'Yetqazib Berish',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20), // Yangi kartalar orasida bo'shliq
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DastavgabiriktirishPage()),
                  );
                },
                child: Card(
                  color: Colors.orange,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    height: 150,
                    child: Center(
                      child: Text(
                        'Dastavkaga biriktirish',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
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

