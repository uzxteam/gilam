import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MaxsulotTuriPage extends StatefulWidget {
  @override
  _MaxsulotTuriPageState createState() => _MaxsulotTuriPageState();
}

class _MaxsulotTuriPageState extends State<MaxsulotTuriPage> {
  List<Map<String, dynamic>> maxsulotlar = [];
  TextEditingController _maxsulotTuriController = TextEditingController();
  String? selectedMaxsulotHolati; // Maxsulot holati uchun tanlov (Kvadrat/Soni)

  // Maxsulot holatlari: Kvadrat (1) va Soni (2)
  final List<Map<String, String>> maxsulotHolatiOptions = [
    {'id': '1', 'name': 'Kvadrat'},
    {'id': '2', 'name': 'Soni'}
  ];

  @override
  void initState() {
    super.initState();
    _fetchMaxsulotlar();
  }

  Future<void> _fetchMaxsulotlar() async {
    final url = 'https://visualai.uz/apidemo/maxsulot.php';
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

  Future<void> _addMaxsulotTuri() async {
    final url = 'https://visualai.uz/apidemo/maxsulot_turiadd.php';
    final newMaxsulotTuri = {
      'maxsulot_turi': _maxsulotTuriController.text,
      'maxsulot_holati': selectedMaxsulotHolati, // Maxsulot holatini yuborish
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
          Navigator.of(context).pop();
          _fetchMaxsulotlar();
          _maxsulotTuriController.clear();
          selectedMaxsulotHolati = null; // Dropdownni tozalash
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Maxsulot turini o'chirish
  Future<void> _deleteMaxsulotTuri(String id) async {
    final url = 'https://visualai.uz/apidemo/maxsulot_turi_delete.php?id=$id';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _fetchMaxsulotlar(); // Ma'lumotlarni yangilab olish
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showAddMaxsulotDialog({bool isEdit = false, Map<String, dynamic>? maxsulot}) {
    if (isEdit && maxsulot != null) {
      _maxsulotTuriController.text = maxsulot['maxsulot_turi'];
      selectedMaxsulotHolati = maxsulot['maxsulot_holati'].toString(); // Holatini olish
    } else {
      _maxsulotTuriController.clear();
      selectedMaxsulotHolati = null;
    }

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
                  isEdit ? 'Maxsulot Turini Tahrirlash' : 'Yangi Maxsulot Turi',
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
                SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Maxsulot holati tanlang',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: selectedMaxsulotHolati,
                  items: maxsulotHolatiOptions.map<DropdownMenuItem<String>>((option) {
                    return DropdownMenuItem<String>(
                      value: option['id'],
                      child: Text(option['name']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMaxsulotHolati = value; // Holatni saqlash
                    });
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Bekor qilish',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _addMaxsulotTuri,
                      child: Text(
                        'Saqlash',
                        style: TextStyle(color: Colors.white),
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
      ),
      body: maxsulotlar.isEmpty
          ? Center(child: CircularProgressIndicator())
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
              subtitle: Text('Holati: ${maxsulotHolatiOptions.firstWhere((option) => option['id'] == maxsulot['maxsulot_holati'].toString())['name']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () {
                      _showAddMaxsulotDialog(isEdit: true, maxsulot: maxsulot);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final bool? result = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Tasdiqlash'),
                            content: Text('Siz bu mahsulot turini o\'chirishni xohlaysizmi?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('Yo\'q'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text('Ha'),
                              ),
                            ],
                          );
                        },
                      );
                      if (result == true) {
                        await _deleteMaxsulotTuri(maxsulot['id'].toString());
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMaxsulotDialog,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
