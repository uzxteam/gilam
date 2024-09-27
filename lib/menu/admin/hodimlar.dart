import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HodimlarPage extends StatefulWidget {
  @override
  _HodimlarPageState createState() => _HodimlarPageState();
}

class _HodimlarPageState extends State<HodimlarPage> {
  List<dynamic> employees = [];
  String? _selectedStatus; // Tanlangan status uchun o'zgaruvchi

  @override
  void initState() {
    super.initState();
    _loadStoredEmployees(); // Avvalgi ma'lumotlarni yuklash
    _fetchEmployees(); // Hodimlar ma'lumotlarini API orqali yuklash
  }

  // Avvalgi saqlangan hodimlar ma'lumotlarini SharedPreferences dan yuklash
  Future<void> _loadStoredEmployees() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('employees_data');
    if (storedData != null) {
      setState(() {
        employees = json.decode(storedData);
      });
    }
  }

  // API orqali hodimlar ro'yxatini yuklash va SharedPreferences ga saqlash
  Future<void> _fetchEmployees() async {
    final url = 'https://visualai.uz/api/hodimlar.php';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          setState(() {
            employees = data['data'];
          });
          // Ma'lumotlarni SharedPreferences ga saqlash
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('employees_data', json.encode(data['data']));
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Foydalanuvchi statusini aniqlash
  String _getUserRole(String status) {
    switch (status) {
      case '1':
        return 'Zakazchi';
      case '2':
        return 'Yuvuvchi';
      case '3':
        return 'Qadoqlovchi';
      case '4':
        return 'Yetkazib beruvchi';
      case '5':
        return 'Zakazchi + Yetkazib beruvchi';
      case '6':
        return 'Yuvuvchi + Qadoqlovchi';
      default:
        return 'Noma\'lum';
    }
  }

  // Foydalanuvchi qo'shish uchun dialogni ko'rsatish
  Future<void> _showAddEmployeeDialog() async {
    String userName = '';
    String userUsername = '';
    String userPassword = '';
    String? selectedStatus;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Dialog oynasining burchaklarini yumaloqlash
          ),
          title: Center(
            child: Text(
              'Hodim qo\'shish',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueAccent, // Matnning rangi
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Hodim ismi',
                    labelStyle: TextStyle(color: Colors.blueAccent), // Label rangi
                    filled: true,
                    fillColor: Colors.grey[200], // Input maydonning orqa fon rangi
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10), // Input ichidagi bo'sh joylar
                  ),
                  onChanged: (value) {
                    userName = value;
                  },
                ),
                SizedBox(height: 15), // Input maydonlar orasidagi bo'sh joy
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.blueAccent), // Label rangi
                    filled: true,
                    fillColor: Colors.grey[200], // Input maydonning orqa fon rangi
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10), // Input ichidagi bo'sh joylar
                  ),
                  onChanged: (value) {
                    userUsername = value;
                  },
                ),
                SizedBox(height: 15), // Input maydonlar orasidagi bo'sh joy
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Parol',
                    labelStyle: TextStyle(color: Colors.blueAccent), // Label rangi
                    filled: true,
                    fillColor: Colors.grey[200], // Input maydonning orqa fon rangi
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10), // Input ichidagi bo'sh joylar
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    userPassword = value;
                  },
                ),
                SizedBox(height: 15), // Input maydonlar orasidagi bo'sh joy
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Status tanlang',
                    labelStyle: TextStyle(color: Colors.blueAccent), // Label rangi
                    filled: true,
                    fillColor: Colors.grey[200], // Input maydonning orqa fon rangi
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10), // Input ichidagi bo'sh joylar
                  ),
                  items: [
                    DropdownMenuItem(
                      value: '1',
                      child: Text('Zakazchi'),
                    ),
                    DropdownMenuItem(
                      value: '2',
                      child: Text('Yuvuvchi'),
                    ),
                    DropdownMenuItem(
                      value: '3',
                      child: Text('Qadoqlovchi'),
                    ),
                    DropdownMenuItem(
                      value: '4',
                      child: Text('Yetkazib beruvchi'),
                    ),
                    DropdownMenuItem(
                      value: '5',
                      child: Text('Zakazchi + Yetqazib berish'),
                    ),
                    DropdownMenuItem(
                      value: '6',
                      child: Text('Yuvuvchi  + Qadoqlovchi'),
                    ),
                  ],
                  onChanged: (value) {
                    selectedStatus = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Bekor qilish',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), // Tugma matnining rangi va stili
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dialogni yopish
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Tugma rangi
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Tugma burchaklari
                ),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12), // Tugma ichidagi bo'sh joy
              ),
              child: Text(
                'Saqlash',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), // Tugma matni stili
              ),
              onPressed: () async {
                if (userName.isNotEmpty &&
                    userUsername.isNotEmpty &&
                    userPassword.isNotEmpty &&
                    selectedStatus != null) {
                  // Yangi hodim qo'shish uchun API ga so'rov yuborish
                  final response = await http.post(
                    Uri.parse('https://visualai.uz/api/hodimadd.php'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'user_name': userName,
                      'user_username': userUsername,
                      'user_password': userPassword,
                      'user_status': selectedStatus,
                    }),
                  );
                  if (response.statusCode == 200) {
                    Navigator.of(context).pop(); // Dialogni yopish
                    _fetchEmployees(); // Hodimlar ro'yxatini yangilash
                  }
                } else {
                  // Xatolik yuz berganini bildirish
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Iltimos, barcha maydonlarni to\'ldiring!'),
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
        title: Align(
          alignment: Alignment.centerLeft, // Yozuvni chap tomonga joylashtirish
          child: Text(
            'Hodimlar',
            style: TextStyle(
              color: Colors.black, // Yozuv qora rangda
            ),
          ),
        ),
        backgroundColor: Colors.white, // AppBar rangini oq qilish
        iconTheme: IconThemeData(
          color: Colors.black, // Orqaga qaytish iconini qora rangda qilish
        ),
      ),
      body: employees.isEmpty
          ? Center(child: CircularProgressIndicator()) // Ma'lumotlar yuklanayotganda
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: employees.length,
          itemBuilder: (context, index) {
            final employee = employees[index];
            return _buildEmployeeCard(employee);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEmployeeDialog, // + iconiga bosilganda hodim qo'shish dialogini ochish
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Har bir hodim uchun karta yaratish
  Widget _buildEmployeeCard(Map<String, dynamic> employee) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.person,
              size: 50,
              color: Colors.blueAccent,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee['user_name'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _getUserRole(employee['user_status']),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
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
