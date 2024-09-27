import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gilam/menu/dastavka/dastvakalogin.dart';
import 'package:gilam/menu/zakaz/zakazadd.dart';
import 'package:gilam/menu/zakaz/zakazupdate.dart';
import 'package:gilam/splash/splash.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ZakazHomePage extends StatefulWidget {
  @override
  _ZakazHomePageState createState() => _ZakazHomePageState();
}

class _ZakazHomePageState extends State<ZakazHomePage> {
  final List<Widget> _inputFields = []; // Inputlar listi
  List<Map<String, dynamic>> tariflar = []; // Tariflar ro'yxati (id, tarif_nomi, tarif_summa)
  List<Map<String, dynamic>> maxsulotlar = []; // Maxsulotlar ro'yxati (id, maxsulot_turi)
  List<String?> selectedTarifs = []; // Har bir input uchun tanlangan tariflar
  List<String?> selectedMaxsulots = []; // Har bir input uchun tanlangan mahsulotlar
  List<double> selectedTarifSummas = []; // Har bir input uchun tarif summasi
  List<TextEditingController> m2Controllers = []; // Har bir input uchun M2 controlleri
  List<TextEditingController> summaControllers = []; // Har bir input uchun summa controlleri
  List<TextEditingController> soniControllers = []; // Har bir input uchun Soni controlleri
  String userName = ''; // Foydalanuvchi ismi
  List<String?> selectedTarifIds = []; // Har bir input uchun tanlangan tarif ID ro'yxati
  bool isLoading = false; // Ekranda loading holati
  bool isAddingInput = false; // Maxsulot qo'shish tugmasi bosa olishini cheklash
  int unsentOrdersCount = 0; // Yuborilmagan buyurtmalar soni
  bool isConnected = false; // Internet holatini tekshirish

  @override
  void initState() {
    super.initState();
    _loadStoredTariflar(); // Avval saqlangan tariflarni yuklash
    _loadStoredMaxsulotlar(); // Avval saqlangan maxsulotlarni yuklash
    _fetchTariflar(); // API orqali tariflarni yuklash
    _fetchMaxsulotlar(); // API orqali maxsulotlarni yuklash
    _loadUserName(); // Foydalanuvchi ismini yuklashFjami
    _checkConnectivity(); // Internet holatini tekshirish
    _loadUnsentOrdersCount(); // Yuborilmagan buyurtmalar sonini yuklash
  }
  Future<void> _loadUnsentOrdersCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedOrders = prefs.getStringList('pending_orders') ?? [];
    setState(() {
      unsentOrdersCount = storedOrders.length; // Yuborilmagan buyurtmalar sonini o'rnatish
    });
  }

