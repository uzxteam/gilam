import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // url_launcher kutubxonasini import qilish
import 'package:permission_handler/permission_handler.dart';

class MijozlarPage extends StatefulWidget {
  @override
  _MijozlarPageState createState() => _MijozlarPageState();
}

class _MijozlarPageState extends State<MijozlarPage> {
  List<dynamic> customers = [];
  bool isError = false;

  Future<void> _requestPermissions() async {
    var status = await Permission.phone.status;
    if (!status.isGranted) {
      await Permission.phone.request();
    }
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadStoredCustomers(); // Avvalgi ma'lumotlarni yuklash
    _fetchCustomers(); // API orqali yangi ma'lumotlarni yuklash
  }

  // Avvalgi saqlangan mijozlar ma'lumotlarini SharedPreferences dan yuklash
  Future<void> _loadStoredCustomers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('customers_data');
    if (storedData != null) {
      setState(() {
        customers = json.decode(storedData);
      });
    }
  }

  // API orqali mijozlar ro'yxatini yuklash va SharedPreferences ga saqlash
  Future<void> _fetchCustomers() async {
    final url = 'https://visualai.uz/api/mijozlar.php';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          setState(() {
            customers = data['data'];
            isError = false; // Error yo'qligini belgilash
          });
          // Ma'lumotlarni SharedPreferences ga saqlash
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('customers_data', json.encode(data['data']));
        } else {
          setState(() {
            isError = true; // Error borligini belgilash
          });
        }
      }
    } catch (e) {
      setState(() {
        isError = true; // Error borligini belgilash
      });
      print('Error: $e');
    }
  }

  // Telefon raqamiga qo'ng'iroq qilish uchun funksiyani yaratish
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunch(launchUri.toString())) {
      await launch(
        launchUri.toString(),
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      print('Could not launch $phoneNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft, // Yozuvni chap tomonga joylashtirish
          child: Text(
            'Mijozlar',
            style: TextStyle(
              color: Colors.black, // Yozuv qora rangda
            ),
          ),
        ),
        backgroundColor: Colors.white, // AppBar rangini oq qilish
        iconTheme: IconThemeData(
          color: Colors.black, // Orqaga qaytish iconini qora rangda qilish
        ),
      ),
      body: isError
          ? _buildErrorContent() // Agar error bo'lsa, xatolik kontentini ko'rsatish
          : customers.isEmpty
          ? Center(child: CircularProgressIndicator()) // Ma'lumotlar yuklanayotganda
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index];
            return _buildCustomerCard(customer);
          },
        ),
      ),
    );
  }

  // Xatolik bo'lganda ko'rsatiladigan kontent
  Widget _buildErrorContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/not_found.png', // Xatolik rasmi
            width: 150,
            height: 150,
          ),
          SizedBox(height: 20),
          Text(
            'Ma\'lumot topilmadi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Har bir mijoz uchun karta yaratish
  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.person,
              size: 50,
              color: Colors.blueAccent,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer['mijoz_ismi'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    customer['mijoz_telefon'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    customer['mijoz_adres'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.phone),
              color: Colors.green,
              onPressed: () {
                _makePhoneCall(customer['mijoz_telefon']);
              },
            ),
          ],
        ),
      ),
    );
  }
}
