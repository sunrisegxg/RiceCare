import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ricecare/splashscreen.dart';

import 'services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
  await EasyLocalization.ensureInitialized();
  await NotificationService.init();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    // thanh trang thai
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // nen trong suot
      statusBarIconBrightness: Brightness.dark, // icon toi
    ),
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('vi'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('vi'),
      saveLocale: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RiceCare',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
    );
  }
}
