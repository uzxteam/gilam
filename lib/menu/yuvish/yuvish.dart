import 'package:flutter/material.dart';
import 'package:gilam/splash/splash.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class YuvishPage extends StatefulWidget {
  @override
  _YuvishPageState createState() => _YuvishPageState();
}

class _YuvishPageState extends State<YuvishPage> {
  List<Map<String, dynamic>> zakazlar = []; // Zakazlar ro'yxati
  String? selectedZakazId; // Tanlangan zakaz_id
  String userName = ''; // Foydalanuvchi ismi
  int? userId; // Foydalanuvchi ID
  List<TextEditingController> kvadratControllers = []; // Kvadrat qiymatlari uchun controllerlar
  List<String> initialKvadratValues = []; // Kvadratning dastlabki qiymatlari

  @override
  void initState() {
    super.initState();
    _loadSavedZakazlar(); // Saqlangan zakazlarni yuklash
    _fetchZakazlar(); // Zakazlarni yuklash
    _loadUserDetails(); // Foydalanuvchi ma'lumotlarini yuklash
  }

  // Saqlangan zakazlar ro'yxatini yuklash
  Future<void> _loadSavedZakazlar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedZakazlar = prefs.getString('zakazlar');
    if (savedZakazlar != null) {
      setState(() {
        zakazlar = List<Map<String, dynamic>>.from(json.decode(savedZakazlar));
      });
    }
  }

  // API orqali zakazlar ro'yxatini yuklash
  Future<void> _fetchZakazlar() async {
    final url = 'https://visualai.uz/api/yuvish.php';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            zakazlar = List<Map<String, dynamic>>.from(data['data']);
          });
          // Ma'lumotlarni saqlash
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('zakazlar', json.encode(zakazlar));
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Foydalanuvchi ma'lumotlarini yuklash
  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'User';
      userId = prefs.getInt('user_id'); // user_id ni yuklash
    });
  }

  // Foydalanuvchini chiqish va ma'lumotlarini o'chirish
  Future<void> _logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Barcha saqlangan ma'lumotlarni o'chirish
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  }

  // Zakaz details ni ko'rsatish uchun yordamchi funksiya
  Widget _buildZakazDetails() {
    if (selectedZakazId == null) return Container(); // Agar zakaz tanlanmagan bo'lsa bo'sh container qaytarish
    final selectedZakaz = zakazlar.firstWhere((zakaz) => zakaz['zakaz_id'].toString() == selectedZakazId);
    final details = selectedZakaz['zakazlar'] as List<dynamic>;

    // Controllerlarni yaratish va dastlabki qiymatlarni saqlash
    kvadratControllers = List<TextEditingController>.generate(
      details.length,
          (index) => TextEditingController(text: details[index]['zakaz_kvadrat'].toString()),
    );
    initialKvadratValues = details.map<String>((detail) => detail['zakaz_kvadrat'].toString()).toList();

    return Expanded(
      child: ListView.builder(
        itemCount: details.length,
        itemBuilder: (context, index) {
          var detail = details[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Maxsulot turi, soni va kvadratini bir qator ko'rsatish
                  Expanded(
                    child: Text(
                      '${detail['maxsulot_turi']['nomi']} - ${detail['zakaz_soni']} dona - ${detail['zakaz_kvadrat']} m2',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  // Kvadrat qiymatini o'zgartirish uchun input
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: kvadratControllers[index],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Kvadrat',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // O'zgartirilgan ma'lumotlarni qabul qilish uchun funksiya
  Future<void> _confirmChanges() async {
    if (selectedZakazId == null || userId == null) return;

    List<Map<String, dynamic>> updatedDetails = [];
    final selectedZakaz = zakazlar.firstWhere((zakaz) => zakaz['zakaz_id'].toString() == selectedZakazId);
    final details = selectedZakaz['zakazlar'] as List<dynamic>;

    for (int i = 0; i < details.length; i++) {
      // Faqat o'zgartirilgan kvadrat qiymatlarini olish
      if (kvadratControllers[i].text.isNotEmpty) {
        updatedDetails.add({
          'tbl_zakazlar_id': details[i]['id'], // zakazlar_id emas id orqali olish
          'zakaz_kvadrat': double.parse(kvadratControllers[i].text),
          'zakaz_kvadrat_eski': double.parse(initialKvadratValues[i]),
        });
      } else {
        // Agar input bo'sh bo'lsa, eski qiymatni yuborish
        updatedDetails.add({
          'tbl_zakazlar_id': details[i]['id'], // zakazlar_id emas id orqali olish
          'zakaz_kvadrat': double.parse(initialKvadratValues[i]),
          'zakaz_kvadrat_eski': double.parse(initialKvadratValues[i]),
        });
      }
    }

    // Yangi ma'lumotlarni API ga yuborish
    Map<String, dynamic> requestData = {
      'user_id': userId,
      'zakaz_id': selectedZakaz['id'], // zakaz_id emas id orqali yuborish
      'zakazlar': updatedDetails,
    };

    final url = 'https://visualai.uz/api/yuvuv_update.php';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          // Muvaffaqiyatli yangilanganligi haqida xabar ko'rsatish
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ma\'lumotlar muvaffaqiyatli yangilandi')),
          );
          // Sahifani yangilash
          _fetchZakazlar();
          setState(() {
            selectedZakazId = null; // Tanlangan zakazni o'chirish
          });
        } else {
          // Xato xabarini ko'rsatish
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Yangilashda xatolik yuz berdi')),
          );
        }
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server bilan bog\'lanishda xatolik yuz berdi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/splash.jpg',
              width: 50,
              height: 50,
            ),
            Row(
              children: [
                Text(
                  userName,
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.red),
                  onPressed: _logoutUser,
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Orqa fon rasmi
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Kontent
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Zakazlar Dropdown
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: Text('Zakazni tanlang'),
                    value: selectedZakazId,
                    items: zakazlar
                        .map((zakaz) => DropdownMenuItem<String>(
                      value: zakaz['zakaz_id'].toString(), // String qiymat berish
                      child: Text(
                        zakaz['zakaz_id'].toString(),
                        style: TextStyle(fontSize: 16),
                      ),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedZakazId = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                // Zakaz details
                _buildZakazDetails(),
                // Tastiqlash tugmasi
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Tastiqlash bosilganda qabul qilinadigan harakatlar
                    _confirmChanges();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Tastiqlash',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
