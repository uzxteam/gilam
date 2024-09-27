import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MaxsulotTuriPage extends StatefulWidget {
  @override
  _MaxsulotTuriPageState createState() => _MaxsulotTuriPageState();
}

class _MaxsulotTuriPageState extends State<MaxsulotTuriPage> {
  List<Map<String, dynamic>> maxsulotlar = []; // Maxsulotlar ro'yxati
  TextEditingController _maxsulotTuriController = TextEditingController(); // Yangi maxsulot turi uchun controller

  @override
  void initState() {
    super.initState();
    _fetchMaxsulotlar(); // Sahifa yuklanganda maxsulotlarni yuklash
  }

  // API orqali maxsulotlar ro'yxatini yuklash
  Future<void> _fetchMaxsulotlar() async {
    final url = 'https://visualai.uz/api/maxsulot.php';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            maxsulotlar = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Yangi maxsulot turini qo'shish uchun API ga so'rov yuborish
  Future<void> _addMaxsulotTuri() async {
    final url = 'https://visualai.uz/api/maxsulot_turiadd.php';
    final newMaxsulotTuri = {
      'maxsulot_turi': _maxsulotTuriController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newMaxsulotTuri),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          Navigator.of(context).pop(); // Dialogni yopish
          _fetchMaxsulotlar(); // Yangi ma'lumotlarni yuklash
          _maxsulotTuriController.clear(); // Input maydonini tozalash
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Yangi maxsulot turini qo'shish uchun dialogni ko'rsatish
  void _showAddMaxsulotDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yangi Maxsulot Turi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _maxsulotTuriController,
                  decoration: InputDecoration(
                    labelText: 'Maxsulot turi kiriting',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: 'Masalan: Elektronika',
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Dialogni yopish
                      },
                      child: Text(
                        'Bekor qilish',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _addMaxsulotTuri, // Yangi maxsulot turini qo'shish
                      child: Text(
                        'Saqlash',
                        style: TextStyle(color: Colors.white), // Matnni oq rangda ko'rsatish
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maxsulot Turlari'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Orqaga qaytish ikonkasi oq rangda
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        iconTheme: IconThemeData(color: Colors.white), // Barcha ikonkalarni oq rangda ko'rsatish
        titleTextStyle: TextStyle(
          color: Colors.white, // AppBar yozuvlarini oq rangda ko'rsatish
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: maxsulotlar.isEmpty
          ? Center(child: CircularProgressIndicator()) // Ma'lumot yuklanayotgan bo'lsa
          : ListView.builder(
        itemCount: maxsulotlar.length,
        itemBuilder: (context, index) {
          final maxsulot = maxsulotlar[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text(
                  maxsulot['maxsulot_turi'][0].toUpperCase(),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                maxsulot['maxsulot_turi'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMaxsulotDialog, // Yangi maxsulot turini qo'shish
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, color: Colors.white), // + icon oq rangda
      ),
    );
  }
}
