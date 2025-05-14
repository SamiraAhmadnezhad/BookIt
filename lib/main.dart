import 'package:bookit/pages/authentication_page/authentication_page.dart';
import 'package:bookit/pages/hotel_detail_page/hotel_detail_page.dart';
import 'package:bookit/pages/reservation_detail_page/reservation_detail_page.dart';
import 'package:bookit/pages/hotel_info_pages/hotel_info_page.dart';
import 'package:bookit/pages/hotel_info_pages/room_info_page.dart';
import 'package:bookit/pages/hotel_info_pages/reserved_rooms_page.dart';
import 'package:bookit/pages/account_pages-guest/user_account_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const UserAccountPage(),
      theme: ThemeData(
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
    );
  }
}
