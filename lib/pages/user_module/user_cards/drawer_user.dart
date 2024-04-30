// ignore_for_file: library_prefixes, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../authentication_module/welcome.dart';
import 'faq.dart';

class UserDrawer extends StatelessWidget {
  const UserDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthorizationProvider>(context, listen: false);
    return SizedBox(
      child: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 64.0),
                  child: SvgPicture.asset(
                    "assets/Logo .svg",
                    width: 80,
                    height: 80,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: const Text(
                      "H O M E",
                      style: TextStyle(color: Color(0xFF222831)),
                    ),
                    leading: const Icon(Icons.home),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: const Text(
                      "F A Q",
                      style: TextStyle(color: Color(0xFF222831)),
                    ),
                    leading: const Icon(Icons.question_answer),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => FaqPage()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: const Text(
                      "S I G N O U T",
                      style: TextStyle(color: Color(0xFF222831)),
                    ),
                    leading: const Icon(Icons.exit_to_app_outlined),
                    onTap: () {
                      ap.userSignOut().whenComplete(() => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WelcomePage())));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
