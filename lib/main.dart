import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gilam/splash/splash.dart'; // easy_localization import qilish

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('uz', 'UZ')],
      path: 'assets/translations',
      fallbackLocale: Locale('en', 'US'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gilam Yuvish',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      locale: context.locale, // Hozirgi til
      supportedLocales: context.supportedLocales, // Qo'llab-quvvatlanadigan tillar
      localizationsDelegates: context.localizationDelegates, // Delegatlar
      home: SplashScreen(),
    );
  }
}
