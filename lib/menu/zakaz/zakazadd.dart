import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../format.dart';
import 'zakaz_home.dart';

class ZakazAddPage extends StatefulWidget {
  final double totalSum;
  final List<Map<String, dynamic>> inputData;

  ZakazAddPage({required this.totalSum, required this.inputData});

  @override
  _ZakazAddPageState createState() => _ZakazAddPageState();
}

class _ZakazAddPageState extends State<ZakazAddPage> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController(text: '+998');
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _skidkaSummaController = TextEditingController();
  final TextEditingController _tolovSummaController = TextEditingController();
  final TextEditingController _qoldiqSummaController = TextEditingController();
  final TextEditingController _izohController = TextEditingController();
  final TextEditingController _naqdController = TextEditingController();
  final TextEditingController _otkazmaController = TextEditingController();

  int unsentOrdersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnsentOrdersCount(); // Yuborilmagan buyurtmalar sonini yuklash
    _tolovSummaController.text = formatSum(widget.totalSum);
    _calculateRemainingSum();
  }
  String formatSum(double sum) {
    final formatter = NumberFormat('#,###');
    return formatter.format(sum);
  }
  // Yuborilmagan buyurtmalar sonini yuklash funksiyasi
  Future<void> _loadUnsentOrdersCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedOrders = prefs.getStringList('pending_orders') ?? [];
    setState(() {
      unsentOrdersCount = storedOrders.length; // Yuborilmagan buyurtmalar sonini o'rnatish
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          // Body content
          Column(
            children: [
              // Logotip va Jami summa joylashgan oddiy satr
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logotip
                    Image.asset(
                      'assets/splash.jpg',
                      width: 80, // Kottaroq logotip
                      height: 80,
                    ),
                    // Jami summa va Yuborish tugmasi
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Jami summa tugmasi bosilganda nima bo'lishini yozing
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16), // Tugma hajmi
                            backgroundColor: Colors.blueAccent, // Tugma rangi
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Jami: ${formatSum(widget.totalSum)}',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 10), // Bo'sh joy
                        Stack(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _sendStoredOrders(context); // Saqlangan ma'lumotlarni yuborish
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                backgroundColor: Colors.green, // Tugma rangi
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12), // Tugma burchaklari
                                ),
                              ),
                              child: Icon(Icons.send, color: Colors.white), // Faqat ikonka
                            ),
                            // Yuborilmagan buyurtmalar sonini ko'rsatish uchun belgisi
                            if (unsentOrdersCount > 0)
                              Positioned(
                                right: 5,
                                top: 5,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$unsentOrdersCount', // Yuborilmagan buyurtmalar soni
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        // Zakaz ID
                        Text(
                          "ZakazID: 123456", // Zakaz ID misol
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        // Mijoz ismi input
                        TextField(
                          controller: _customerNameController,
                          decoration: InputDecoration(
                            labelText: 'Mijoz ismi',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Telefon raqam input
                        TextField(
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Telefon raqam',
                            hintText: '+998907874867',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Adres input
                        TextField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Adres',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Naqd va O'tkazma input maydonlari
                        Row(
                          children: [
                            // Naqd input
                            Expanded(
                              child: TextField(
                                controller: _naqdController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [NumberInputFormatter()],
                                decoration: InputDecoration(
                                  labelText: 'Naqd',
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (value) {
                                  _calculateRemainingSum(); // Naqd qiymati o'zgarganda qayta hisoblash
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            // O'tkazma input
                            Expanded(
                              child: TextField(
                                controller: _otkazmaController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [NumberInputFormatter()],
                                decoration: InputDecoration(
                                  labelText: 'O\'tkazma',
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (value) {
                                  _calculateRemainingSum(); // O'tkazma qiymati o'zgarganda qayta hisoblash
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        // Skidka summa input
                        TextField(
                          controller: _skidkaSummaController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [NumberInputFormatter()],
                          decoration: InputDecoration(
                            labelText: 'Skidka summa',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            _calculateRemainingSum(); // Skidka qiymati o'zgarganda qayta hisoblash
                          },
                        ),
                        SizedBox(height: 20),
                        // Tolov summa input (jami summa bu yerda ko'rsatiladi)
                        TextField(
                          controller: _tolovSummaController,
                          keyboardType: TextInputType.number,
                          readOnly: true, // Faqat o'qish uchun maydon
                          decoration: InputDecoration(
                            labelText: 'Jami summa',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Qoldiq summa input
                        TextField(
                          controller: _qoldiqSummaController,
                          keyboardType: TextInputType.number,
                          readOnly: true, // Faqat o'qish uchun maydon
                          decoration: InputDecoration(
                            labelText: 'Qoldiq summa',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Izoh input (katta)
                        TextField(
                          controller: _izohController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Izoh',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Orqaga va Tasdiqlash tugmalari
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Orqaga qaytish
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        backgroundColor: Colors.grey, // Orqaga tugmasi rangi
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Orqaga",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Tasdiqlash bosilganda ma'lumotlarni saqlash
                        _saveOrder(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        backgroundColor: Colors.green, // Tasdiqlash tugmasi rangi
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Tasdiqlash",
                        style: TextStyle(fontSize: 16, color: Colors.white),
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

  // Qoldiq summani hisoblash funksiyasi
  void _calculateRemainingSum() {
    double naqdSumma = double.tryParse(_naqdController.text.replaceAll(',', '')) ?? 0.0;
    double otkazmaSumma = double.tryParse(_otkazmaController.text.replaceAll(',', '')) ?? 0.0;
    double skidkaSumma = double.tryParse(_skidkaSummaController.text.replaceAll(',', '')) ?? 0.0;

    double jamiSumma = widget.totalSum;
    double tolanganSumma = naqdSumma + otkazmaSumma;

    double qoldiqSumma = jamiSumma - (tolanganSumma + skidkaSumma);

    _qoldiqSummaController.text = formatSum(qoldiqSumma); // Formatlangan summani o'rnatish
  }


  // Buyurtmani tasdiqlashdan oldin saqlash funksiyasi
  void _saveOrder(BuildContext context) async {
    int? userId = await _getUserId(); // SharedPreferences'dan user_id ni olish
    if (userId == null) {
      _showSnackbar(context, 'User ID topilmadi, iltimos, qayta kiriting.');
      return;
    }

    // Naqd va O'tkazma qiymatlari bo'sh bo'lsa, ularni 0 qilib yuborish
    double naqdSumma = double.tryParse(_naqdController.text.replaceAll(',', '')) ?? 0.0;
    double otkazmaSumma = double.tryParse(_otkazmaController.text.replaceAll(',', '')) ?? 0.0;
    double skidkaSumma = double.tryParse(_skidkaSummaController.text.replaceAll(',', '')) ?? 0.0;

    var orderData = {
      "mijoz": [
        {
          "mijoz_ismi": _customerNameController.text,
          "mijoz_telefon": _phoneNumberController.text,
          "mijoz_adres": _addressController.text,
        }
      ],
      "zakaz": [
        {
          "user_id": userId, // user_id ni SharedPreferences dan olish
          "jami_summa": widget.totalSum,
          "skidka_summa": skidkaSumma,
          "qoldiq_summa": double.parse(_qoldiqSummaController.text.replaceAll(',', '')), // Vergullarni olib tashlab, double qilib o'zgartirish
          "zakaz_haqida": _izohController.text,
          "zakaz_status": 1, // Zakaz statusini o'zgartiring
        }
      ],
      "zakaz_turi": widget.inputData, // Bu yerdagi input ma'lumotlarini oldingi sahifadan olingan ma'lumotlar
      "tolov": [
        {
          "tolov_turi": 1, // Naqd uchun 1
          "summa": naqdSumma,
        },
        {
          "tolov_turi": 2, // O'tkazma uchun 2
          "summa": otkazmaSumma,
        }
      ]
    };

    // Internet holatini tekshirish
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Internet yo'q bo'lsa, ma'lumotlarni saqlash
      await _saveOrderLocally(orderData);
      _showSnackbar(context, 'Internet yo\'q. Buyurtma vaqtincha saqlandi.');
      await _loadUnsentOrdersCount(); // Yuborilmagan buyurtmalar sonini yangilash
    } else {
      // DNS muammolarni bartaraf qilish uchun alohida internetni tekshirish
      if (await _checkInternetConnection()) {
        // Internet bo'lsa, buyurtmani serverga yuborish
        await _submitOrder(orderData, context);
      } else {
        _showSnackbar(context, 'Internet yo\'q. Buyurtma vaqtincha saqlandi.');
        await _saveOrderLocally(orderData);
        await _loadUnsentOrdersCount();
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => ZakazHomePage()),
                (Route<dynamic> route) => false,
          );
        });
      }
    }
  }

  // DNS muammolarni bartaraf qilish uchun alohida internetni tekshirish
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await http.get(Uri.parse('https://google.com'));
      if (result.statusCode == 200) {
        return true; // Internet mavjud
      }
    } catch (e) {
      print('Internetga ulanishda xatolik: $e');
    }
    return false; // Internet yo'q
  }

  // user_id ni SharedPreferences'dan olish funksiyasi
  Future<int?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id'); // user_id ni olish
  }

  // Buyurtmani mahalliy saqlash funksiyasi
  Future<void> _saveOrderLocally(Map<String, dynamic> orderData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedOrders = prefs.getStringList('pending_orders') ?? [];
    storedOrders.add(json.encode(orderData));
    await prefs.setStringList('pending_orders', storedOrders);
  }

  // Mahalliy saqlangan buyurtmalarni serverga yuborish funksiyasi
  Future<void> _sendStoredOrders(BuildContext context) async {
    // Internet holatini tekshirish
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showSnackbar(context, 'Internet yo\'q. Buyurtmalarni yuborish uchun internetga ulang.');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedOrders = prefs.getStringList('pending_orders') ?? [];

    if (storedOrders.isEmpty) {
      _showSnackbar(context, 'Saqlangan ma\'lumot mavjud emas.');
      return;
    }

    for (String order in storedOrders) {
      var orderData = json.decode(order);
      await _submitOrder(orderData, null); // Yuborish uchun context kerak emas
    }

    // Serverga muvaffaqiyatli yuborilgandan so'ng, mahalliy saqlangan buyurtmalarni tozalash
    await prefs.remove('pending_orders');
    _showSnackbar(context, 'Barcha saqlangan buyurtmalar muvaffaqiyatli yuborildi.');
    await _loadUnsentOrdersCount(); // Yuborilmagan buyurtmalar sonini yangilash
  }

  // Buyurtmani serverga yuborish funksiyasi
  Future<void> _submitOrder(Map<String, dynamic> orderData, BuildContext? context) async {
    try {
      final response = await http.post(
        Uri.parse('https://visualai.uz/api/zakaz_add.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(orderData),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          // Muvaffaqiyatli xabar
          print('Zakaz muvaffaqiyatli qo\'shildi');
          if (context != null) {
            _showSnackbar(context, 'Zakaz muvaffaqiyatli qo\'shildi');
            // Zakaz muvaffaqiyatli qo'shilgandan keyin ZakazHomePage sahifasiga yo'naltirish
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ZakazHomePage()),
                  (Route<dynamic> route) => false,
            );
          }
        } else {
          print('Xatolik yuz berdi: ${responseData['message']}');
        }
      } else {
        print('Server bilan aloqa xatoligi: ${response.statusCode}');
      }
    } catch (e) {
      print('Xatolik yuz berdi: $e');
    }
  }

  // Snackbar ko'rsatish funksiyasi
  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
