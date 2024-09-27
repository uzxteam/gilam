import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LidAddPage extends StatefulWidget {
  @override
  _LidAddPageState createState() => _LidAddPageState();
}

class _LidAddPageState extends State<LidAddPage> {
  List<Map<String, String>> cartData = [];

  @override
  void initState() {
    super.initState();
    _loadCartData();
    _fetchDataFromApi();
  }

  Future<void> _loadCartData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedData = prefs.getStringList('cartData');
    if (savedData != null) {
      cartData = savedData.map((e) => Map<String, String>.from(json.decode(e))).toList();
    }
    setState(() {});
  }

  Future<void> _fetchDataFromApi() async {
    final response = await http.get(Uri.parse('https://visualai.uz/api/lidlar.php'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      cartData = data.map((item) => Map<String, String>.from(item)).toList();
      await _saveCartData();
      setState(() {});
    }
  }

  Future<void> _saveCartData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> saveData = cartData.map((e) => json.encode(e)).toList();
    await prefs.setStringList('cartData', saveData);
  }

  void _addCartItem(String name, String phone, String address, String note) async {
    Map<String, String> newItem = {
      'lid_name': name,
      'lid_phone': phone,
      'lid_adres': address,
      'lid_izoh': note,
    };

    // Malumotni serverga yuborish
    await _sendDataToApi(newItem);

    // Mahalliy listga qo'shish va saqlash
    setState(() {
      cartData.add(newItem);
      _saveCartData();
    });
  }

  Future<void> _sendDataToApi(Map<String, String> data) async {
    final response = await http.post(
      Uri.parse('https://visualai.uz/api/lid_add.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      // Xatolik bo'lsa, userga xabar berish
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Malumotni yuborishda xatolik yuz berdi!')));
    }
  }

  void _showAddDialog() {
    String name = '';
    String phone = '';
    String address = '';
    String note = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ma\'lumot qo\'shish'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Mijoz Ismi',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Telefon',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    phone = value;
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Manzil',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    address = value;
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Izoh',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    note = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Bekor qilish'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Saqlash'),
              onPressed: () {
                if (name.isNotEmpty && phone.isNotEmpty && address.isNotEmpty && note.isNotEmpty) {
                  _addCartItem(name, phone, address, note);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _callPhoneNumber(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _deleteCartItem(int index) {
    setState(() {
      cartData.removeAt(index);
      _saveCartData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lid Add Page'),
      ),
      body: cartData.isEmpty
          ? Center(child: Text('Cartda ma\'lumotlar mavjud emas.'))
          : ListView.builder(
        itemCount: cartData.length,
        itemBuilder: (context, index) {
          final item = cartData[index];
          return Dismissible(
            key: Key(item['lid_phone']!),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            onDismissed: (direction) {
              _deleteCartItem(index);
            },
            child: Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(item['lid_name']!),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Telefon: ${item['lid_phone']}'),
                    Text('Manzil: ${item['lid_adres']}'),
                    Visibility(
                      visible: true,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('Izoh: ${item['lid_izoh']}'),
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    _callPhoneNumber(item['lid_phone']!);
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
