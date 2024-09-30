import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:gilam/menu/dastavka/dastavka.dart';

class DastavkaUpdatePage extends StatefulWidget {
  @override
  _DastavkaUpdatePageState createState() => _DastavkaUpdatePageState();
}

class _DastavkaUpdatePageState extends State<DastavkaUpdatePage> {
  List<dynamic> offlineZakazlar = []; // Jo'natilmagan ma'lumotlar ro'yxati
  bool isSending = false; // Ma'lumotlar yuborilayotganligini ko'rsatish uchun
  int sentCount = 0; // Yuborilgan ma'lumotlar soni

  @override
  void initState() {
    super.initState();
    _loadOfflineZakazlar(); // Saqlangan ma'lumotlarni yuklash
  }

  // Saqlangan offline ma'lumotlarni yuklash
  Future<void> _loadOfflineZakazlar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String zakazlar = prefs.getString('offline_zakazlar') ?? '[]';
    setState(() {
      offlineZakazlar = json.decode(zakazlar);
    });
  }

  // Offline ma'lumotlarni API ga yuborish funksiyasi
  Future<void> _sendOfflineZakazlar() async {
    setState(() {
      isSending = true;
      sentCount = 0;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> remainingZakazlar = [];

    for (var zakaz in offlineZakazlar) {
      // Tolovlar ichida `id` bo'lmasa, uni avtomatik tarzda qo'shamiz
      for (int i = 0; i < zakaz['tolovlar'].length; i++) {
        if (!zakaz['tolovlar'][i].containsKey('id')) {
          zakaz['tolovlar'][i]['id'] = (i + 1).toString(); // Har bir to'lov uchun `id` ni yaratamiz
        }
      }

      try {
        final response = await http.post(
          Uri.parse('https://visualai.uz/apidemo/dastavka_add.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(zakaz),
        );

        if (response.statusCode == 200) {
          setState(() {
            sentCount++;
          });
        } else {
          remainingZakazlar.add(zakaz); // Yuborilmagan ma'lumotlarni saqlab qolish
        }
      } on SocketException {
        remainingZakazlar.add(zakaz); // Internet yo'q bo'lsa, saqlab qolish
      } catch (e) {
        print('Xatolik: $e');
        remainingZakazlar.add(zakaz); // Boshqa xatoliklar bo'lsa, saqlab qolish
      }
    }

    // Yuborilmagan ma'lumotlarni qayta saqlash
    prefs.setString('offline_zakazlar', json.encode(remainingZakazlar));

    // Barcha ma'lumotlar yuborilgan bo'lsa DastavkaPage sahifasiga o'tish
    if (remainingZakazlar.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DastavkaPage()),
      );
    } else {
      setState(() {
        offlineZakazlar = remainingZakazlar;
        isSending = false;
      });
    }
  }

  // Ma'lumotni alohida o'chirish funksiyasi
  Future<void> _deleteOfflineZakaz(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      offlineZakazlar.removeAt(index); // Ma'lumotni ro'yxatdan o'chirish
    });

    // Qolgan ma'lumotlarni saqlash
    prefs.setString('offline_zakazlar', json.encode(offlineZakazlar));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yuborilmagan Ma\'lumotlar'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jo\'natilishi kerak bo\'lgan ma\'lumotlar soni: ${offlineZakazlar.length}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: offlineZakazlar.length,
                itemBuilder: (context, index) {
                  var zakaz = offlineZakazlar[index];
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Zakaz ID: ${zakaz['zakaz_id']}',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8),
                                    Text('User ID: ${zakaz['user_id']}'),
                                    SizedBox(height: 8),
                                    Text('Jami summa: ${zakaz['jami_summa']} so\'m'),
                                    SizedBox(height: 8),
                                    Text('Skidka summa: ${zakaz['skidka_summa']} so\'m'),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  bool confirmDelete = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Tasdiqlash'),
                                        content: Text('Haqiqatdan ham ushbu ma\'lumotni o\'chirmoqchimisiz?'),
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

                                  if (confirmDelete == true) {
                                    _deleteOfflineZakaz(index); // Ma'lumotni o'chirish
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: isSending ? null : _sendOfflineZakazlar,
                icon: Icon(Icons.send, color: Colors.white),
                label: Text(
                  isSending ? 'Yuborilmoqda...' : 'Yuborish',
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
            if (isSending)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text(
                        'Yuborilgan ma\'lumotlar: $sentCount / ${offlineZakazlar.length}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
