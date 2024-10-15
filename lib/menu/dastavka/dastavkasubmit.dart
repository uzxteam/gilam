import 'package:flutter/material.dart';
import 'package:gilam/format.dart';
import 'package:gilam/menu/dastavka/dastavka.dart';
import 'package:gilam/splash/splash.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Internet aloqasini tekshirish uchun
import 'dart:io'; // Internet xatolarini ushlash uchun

class DastavkaSubmitPage extends StatefulWidget {
  final Map<String, dynamic> zakaz;

  DastavkaSubmitPage({required this.zakaz});

  @override
  _DastavkaSubmitPageState createState() => _DastavkaSubmitPageState();
}

class _DastavkaSubmitPageState extends State<DastavkaSubmitPage> {
  double naqtSumma = 0;
  double otkazmaSumma = 0;
  double skidkaSumma = 0;
  double tolashiKerakSumma = 0;
  double jamiSumma = 0;
  double eskiNaqtSumma = 0;
  double eskiOtkazmaSumma = 0;
  double eskiSkidkaSumma = 0;
  double qoldiqSumma = 0;
  int? userId;

  // TextField controllerlari
  TextEditingController naqtController = TextEditingController();
  TextEditingController otkazmaController = TextEditingController();
  TextEditingController skidkaController = TextEditingController();
  String formatSum(double sum) {
    final formatter = NumberFormat('#,###');
    return formatter.format(sum);
  }

  @override
  void initState() {
    super.initState();
    _loadUserId(); // user_idni yuklash
    _initializeFields(); // Kiritilgan maydonlarni boshlash
  }

