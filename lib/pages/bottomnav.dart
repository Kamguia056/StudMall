import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:studmall2/pages/add.dart';
import 'package:studmall2/pages/favoris.dart';
import 'package:studmall2/pages/home.dart';
import 'package:studmall2/pages/message.dart';
import 'package:studmall2/pages/profile.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late List<Widget> pages;

  late Home HomePage;
  late Favoris favoris;
  late Add add;
  late ConversationsPage message;
  late Profile profile;
  int currentTabIndex = 0;

  @override
  void initState() {
    HomePage = Home();
    favoris = Favoris();
    add = Add();
    message = ConversationsPage();
    profile = Profile();
    pages = [HomePage, favoris, add, message, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: Colors.white,
        color: const Color.fromARGB(255, 65, 22, 165),
        animationDuration: Duration(milliseconds: 300),
        onTap: (int index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        items: [
          Icon(Icons.home_outlined, color: Colors.white),
          Icon(Icons.favorite_border, color: Colors.white),
          Icon(Icons.add, color: Colors.white),
          Icon(Icons.message_outlined, color: Colors.white),
          Icon(Icons.person_outline, color: Colors.white),
        ],
      ),
      body: pages[currentTabIndex],
    );
  }
}
