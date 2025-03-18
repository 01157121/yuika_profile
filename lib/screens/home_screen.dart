import 'package:flutter/material.dart';
import 'news.dart';

// ...existing code...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        // ...existing code...
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                    ),
                  ),
                  Image.asset('assets/images/drawback.png'),
                ],
              ),
            ),
            // ...existing drawer items...
          ],
        ),
      ),
      body: Column(
        children: [
          NewsWidget(),
          // ...existing code...
        ],
      ),
    );
  }
// ...existing code...
