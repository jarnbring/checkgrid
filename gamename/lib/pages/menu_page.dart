import 'package:flutter/material.dart';
import 'package:gamename/pages/game_page.dart';
import 'package:gamename/pages/settings_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget menuButton(String title, Widget routePage) {
      return ElevatedButton(
               onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => routePage),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 20,
                padding:
                    EdgeInsets
                        .zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), 
                ),
                backgroundColor:
                    Colors
                        .transparent,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.purple
                    ], 
                    begin: Alignment.topLeft, 
                    end: Alignment.bottomRight, 
                  ),
                ),
                child: Container(
                  alignment: Alignment.center,
                  width: 200,
                  height: 60,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 150),
            Text('CheckGrid', style: TextStyle(fontSize: 35)),
            const SizedBox(height: 75),
            menuButton("Play", GamePage()),
            const SizedBox(height: 50),
            menuButton("Settings", SettingsPage()),
            const SizedBox(height: 300),
          ],
        ),
      ),
    );
  }
}
