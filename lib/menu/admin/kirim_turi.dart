import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model
class KirimTuri {
  final String id;
  final String kirimNomi;

  KirimTuri({required this.id, required this.kirimNomi});

  factory KirimTuri.fromJson(Map<String, dynamic> json) {
    return KirimTuri(
      id: json['id'],
      kirimNomi: json['kirim_nomi'],
    );
  }
}

// Ma'lumot olish funksiyasi
Future<List<KirimTuri>> fetchKirimTuri() async {
  final response =
      await http.get(Uri.parse('https://visualai.uz/api/kirim_turi.php'));

  if (response.statusCode == 200) {
    final parsedJson = jsonDecode(response.body);
    final List<dynamic> data = parsedJson['data'];
    return data.map((item) => KirimTuri.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

// Ma'lumot qo'shish funksiyasi
Future<void> addKirimTuri(String kirimNomi) async {
  final response = await http.post(
    Uri.parse('https://visualai.uz/api/kirim_turi_add.php'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'kirim_nomi': kirimNomi}),
  );

  if (response.statusCode == 200) {
    print('Ma\'lumot muvaffaqiyatli qo\'shildi');
  } else {
    throw Exception('Ma\'lumotni qo\'shishda xatolik yuz berdi');
  }
}

// Ma'lumotni o'chirish funksiyasi
Future<void> deleteKirimTuri(String id) async {
  final response = await http.post(
    Uri.parse('https://visualai.uz/api/kirim_turi_delete.php'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'kirim_id': id}),
  );

  if (response.statusCode == 200) {
    print('Ma\'lumot muvaffaqiyatli o\'chirildi');
  } else {
    throw Exception('Ma\'lumotni o\'chirishda xatolik yuz berdi');
  }
}

// UI
class KirimTuriPage extends StatefulWidget {
  @override
  _KirimTuriPageState createState() => _KirimTuriPageState();
}

class _KirimTuriPageState extends State<KirimTuriPage> {
  late Future<List<KirimTuri>> futureKirimTuri;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureKirimTuri = fetchKirimTuri();
  }

  // Ma'lumotni ro'yxatdan o'chirish funksiyasi
  void removeItem(String id) {
    setState(() {
      futureKirimTuri = futureKirimTuri
          .then((value) => value.where((item) => item.id != id).toList());
    });
  }

  // Tasdiqlash dialogi funksiyasi
  Future<void> _showDeleteDialog(
      BuildContext context, String id, String name) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'O\'chirishni tasdiqlash',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: Text(
              '$name ma\'lumotini o\'chirishni xohlaysizmi?',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Bekor qilish',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'O\'chirish',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
              onPressed: () async {
                try {
                  await deleteKirimTuri(id);
                  removeItem(id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$name muvaffaqiyatli o\'chirildi'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('O\'chirishda xatolik: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Ma'lumot qo'shish dialogini ko'rsatish funksiyasi
  Future<void> _showAddDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Kirim Turi Qo\'shish',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
                hintText: 'Kirim nomini kiriting',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue, width: 1.5),
                )),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Bekor qilish',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Qo\'shish',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () async {
                if (_controller.text.isNotEmpty) {
                  try {
                    await addKirimTuri(_controller.text);
                    Navigator.of(context).pop(); // Dialogni yopish
                    _controller.clear(); // TextField'ni tozalash
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ma\'lumot muvaffaqiyatli qo\'shildi'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                    setState(() {
                      futureKirimTuri =
                          fetchKirimTuri(); // Yangi ma'lumotlarni yangilash
                    });
                  } catch (e) {
                    Navigator.of(context).pop(); // Dialogni yopish
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ma\'lumotni qo\'shishda xatolik: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ma\'lumot kiritilmagan!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kirim Turlari'),
      ),
      body: FutureBuilder<List<KirimTuri>>(
        future: futureKirimTuri,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 150,
                  ),
                  Image.asset(
                    "assets/not_found.png",
                    height: 300,
                  ),
                  Text(
                    "Ma'lumot topilmadi",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black45,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final kirimTuri = snapshot.data![index];
                return Dismissible(
                  key: Key(kirimTuri.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    // Dialog orqali tasdiqlash
                    await _showDeleteDialog(
                        context, kirimTuri.id, kirimTuri.kirimNomi);
                    return false; // Dismissible funksiyasini avtomatik ishlatmaslik uchun
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    padding: EdgeInsets.only(left: 8),
                    child: ListTile(
                      title: Text(
                        kirimTuri.kirimNomi,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'ID: ${kirimTuri.id}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _showAddDialog,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
