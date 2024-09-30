import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gilam/menu/zakaz/zakaz_home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LidAddPage extends StatefulWidget {
  @override
  _LidAddPageState createState() => _LidAddPageState();
}

class _LidAddPageState extends State<LidAddPage> {
  List<Map<String, dynamic>> cartData = [];

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
      cartData = savedData.map((e) => Map<String, dynamic>.from(json.decode(e))).toList();
    }
    setState(() {});
  }

  Future<void> _fetchDataFromApi() async {
    final response = await http.get(Uri.parse('https://visualai.uz/apidemo/lidlar.php'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      cartData = data.map((item) => Map<String, dynamic>.from(item)).toList();
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
    Map<String, dynamic> newItem = {
      'lid_name': name,
      'lid_phone': phone,
      'lid_adres': address,
      'lid_izoh': note,
    };

    await _sendDataToApi(newItem);
    setState(() {
      cartData.add(newItem);
      _saveCartData();
    });
  }

  Future<void> _sendDataToApi(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('https://visualai.uz/apidemo/lid_add.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Malumotni yuborishda xatolik yuz berdi!')));
    }
  }

  void _deleteCartItem(int index) async {
    final id = cartData[index]['id'];
    final response = await http.get(Uri.parse('https://visualai.uz/apidemo/deletelid.php?id=$id'));

    if (response.statusCode == 200) {
      setState(() {
        cartData.removeAt(index);
        _saveCartData();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('O\'chirishda xatolik yuz berdi!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lid Add Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ZakazHomePage()));
            },
          ),
        ],
      ),
      body: cartData.isEmpty
          ? Center(child: Text('Cartda ma\'lumotlar mavjud emas.'))
          : ListView.builder(
        itemCount: cartData.length,
        itemBuilder: (context, index) {
          final item = cartData[index];
          return Dismissible(
            key: Key(item['lid_phone']),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _deleteCartItem(index);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              elevation: 5,
              margin: EdgeInsets.all(8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(item['lid_name'][0].toUpperCase(),
                      style: TextStyle(color: Colors.white)),
                ),
                title: Text(item['lid_name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Telefon: ${item['lid_phone']}'),
                    Text('Manzil: ${item['lid_adres']}'),
                    Text('Izoh: ${item['lid_izoh']}'),
                  ],
                ),
                trailing: Wrap(
                  spacing: 12, // space between two icons
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.call),
                      onPressed: () {
                        _callPhoneNumber(item['lid_phone']);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ZakazHomePage()));
                },
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
                  Navigator.of(context). pop();
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
}