  // SharedPreferences dan user_id ni yuklash
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id'); // user_id ni yuklash
    });
  }

  // Naqt, O'tkazma va Skidka summalarini boshlash
  void _initializeFields() {
    var tolovlar = widget.zakaz['tolovlar'] ?? [];
    var details = widget.zakaz['zakazlar'] ?? [];

    for (var tolov in tolovlar) {
      if (tolov['tolov_turi'] == 1) {
        naqtSumma += double.tryParse(tolov['summa']?.toString() ?? '0') ?? 0;
        eskiNaqtSumma = naqtSumma;
      } else if (tolov['tolov_turi'] == 2) {
        otkazmaSumma += double.tryParse(tolov['summa']?.toString() ?? '0') ?? 0;
        eskiOtkazmaSumma = otkazmaSumma;
      }
    }

    skidkaSumma = double.tryParse(widget.zakaz['skidka_summa']?.toString() ?? '0') ?? 0;
    eskiSkidkaSumma = skidkaSumma;
    jamiSumma = double.tryParse(widget.zakaz['jami_summa']?.toString() ?? '0') ?? 0;
    qoldiqSumma = double.tryParse(widget.zakaz['qoldiq_summa']?.toString() ?? '0') ?? 0;
    tolashiKerakSumma = jamiSumma - skidkaSumma - naqtSumma - otkazmaSumma;

    naqtController.text = '';
    otkazmaController.text = '';
    skidkaController.text = '';
  }

  // Qoldiq summani yangilash
  void _updateQoldiqSumma() {
    setState(() {
      tolashiKerakSumma = jamiSumma - skidkaSumma - naqtSumma - otkazmaSumma;
    });
  }

  // Internet mavjudligini tekshirish funksiyasi
  Future<bool> _isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Ma'lumotlarni saqlash funksiyasi (internet ishlamasa)
  Future<void> _saveDataOffline(Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String zakazlar = prefs.getString('offline_zakazlar') ?? '[]';
    List<dynamic> offlineZakazlar = json.decode(zakazlar);
    offlineZakazlar.add(data);
    prefs.setString('offline_zakazlar', json.encode(offlineZakazlar));
    _showOfflineDataInfo(); // Saqlanganlik haqida xabar berish
  }

  // Saqlangan offline ma'lumotlarni ko'rsatish
  Future<void> _showOfflineDataInfo() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Internet mavjud emas. Ma\'lumotlar vaqtincha saqlandi.'),
        duration: Duration(seconds: 3),
      ),
    );
    // Xabar ko'rsatilgandan keyin DastavkaPage sahifasiga yo'naltirish
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DastavkaPage()),
    );
  }

  // API ga ma'lumotlarni yuborish funksiyasi
  Future<void> submitData() async {
    double yangiNaqt = double.tryParse(naqtController.text) ?? 0;
    double yangiOtkazma = double.tryParse(otkazmaController.text) ?? 0;
    double yangiSkidka = double.tryParse(skidkaController.text) ?? 0;

    naqtSumma += yangiNaqt;
    otkazmaSumma += yangiOtkazma;
    skidkaSumma += yangiSkidka;

    final requestData = {
      'user_id': userId,
      'zakaz_id': widget.zakaz['id'],
      'jami_summa': jamiSumma.toString(),
      'skidka_summa': skidkaSumma.toString(),
      'qoldiq_summa': (tolashiKerakSumma).toString(),
      'tolovlar': [
        {'tolov_turi': '1', 'summa': naqtSumma.toString()},
        {'tolov_turi': '2', 'summa': otkazmaSumma.toString()},
      ]
    };

    // Internet mavjudligini tekshirish
    bool connected = await _isConnected();

    if (connected) {
      try {
        final response = await http.post(
          Uri.parse('https://visualai.uz/apidemo/dastavka_add.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestData),
        );

        if (response.statusCode == 200) {
          print('Ma\'lumotlar muvaffaqiyatli yuborildi');
          print('Javob: ${response.body}');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DastavkaPage()),
          );
        } else {
          print('Xatolik: ${response.statusCode}');
          await _saveDataOffline(requestData); // Server xatoligida offline saqlash
        }
      } on SocketException {
        print('Internetga ulanishda muammo yuz berdi');
        await _saveDataOffline(requestData); // Ulanish xatosida offline saqlash
      } catch (e) {
        print('Xatolik: $e');
        await _saveDataOffline(requestData); // Boshqa xatolarda offline saqlash
      }
    } else {
      await _saveDataOffline(requestData); // Internet bo'lmasa offline saqlash
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/splash.jpg',
              width: 50,
              height: 50,
            ),
            Text(
              'User Name',
              style: TextStyle(color: Colors.white),
            ),
            IconButton(
              icon: Icon(Icons.logout, color: Colors.red),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => SplashScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.green,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zakaz ID: ${widget.zakaz['zakaz_id']}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text('Mijoz: ${widget.zakaz['mijoz']['mijoz_ismi']}'),
                      Row(
                        children: [
                          Text('Telefon: '),
                          GestureDetector(
                            onTap: () async {
                              final phoneNumber = widget.zakaz['mijoz']['mijoz_telefon'];
                              final url = 'tel:$phoneNumber';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                print('Telefon raqamiga qo\'ng\'iroq qilish mumkin emas: $phoneNumber');
                              }
                            },
                            child: Row(
                              children: [
                                Icon(Icons.phone, color: Colors.blue),
                                SizedBox(width: 4),
                                Text(
                                  widget.zakaz['mijoz']['mijoz_telefon'],
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text('Adres: ${widget.zakaz['mijoz']['mijoz_adres']}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Zakaz Detallari:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.zakaz['zakazlar'].length,
                  itemBuilder: (context, index) {
                    var detail = widget.zakaz['zakazlar'][index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Maxsulot: ${detail['maxsulot_turi']['nomi']}',
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
                  },
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Umumiy Ma\'lumotlar:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Jami: ${formatSum(double.tryParse(widget.zakaz['jami_summa'].toString()) ?? 0)} so\'m'),
                  Text('Skidka: ${formatSum(double.tryParse(skidkaSumma.toString()) ?? 0)} so\'m'),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tolangan: ${formatSum(naqtSumma + otkazmaSumma)} so\'m'),
                  Text('Qoldiq: ${formatSum(double.tryParse(tolashiKerakSumma.toString()) ?? 0)} so\'m'),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.28,
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Naqt',
                      ),
                      keyboardType: TextInputType.number,
                      controller: naqtController,
                      onChanged: (value) {
                        setState(() {
                          double yangiNaqt = double.tryParse(value.isEmpty ? '0' : value) ?? 0;
                          naqtSumma = eskiNaqtSumma + yangiNaqt;
                          _updateQoldiqSumma();
                        });
                      },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.28,
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'O\'tkazma',
                      ),
                      keyboardType: TextInputType.number,
                      controller: otkazmaController,
                      onChanged: (value) {
                        setState(() {
                          double yangiOtkazma = double.tryParse(value.isEmpty ? '0' : value) ?? 0;
                          otkazmaSumma = eskiOtkazmaSumma + yangiOtkazma;
                          _updateQoldiqSumma();
                        });
                      },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.28,
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Skidka',
                      ),
                      keyboardType: TextInputType.number,
                      controller: skidkaController,
                      onChanged: (value) {
                        setState(() {
                          double yangiSkidka = double.tryParse(value.isEmpty ? '0' : value) ?? 0;
                          skidkaSumma = eskiSkidkaSumma + yangiSkidka;
                          _updateQoldiqSumma();
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    submitData();
                  },
                  icon: Icon(Icons.check, color: Colors.white),
                  label: Text(
                    'Topshirish',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
