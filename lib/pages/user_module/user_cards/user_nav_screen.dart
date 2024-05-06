// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';

//import 'package:on_spot_mechanic/utils/colors.dart';
import 'package:line_icons/line_icons.dart';

import '../../../models/user_models.dart';
import '../../../utils/colors.dart';
import '../user_home.dart';
import '../user_profile.dart';
import '../user_vehicle.dart';

class UserNavPage extends StatefulWidget {
  final int index;
  const UserNavPage({super.key, required this.index});

  @override
  State<UserNavPage> createState() => _UserNavPageState();
}

class _UserNavPageState extends State<UserNavPage> {
  UserModel get userModel => _userModel;

  late UserModel _userModel;
  int currentPageIndex = 1;
  int _selectedIndex = 1;
  static const List<Widget> _widgetOptions = <Widget>[
    UserVehiclePage(),
    UserHomeScreen(),
    UserProfilePage()
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex =
        widget.index; // Set the initial index from the widget's parameter
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: PageStorageKey('user_nav_screen'), // Add PageStorageKey here

      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: secondaryColor, boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
        ]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
                gap: 8,
                activeColor: primaryColor,
                iconSize: 24,
                tabBackgroundColor: Color.fromARGB(255, 43, 48, 57),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                duration: Duration(milliseconds: 800),
                tabs: [
                  GButton(
                    icon: LineIcons.car,
                    iconColor: silver,
                    text: 'Vehicle',
                  ),
                  GButton(
                    icon: LineIcons.home,
                    iconColor: silver,
                    text: 'Home',
                  ),
                  GButton(
                    icon: LineIcons.user,
                    iconColor: silver,
                    text: 'Profile',
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                }),
          ),
        ),
      ),
    );
  }
}