// Internet holatini tekshirish funksiyasi
  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      isConnected = connectivityResult != ConnectivityResult.none;
    });
  }
  // Avval saqlangan tariflarni yuklash
  Future<void> _loadStoredTariflar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedTariflar = prefs.getString('tariflar_data');
    if (storedTariflar != null) {
      setState(() {
        tariflar = List<Map<String, dynamic>>.from(json.decode(storedTariflar));
      });
    }
  }

  // Avval saqlangan maxsulotlarni yuklash
  Future<void> _loadStoredMaxsulotlar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedMaxsulotlar = prefs.getString('maxsulotlar_data');
    if (storedMaxsulotlar != null) {
      setState(() {
        maxsulotlar = List<Map<String, dynamic>>.from(json.decode(storedMaxsulotlar));
      });
    }
  }

  // Barcha ma'lumotlarni o'chirish va splash screen'ga qaytish funksiyasi
  void _clearAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Barcha saqlangan ma'lumotlarni o'chirish
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  }

  // API orqali tariflar ro'yxatini yuklash va SharedPreferences ga saqlash
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
          // Ma'lumotlarni SharedPreferences ga saqlash
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('tariflar_data', json.encode(data['data']));
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // API orqali maxsulotlar ro'yxatini yuklash va SharedPreferences ga saqlash
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
          // Ma'lumotlarni SharedPreferences ga saqlash
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('maxsulotlar_data', json.encode(data['data']));
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Foydalanuvchi ismini yuklash
  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'User';
    });
  }

  // Matn uzunligini cheklash uchun yordamchi funksiya
  String _shortenText(String text, int maxLength) {
    return text.length > maxLength ? '${text.substring(0, maxLength)}...' : text;
  }

  // Yangi input qatori qo'shish
  void _addInputFields() {
    if (isAddingInput) return; // Agar qo'shilish jarayoni bo'lsa, qaytish

    setState(() {
      isLoading = true; // Loading holatni yoqish
      isAddingInput = true; // Qo'shilish jarayonini boshlash
    });

    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        final m2Controller = TextEditingController(); // Har bir qator uchun yangi M2 controller
        final summaController = TextEditingController(); // Har bir qator uchun yangi Summa controller
        final soniController = TextEditingController(); // Har bir qator uchun yangi Soni controller

        m2Controllers.add(m2Controller); // Controllerlarni ro'yxatga qo'shish
        summaControllers.add(summaController);
        soniControllers.add(soniController);

        // Tanlangan tarif va summalarni ro'yxatga qo'shish
        selectedTarifs.add(tariflar.isNotEmpty ? tariflar[0]['tarif_nomi'] as String : null);
        selectedTarifIds.add(tariflar.isNotEmpty ? tariflar[0]['id'] as String : null);
        selectedMaxsulots.add(maxsulotlar.isNotEmpty ? maxsulotlar[0]['id'] as String : null);
        selectedTarifSummas.add(tariflar.isNotEmpty ? double.parse(tariflar[0]['tarif_summa']) : 0.0);

        _inputFields.add(_buildInputCard(
          m2Controller: m2Controller,
          summaController: summaController,
          soniController: soniController,
          index: _inputFields.length,
        )); // Yangi qatorni ro'yxatga qo'shish
        _calculateTotalSum(); // Jami summani hisoblash

        isLoading = false; // Loading holatni o'chirish
        isAddingInput = false; // Qo'shilish jarayonini tugatish
      });
    });
  }

  // M2 qiymati o'zgarganda chaqiriladi va summani hisoblaydi
  void _calculateSumma(int index) {
    double m2 = double.tryParse(m2Controllers[index].text) ?? 0.0;
    double summa = m2 * selectedTarifSummas[index];
    summaControllers[index].text = summa.toStringAsFixed(0); // Summa ni ko'rsatish, o'nlik qismisiz
    _calculateTotalSum(); // Jami summani qayta hisoblash
  }

  // Jami summani hisoblash
  double _calculateTotalSum() {
    double total = 0.0;
    for (var controller in summaControllers) {
      total += double.tryParse(controller.text) ?? 0.0;
    }
    return total;
  }

