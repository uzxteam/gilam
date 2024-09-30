import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'zakaz_home.dart'; // ZakazHomePage import qilish kerak

class ZakazUpdatePage extends StatefulWidget {
  @override
  _ZakazUpdatePageState createState() => _ZakazUpdatePageState();
}

class _ZakazUpdatePageState extends State<ZakazUpdatePage> {
  int unsentOrdersCount = 0; // Yuborilmagan buyurtmalar soni
  bool isSending = false; // Yuborish jarayonida ekanligini belgilash

  @override
  void initState() {
    super.initState();
    _loadUnsentOrdersCount(); // Yuborilmagan buyurtmalar sonini yuklash
  }

  // Yuborilmagan buyurtmalar sonini yuklash funksiyasi
  Future<void> _loadUnsentOrdersCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedOrders = prefs.getStringList('pending_orders') ?? [];
    setState(() {
      unsentOrdersCount = storedOrders.length; // Yuborilmagan buyurtmalar sonini o'rnatish
    });
  }

  // Mahalliy saqlangan buyurtmalarni ketma-ket serverga yuborish funksiyasi
  Future<void> _sendStoredOrders() async {
    setState(() {
      isSending = true; // Yuborish jarayonini boshlash
    });

    // Internet holatini tekshirish
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showSnackbar(context, 'Internet yo\'q. Buyurtmalarni yuborish uchun internetga ulang.');
      setState(() {
        isSending = false; // Yuborish jarayonini tugatish
      });
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedOrders = prefs.getStringList('pending_orders') ?? [];

    if (storedOrders.isEmpty) {
      _showSnackbar(context, 'Saqlangan ma\'lumot mavjud emas.');
      setState(() {
        isSending = false; // Yuborish jarayonini tugatish
      });
      return;
    }

    // Barcha buyurtmalarni ketma-ket yuborish
    for (int i = 0; i < storedOrders.length; i++) {
      var orderData = json.decode(storedOrders[i]);

      bool isSuccess = await _submitOrder(orderData);
      if (!isSuccess) {
        _showSnackbar(context, 'Buyurtma yuborishda xatolik. Qayta urining.');
        setState(() {
          isSending = false; // Yuborish jarayonini tugatish
        });
        return;
      }
    }

    // Serverga barcha buyurtmalar muvaffaqiyatli yuborilgandan so'ng, mahalliy saqlangan buyurtmalarni tozalash
    await prefs.remove('pending_orders');
    _showSnackbar(context, 'Barcha saqlangan buyurtmalar muvaffaqiyatli yuborildi.');
    await _loadUnsentOrdersCount(); // Yuborilmagan buyurtmalar sonini yangilash

    // ZakazHomePage sahifasiga qaytish
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => ZakazHomePage()),
          (Route<dynamic> route) => false,
    );
  }

  // Buyurtmani serverga yuborish funksiyasi
  Future<bool> _submitOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        Uri.parse('https://visualai.uz/apidemo/zakaz_add.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(orderData),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          print('Zakaz muvaffaqiyatli qo\'shildi');
          return true; // Muvaffaqiyatli yuborildi
        } else {
          print('Xatolik yuz berdi: ${responseData['message']}');
          return false; // Yuborishda xatolik
        }
      } else {
        print('Server bilan aloqa xatoligi: ${response.statusCode}');
        return false; // Yuborishda xatolik
      }
    } catch (e) {
      print('Xatolik yuz berdi: $e');
      return false; // Yuborishda xatolik
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Yuborilmagan buyurtmalar sonini ko'rsatish
            Text(
              'Yuborilmagan buyurtmalar: $unsentOrdersCount',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: unsentOrdersCount > 0 && !isSending ? _sendStoredOrders : null, // Faqat yuborilmagan buyurtmalar bo'lsa va yuborish jarayoni davom etmasa tugma faollashadi
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                backgroundColor: unsentOrdersCount > 0 && !isSending ? Colors.green : Colors.grey, // Tugma rangi
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Tugma burchaklari
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.send, color: Colors.white), // Yuborish ikonkasi
                  SizedBox(width: 8),
                  Text(
                    isSending ? "Yuborilmoqda..." : "Buyurtmalarni yuborish", // Yuborish jarayonida holatni ko'rsatish
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
