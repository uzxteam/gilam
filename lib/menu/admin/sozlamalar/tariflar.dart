import 'package:flutter/material.dart';
import 'package:gilam/format.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class TariflarPage extends StatefulWidget {
  @override
  _TariflarPageState createState() => _TariflarPageState();
}

class _TariflarPageState extends State<TariflarPage> {
  List<Map<String, dynamic>> tariflar = []; // Tariflar ro'yxati
  TextEditingController _tarifNomiController = TextEditingController(); // Tarif nomi uchun controller
  TextEditingController _tarifSummaController = TextEditingController(); // Tarif summa uchun controller
  String? editingTarifId; // Tahrirlanayotgan tarif ID si
  String _formatSum(dynamic sum) {
    final formatter = NumberFormat('#,###');
    int actualSum;
    if (sum is String) {
      actualSum = int.parse(sum);
    } else {
      actualSum = sum;
    }
    return formatter.format(actualSum);
  }


  @override
  void initState() {
    super.initState();
    _fetchTariflar(); // Sahifa yuklanganda tariflarni yuklash
  }

  // API orqali tariflar ro'yxatini yuklash
  Future<void> _fetchTariflar() async {
    final url = 'https://visualai.uz/api/tariflar.php';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            tariflar = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Yangi tarif qo'shish uchun API ga so'rov yuborish
  Future<void> _addTarif() async {
    final url = 'https://visualai.uz/api/tarifadd.php';
    final newTarif = {
      'tarif_nomi': _tarifNomiController.text,
      'tarif_summa': int.parse(_tarifSummaController.text),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newTarif),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          Navigator.of(context).pop(); // Dialogni yopish
          _fetchTariflar(); // Yangi ma'lumotlarni yuklash
          _tarifNomiController.clear(); // Input maydonini tozalash
          _tarifSummaController.clear(); // Summa inputini tozalash
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Tahrirlangan tarifni yangilash uchun API ga so'rov yuborish
  Future<void> _updateTarif(String id) async {
    final url = 'https://visualai.uz/api/tarifadd.php';
    final updatedTarif = {
      'id': id, // Tahrirlanayotgan tarif ID si
      'tarif_nomi': _tarifNomiController.text,
      'tarif_summa': int.parse(_tarifSummaController.text),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedTarif),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          Navigator.of(context).pop(); // Dialogni yopish
          _fetchTariflar(); // Yangi ma'lumotlarni yuklash
          _tarifNomiController.clear(); // Input maydonini tozalash
          _tarifSummaController.clear(); // Summa inputini tozalash
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteTarif(String id) async {
    final url = 'https://visualai.uz/api/tarif_delete.php?id=$id';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _fetchTariflar();
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Yangi yoki tahrirlangan tarif qo'shish uchun dialogni ko'rsatish
  void _showAddOrEditTarifDialog({bool isEdit = false, Map<String, dynamic>? tarif}) {
    if (isEdit && tarif != null) {
      _tarifNomiController.text = tarif['tarif_nomi'];
      _tarifSummaController.text = _formatSum(tarif['tarif_summa']);
      editingTarifId = tarif['id'];
    } else {
      _tarifNomiController.clear();
      _tarifSummaController.clear();
      editingTarifId = null;
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
                  isEdit ? 'Tarifni Tahrirlash' : 'Yangi Tarif Qo\'shish',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _tarifNomiController,
                  decoration: InputDecoration(
                    labelText: 'Tarif nomini kiriting',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: 'Masalan: Oylik tarif',
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _tarifSummaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [NumberInputFormatter()],
                  decoration: InputDecoration(
                    labelText: 'Summa kiriting',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: 'Masalan: 10,000',
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
                      onPressed: () {
                        if (isEdit && editingTarifId != null) {
                          _updateTarif(editingTarifId!); // Tahrirlangan tarifni yangilash
                        } else {
                          _addTarif(); // Yangi tarif qo'shish
                        }
                      },
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
        title: Text('Tariflar'),
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
      body: tariflar.isEmpty
          ? Center(child: CircularProgressIndicator()) // Ma'lumot yuklanayotgan bo'lsa
          : ListView.builder(
        itemCount: tariflar.length,
        itemBuilder: (context, index) {
          final tarif = tariflar[index];
          return Dismissible(
            key: ValueKey(tarif['id']),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              color: Colors.blueAccent,
              child: Icon(Icons.edit, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              _showAddOrEditTarifDialog(isEdit: true, tarif: tarif);
              return false; // O'chirish emas, faqat dialogni ochish
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                title: Text(
                  tarif['tarif_nomi'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Summa: ${_formatSum(tarif['tarif_summa'])}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final bool? result = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Tasdiqlash'),
                          content: Text('Siz bu tarifni o\'chirishni xohlaysizmi?'),
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
                      await _deleteTarif(tarif['id']);
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditTarifDialog(), // Yangi tarif qo'shish
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, color: Colors.white), // + icon oq rangda
      ),
    );
  }
}
