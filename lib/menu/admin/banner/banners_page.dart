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
  final int zakazSoni;

  BannerInfo(this.title, this.amount, this.color, this.zakazStatus, this.zakazSoni);
}

// Banner kartasi vidjeti
class BannerCardWidget extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final String zakazStatus;
  final int zakazSoni;
  final VoidCallback onDetailPressed;

  const BannerCardWidget({
    required this.title,
    required this.amount,
    required this.color,
    required this.zakazStatus,
    required this.zakazSoni,
    required this.onDetailPressed,
  });

  @override
  Widget build(BuildContext context) {
    double scale = MediaQuery.of(context).textScaleFactor;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      width: 200,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 18, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title ($zakazSoni)',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      amount,
                      style: TextStyle(
                        fontSize: 32 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "So'm",
                      style: TextStyle(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: onDetailPressed,
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
  final response = await http.get(Uri.parse('https://visualai.uz/apidemo/zakazsoni.php'));
  List<BannerInfo> banners = [
    BannerInfo("Tugallangan", "0", Colors.green.withOpacity(0.8), "5", 0),
    BannerInfo("Yuvishda", "0", Colors.purple.withOpacity(0.8), "1", 0),
    BannerInfo("Qadoqlashda", "0", Colors.blue.withOpacity(0.8), "2", 0),
    BannerInfo("Yuborishga tayyor", "0", Colors.deepOrange.withOpacity(0.8), "3", 0),
    BannerInfo("Yetqazib berishda", "0", Colors.orange.withOpacity(0.8), "4", 0),
  ];

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['error'] == false) {
      List<dynamic> zakazList = data['data'];

      for (var zakaz in zakazList) {
        String status = zakaz['zakaz_status'];
        String formattedAmount = formatNumber(zakaz['jami_summa']);
        int zakazSoni = int.parse(zakaz['zakaz_soni']);

        switch (status) {
          case '1':
            banners[1] = BannerInfo("Yuvishda", formattedAmount, Colors.purple.withOpacity(0.8), "1", zakazSoni);
            break;
          case '2':
            banners[2] = BannerInfo("Qadoqlashda", formattedAmount, Colors.blue.withOpacity(0.8), "2", zakazSoni);
            break;
          case '3':
            banners[3] = BannerInfo("Yuborishga tayyor", formattedAmount, Colors.deepOrange.withOpacity(0.8), "3", zakazSoni);
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
