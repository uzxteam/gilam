import 'package:flutter/material.dart';
import 'package:gilam/menu/dastavka/dastavkasubmit.dart';
import 'package:gilam/menu/dastavka/dastavkaupdate.dart'; // Yuborish sahifasi
import 'package:gilam/splash/splash.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Internet aloqasini tekshirish uchun

class DastavkaPage extends StatefulWidget {
  @override
  _DastavkaPageState createState() => _DastavkaPageState();
}

class _DastavkaPageState extends State<DastavkaPage> {
  List<Map<String, dynamic>> zakazlar = [];
  List<Map<String, dynamic>> offlineZakazlar = []; // Saqlangan offline ma'lumotlar
  Map<String, dynamic>? selectedZakaz;
  String userName = '';
  int offlineCount = 0; // Yuborilmagan ma'lumotlar sonini saqlash
  String formatSum(double sum) {
    final formatter = NumberFormat('#,###');
    return formatter.format(sum);
  }

  @override
  void initState() {
    super.initState();
    _loadCachedZakazlar();
    _fetchZakazlar();
    _loadUserDetails();
    _checkOfflineDataCount(); // Yuborilmagan ma'lumotlar sonini tekshirish
  }

  // Ma'lumotlarni SharedPreferences ga saqlash
  Future<void> _saveZakazlarToPrefs(List<Map<String, dynamic>> zakazlar) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String zakazlarJson = json.encode(zakazlar);
    await prefs.setString('cached_zakazlar', zakazlarJson);
  }

  // Saqlangan ma'lumotlarni yuklash
  Future<void> _loadCachedZakazlar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? zakazlarJson = prefs.getString('cached_zakazlar');
    if (zakazlarJson != null) {
      setState(() {
        zakazlar = List<Map<String, dynamic>>.from(json.decode(zakazlarJson));
      });
    }

    // Offline ma'lumotlarni yuklash
    String offlineZakazlarJson = prefs.getString('offline_zakazlar') ?? '[]';
    setState(() {
      offlineZakazlar = List<Map<String, dynamic>>.from(json.decode(offlineZakazlarJson));
    });
  }

  // API dan ma'lumotlarni olish
  Future<void> _fetchZakazlar() async {
    final url = 'https://visualai.uz/api/dastavka.php';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            zakazlar = List<Map<String, dynamic>>.from(data['data']);
          });
          _saveZakazlarToPrefs(zakazlar);
        } else if (data['status'] == 'error' && data['message'] == 'Zakazlar topilmadi') {
          await _clearCachedZakazlar(); // cached_zakazlar ni o'chirish
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Foydalanuvchi ma'lumotlarini olish
  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'User';
    });
  }

  // Yuborilmagan ma'lumotlar sonini tekshirish
  Future<void> _checkOfflineDataCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String zakazlarJson = prefs.getString('offline_zakazlar') ?? '[]';
    List<dynamic> offlineZakazlar = json.decode(zakazlarJson);
    setState(() {
      offlineCount = offlineZakazlar.length; // Yuborilmagan ma'lumotlar soni
    });
  }

  // cached_zakazlar ni o'chirish funksiyasi
  Future<void> _clearCachedZakazlar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_zakazlar'); // cached_zakazlar ni o'chirish
    setState(() {
      zakazlar = []; // zakazlar ro'yxatini bo'shatish
    });
  }

  // Foydalanuvchini chiqish funksiyasi
  Future<void> _logoutUser() async {
    // Chiqish uchun tasdiqlash oynasini ko'rsatish
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tasdiqlash'),
          content: Text('Haqiqatdan ham chiqishni istaysizmi?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // "Yo'q" tanlanganida dialogni yopish
              },
              child: Text('Yo\'q'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // "Ha" tanlanganida true qiymatini qaytarish
              },
              child: Text('Ha'),
            ),
          ],
        );
      },
    );

    // Agar foydalanuvchi "Ha" tugmasini bosgan bo'lsa, logoutni amalga oshirish
    if (confirmLogout == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Barcha saqlangan ma'lumotlarni o'chirish
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SplashScreen(), // SplashScreen sahifasini ochadi
        ),
      );
    }
  }

  // Telefon raqamiga qo'ng'iroq qilish funksiyasi
  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Telefon raqamiga qo\'ng\'iroq qilish mumkin emas: $phoneNumber');
    }
  }

  // Tanlangan zakaz ma'lumotlarini ko'rsatish uchun karta
  Widget _buildZakazCard(Map<String, dynamic> zakaz) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedZakaz = zakaz; // Zakaz tanlanganda selectedZakaz o'rnatiladi
        });
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'ID: ${zakaz['zakaz_id']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: selectedZakaz == zakaz ? Colors.green : Colors.black, // Tanlangan zakaz yashil rangda bo'ladi
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${zakaz['mijoz']['mijoz_ismi']}',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedZakaz == zakaz ? Colors.green : Colors.black, // Tanlangan zakaz yashil rangda bo'ladi
                      ),
                    ),
                  ),
                  // Call Icon
                  IconButton(
                    icon: Icon(Icons.call, color: Colors.blue),
                    onPressed: () {
                      _makePhoneCall(zakaz['mijoz']['mijoz_telefon']);
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Adres: ${zakaz['mijoz']['mijoz_adres']}',
                style: TextStyle(
                  fontSize: 16,
                  color: selectedZakaz == zakaz ? Colors.green : Colors.black, // Tanlangan zakaz yashil rangda bo'ladi
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Detallarni ko'rsatish uchun karta
  Widget _buildDetailsCard() {
    if (selectedZakaz == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40), // Yozuvni biroz pastga tushirish uchun padding qo'shildi
        child: Center(
          child: Text(
            'Zakaz ma\'lumotlarini ko\'rish uchun zakazni tanlang',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Column(
      children: List<Widget>.from(selectedZakaz!['zakazlar'].map((detail) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Maxsulot Turi: ${detail['maxsulot_turi']['nomi']}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Soni: ${detail['zakaz_soni']} dona',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Kvadrat: ${detail['zakaz_kvadrat']} m2',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Summa: ${formatSum(double.tryParse(detail['zakaz_summa'].toString()) ?? 0)} so\'m',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Tarif: ${detail['zakaz_tarif']['nomi']}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }).toList()),
    );
  }

  // Agar ma'lumotlar bo'lmasa, "Ma'lumot topilmadi" xabarini ko'rsatish
  Widget _buildNoDataMessage() {
    return Center(
      child: SingleChildScrollView(
        // SingleChildScrollView qo'shildi
        physics: AlwaysScrollableScrollPhysics(), // Ekranni pastga tortib yangilash uchun imkon yaratadi
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/not_found.png',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),
            Text(
              'Ma\'lumot topilmadi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Yangilash uchun ekranni pastga torting',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Internet mavjudligini tekshirish funksiyasi
  Future<bool> _isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Widget build(BuildContext context) {
    // Offline ma'lumotlar bo'lsa, ularni ro'yxatdan olib tashlash
    List<Map<String, dynamic>> filteredZakazlar = zakazlar.where((zakaz) {
      return !offlineZakazlar.any((offlineZakaz) => offlineZakaz['zakaz_id'] == zakaz['id']);
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true, // AppBar orqasida ham kontentni kengaytirish
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBarni shaffof qilish
        elevation: 0, // So'ya effektini olib tashlash
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/splash.jpg', // Logotip uchun rasmni qo'shing
            fit: BoxFit.contain,
          ),
        ),
        title: Center(
          child: Text(
            userName,
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.cloud_upload, color: Colors.green),
                onPressed: () async {
                  bool connected = await _isConnected();
                  if (connected) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DastavkaUpdatePage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Internet mavjud emas, iltimos internetni yoqing.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
              ),
              if (offlineCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '$offlineCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: _logoutUser,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Orqa fon rasmi
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'), // Fon rasmi
                fit: BoxFit.cover, // Rasmni ekranga moslashtirish
              ),
            ),
          ),
          // Asosiy kontent
          Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchZakazlar, // Yangilash uchun API-ga murojaat
                  child: filteredZakazlar.isEmpty
                      ? _buildNoDataMessage() // Ma'lumot bo'lmasa, xabar va rasm ko'rsatish
                      : ListView(
                    children: [
                      // Yuqori qismdagi Zakaz kartasi
                      Column(
                        children: filteredZakazlar.map((zakaz) => _buildZakazCard(zakaz)).toList(),
                      ),
                      // Pastki qismdagi detallar kartasi
                      _buildDetailsCard(),
                    ],
                  ),
                ),
              ),
              // Tastiqlash tugmasi doim ekranning pastki qismida bo'lishi uchun
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Tugmalar orasida bo'shliq yaratish
                  children: [
                    // Orqaga tugmasi
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Orqaga qaytish
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        backgroundColor: Colors.red, // "Orqaga" tugmasi qizil rangda
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Orqaga',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    // Keyingisi tugmasi
                    ElevatedButton(
                      onPressed: selectedZakaz != null
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DastavkaSubmitPage(zakaz: selectedZakaz!), // Tanlangan zakazni yuborish
                          ),
                        );
                      }
                          : null, // Agar zakaz tanlanmagan bo'lsa, tugma faol bo'lmaydi
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        backgroundColor: selectedZakaz != null ? Colors.green : Colors.grey, // Tanlangan bo'lsa, yashil, aks holda kul rangda
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Keyingisi',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),


            ],
          ),
        ],
      ),
    );
  }
}
