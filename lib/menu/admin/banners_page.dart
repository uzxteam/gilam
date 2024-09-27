import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Formatlash uchun kerak

// Kartalar uchun ma'lumotlar ro'yxati
class BannerInfo {
  final String title;
  final String amount;
  final Color color;
  final String zakazStatus;
  final int zakazSoni; // Zakaz soni qo'shildi

  BannerInfo(this.title, this.amount, this.color, this.zakazStatus, this.zakazSoni);
}

// Banner kartasi vidjeti
class BannerCardWidget extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final String zakazStatus; // Zakaz statusi qo'shildi
  final int zakazSoni; // Zakaz soni qo'shildi
  final VoidCallback onDetailPressed; // Batafsil tugmasi bosilganda chaqiriladigan funksiya

  const BannerCardWidget({
    required this.title,
    required this.amount,
    required this.color,
    required this.zakazStatus,
    required this.zakazSoni, // Zakaz soni qo'shildi
    required this.onDetailPressed, // Batafsil tugmasi uchun funksiya qo'shildi
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15), // Banner orasidagi va pastki bo'shliq
      width: 200, // Banner kengligi qisqartirildi
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40), // Kartalarni yumaloq qilish
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5), // Kartaning o'z rangiga mos soyani qo'shish
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 18, bottom: 8), // Chapdan 10 px, yuqori va pastdan 8 px bo'shliq
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner nomi va zakaz soni birga ko'rsatiladi
                Align(
                  alignment: Alignment.centerLeft, // Nomlarni biroz o'ngroqqa surish uchun
                  child: Text(
                    '$title ($zakazSoni)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft, // Raqamlarni ham biroz o'ngroqqa surish uchun
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Faqat matn uchun yetarli bo'lgan joyni oladi
                    children: [
                      Text(
                        amount,
                        style: TextStyle(
                          fontSize: 32, // Raqamlar uchun shrift kattaligi
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 5), // Raqam va "So'm" orasida biroz bo'shliq qo'shish uchun
                      Text(
                        "So'm",
                        style: TextStyle(
                          fontSize: 20, // "So'm" uchun shrift kattaligi
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: onDetailPressed, // Batafsil tugmasi bosilganda funksiya chaqiriladi
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Batafsil',
                style: TextStyle(color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// API ma'lumotlarini olish va bannerlarni yangilash uchun funksiya
Future<List<BannerInfo>> fetchBannerData() async {
  final response = await http.get(Uri.parse('https://visualai.uz/api/zakazsoni.php'));
  List<BannerInfo> banners = [
    BannerInfo("Tugallangan", "0", Colors.green.withOpacity(0.8), "5", 0),
    BannerInfo("Yuvishda", "0", Colors.purple.withOpacity(0.8), "1", 0),
    BannerInfo("Qadoqlashda", "0", Colors.blue.withOpacity(0.8), "2", 0),
    BannerInfo("Yuborishga tayyor", "0", Colors.yellow.withOpacity(0.8), "3", 0),
    BannerInfo("Yetqazib berishda", "0", Colors.orange.withOpacity(0.8), "4", 0),
  ];

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['error'] == false) {
      List<dynamic> zakazList = data['data'];

      for (var zakaz in zakazList) {
        String status = zakaz['zakaz_status'];
        String formattedAmount = formatNumber(zakaz['jami_summa']); // Raqamni formatlash
        int zakazSoni = int.parse(zakaz['zakaz_soni']);

        switch (status) {
          case '1':
            banners[1] = BannerInfo("Yuvishda", formattedAmount, Colors.purple.withOpacity(0.8), "1", zakazSoni);
            break;
          case '2':
            banners[2] = BannerInfo("Qadoqlashda", formattedAmount, Colors.blue.withOpacity(0.8), "2", zakazSoni);
            break;
          case '3':
            banners[3] = BannerInfo("Yuborishga tayyor", formattedAmount, Colors.blueGrey.withOpacity(0.8), "3", zakazSoni);
            break;
          case '4':
            banners[4] = BannerInfo("Yetqazib berishda", formattedAmount, Colors.orange.withOpacity(0.8), "4", zakazSoni);
            break;
          case '5':
            banners[0] = BannerInfo("Tugallangan", formattedAmount, Colors.green.withOpacity(0.8), "5", zakazSoni);
            break;
        }
      }
    }
  }
  return banners;
}

// Raqamni formatlash uchun funksiya
String formatNumber(String number) {
  final formatter = NumberFormat("#,###", "en_US");
  return formatter.format(int.parse(number));
}