// Yangi input qatori yaratish
  Widget _buildInputCard({
    required TextEditingController m2Controller,
    required TextEditingController summaController,
    required TextEditingController soniController,
    required int index,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Kichik padding berish
        child: Column(
          children: [
            // Maxsulot turini tanlang dropdown
            Row(
              children: [
                Expanded(
                  flex: 5, // Dropdown uchun kenglik
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Maxsulot turini tanlang',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    value: selectedMaxsulots[index],
                    items: maxsulotlar.map((maxsulot) => DropdownMenuItem<String>(
                      value: maxsulot['id'], // Maxsulot ID sini tanlash uchun
                      child: Text(
                        _shortenText(maxsulot['maxsulot_turi'] as String, 15),
                        overflow: TextOverflow.ellipsis, // Matnni cheklash va qolgan qismini '...' bilan almashtirish
                      ),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMaxsulots[index] = value;
                      });
                    },
                  ),
                ),
                // O'chirish tugmasi
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _inputFields.removeAt(index);
                      m2Controllers.removeAt(index);
                      summaControllers.removeAt(index);
                      soniControllers.removeAt(index);
                      selectedTarifs.removeAt(index);
                      selectedTarifIds.removeAt(index);
                      selectedMaxsulots.removeAt(index);
                      selectedTarifSummas.removeAt(index);
                      _calculateTotalSum();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            // 4 ta yonma-yon input maydonlari
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Soni input field
                Expanded(
                  flex: 2, // Kichikroq o'lchamda
                  child: TextField(
                    controller: soniController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Soni',
                      labelStyle: TextStyle(fontSize: 14), // Kichikroq matn o'lchami
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(fontSize: 14), // Kichikroq matn o'lchami
                  ),
                ),
                SizedBox(width: 5), // Kichikroq bo'shliq
                // M2 input field
                Expanded(
                  flex: 2, // Kichikroq o'lchamda
                  child: TextField(
                    controller: m2Controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'M2',
                      labelStyle: TextStyle(fontSize: 14), // Kichikroq matn o'lchami
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(fontSize: 14), // Kichikroq matn o'lchami
                    onChanged: (value) {
                      _calculateSumma(index); // M2 qiymati o'zgarganda summani hisoblash
                      setState(() {}); // Dinamik yangilash
                    },
                  ),
                ),
                SizedBox(width: 5), // Kichikroq bo'shliq
                // Tariflar dropdown field
                Expanded(
                  flex: 3, // Kattaroq o'lchamda
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Tariflar',
                      labelStyle: TextStyle(fontSize: 16),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    value: selectedTarifs[index], // Bunda qiymat tariflar ro'yxatidagi qiymat bilan mos bo'lishi kerak
                    items: tariflar.map((tarif) {
                      return DropdownMenuItem<String>(
                        value: tarif['tarif_nomi'] as String, // Bunda qiymat unique bo'lishi kerak
                        child: Text(
                          _shortenText(tarif['tarif_nomi'] as String, 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTarifs[index] = value;
                        // Bo'sh `Map<String, dynamic>` qaytaring null emas!
                        final selectedTarif = tariflar.firstWhere(
                                (tarif) => tarif['tarif_nomi'] == value,
                            orElse: () => <String, dynamic>{}); // Agar hech qanday mos keladigan element topilmasa, bo'sh map qaytaradi
                        if (selectedTarif.isNotEmpty) { // Bo'sh emasligini tekshirish
                          selectedTarifIds[index] = selectedTarif['id'];
                          selectedTarifSummas[index] = double.parse(selectedTarif['tarif_summa']);
                          _calculateSumma(index);
                          setState(() {}); // Dinamik yangilash
                        }
                      });
                    },
                  ),
                ),
                SizedBox(width: 5), // Kichikroq bo'shliq
                // Summa output field
                Expanded(
                  flex: 3, // Kattaroq o'lchamda
                  child: TextField(
                    controller: summaController,
                    readOnly: true, // Faqat o'qish uchun maydon
                    decoration: InputDecoration(
                      labelText: 'Summa',
                      labelStyle: TextStyle(fontSize: 16), // Kattaroq matn o'lchami
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(fontSize: 16), // Kattaroq matn o'lchami
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  // Keyingi sahifaga o'tish
  void _navigateToNextPage() {
    double totalSum = _calculateTotalSum();
    List<Map<String, dynamic>> inputData = [];

    for (int i = 0; i < _inputFields.length; i++) {
      inputData.add({
        'zakaz_tarif_id': selectedTarifs[i],
        'zakaz_tarif': selectedTarifIds[i],
        'zakaz_kvadrat': m2Controllers[i].text,
        'zakaz_soni': soniControllers[i].text, // Soni qiymatini qo'shish
        'zakaz_summa': summaControllers[i].text,
        'maxsulot_turi': selectedMaxsulots[i], // Tanlangan maxsulot ID sini qo'shish
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZakazAddPage(totalSum: totalSum, inputData: inputData),
      ),
    );
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Logotip va Jami summa joylashgan oddiy satr
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logotip
                      Image.asset(
                        'assets/splash.jpg',
                        width: 80, // Kottaroq logotip
                        height: 80,
                      ),
                      // Jami summa tugmasi va chiqish ikonkasi
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Jami summa tugmasi bosilganda nima bo'lishini yozing
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Tugma hajmi
                              backgroundColor: Colors.blueAccent, // Tugma rangi
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              '${_calculateTotalSum().toStringAsFixed(0)}', // Jami summani ko'rsatish
                              style: TextStyle(fontSize: 18,color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 10), // Bo'sh joy
                          Row(
                            children: [
                              if (unsentOrdersCount > 0 && isConnected) // Faqat internet bor va yuborilmagan buyurtmalar bo'lsa
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ZakazUpdatePage()), // ZakazUpdatePage sahifasiga o'tish
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.all(12), // Tugma kattaligini moslashtirish
                                    backgroundColor: Colors.orange, // Tugma rangi
                                    shape: CircleBorder(), // Doira shaklida tugma
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center, // Icon va sonni markazga joylashtirish
                                    children: [
                                      Icon(Icons.send, color: Colors.white, size: 32), // Yuborish ikonkasi
                                      if (unsentOrdersCount > 0)
                                        Positioned(
                                          right: -2, // O'ng tomonga biroz ko'chirish
                                          top: -4, // Yuqori tomonga biroz ko'chirish
                                          child: Container(
                                            padding: EdgeInsets.all(2), // Ichki qismini kichikroq qilish
                                            decoration: BoxDecoration(
                                              color: Colors.red, // Qizil rang fon
                                              borderRadius: BorderRadius.circular(10), // Doira shaklida
                                            ),
                                            constraints: BoxConstraints(
                                              minWidth: 16, // Minimal kenglikni kichikroq qilish
                                              minHeight: 16, // Minimal balandlikni kichikroq qilish
                                            ),
                                            child: Text(
                                              '$unsentOrdersCount', // Yuborilmagan buyurtmalar soni
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10, // Kichikroq shrift
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                ),
                              SizedBox(width: 10), // Kichik bo'shliq
                              IconButton(
                                icon: Icon(Icons.logout, color: Colors.red), // Chiqish ikonkasi
                                onPressed: _clearAllData, // Chiqish bosilganda barcha ma'lumotlarni o'chirish va Splash sahifaga o'tish
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Zakaz oluvchi ismi
                Text(
                  userName, // Foydalanuvchi ismi SharedPreferences dan o'qiladi
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center, // O'rtada joylashtirish
                ),

                Expanded(
                  child: ListView(
                    children: [
                      ..._inputFields, // Dastlabki input qatorlari
                      if (isLoading)
                        Center(
                          child: CircularProgressIndicator(), // Loading indikator
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // "Maxsulot qo'shish" tugmasi
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => DastavkaLoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        backgroundColor: Colors.blueAccent, // Tugma rangi
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Tugma burchaklari
                        ),
                      ),
                      child: Text(
                        "Orqaga",
                        style: TextStyle(fontSize: 16,color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isLoading ? null : _addInputFields, // Yangi input qatorlarini qo'shish
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        backgroundColor: Colors.blueAccent, // Tugma rangi
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Tugma burchaklari
                        ),
                      ),
                      child: Text(
                        "Maxsulot qo'shish",
                        style: TextStyle(fontSize: 16,color: Colors.white),
                      ),
                    ),
                    // "Keyingisi" tugmasi
                    ElevatedButton(
                      onPressed: _navigateToNextPage, // Keyingi sahifaga o'tish
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        backgroundColor: Colors.green, // Tugma rangi
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Tugma burchaklari
                        ),
                      ),
                      child: Text(
                        "Keyingisi",
                        style: TextStyle(fontSize: 16,color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
