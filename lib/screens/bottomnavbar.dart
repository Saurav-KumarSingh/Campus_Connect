import 'package:collegelink/screens/group_screen.dart';
import 'package:collegelink/screens/home_screen.dart';
import 'package:collegelink/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int CurrentIndex = 0;

  List<Widget> Pages = [
    GroupScreen(),
    HomeScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: CurrentIndex,
        children: Pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.group_add,
              color: CurrentIndex == 0 ? Colors.orange : Colors.black,
            ),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              color: CurrentIndex == 1 ? Colors.orange : Colors.black,
            ),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: CurrentIndex == 2 ? Colors.orange : Colors.black,
            ),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            CurrentIndex = index;
          });
        },
        type: BottomNavigationBarType.shifting,
        currentIndex: CurrentIndex,
        selectedItemColor: Colors.orange,
        iconSize: 30,
        elevation: 10,
        backgroundColor: Colors.white,
      ),
    );
  }
}