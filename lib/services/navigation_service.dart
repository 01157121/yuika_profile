import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationService {
  static void navigateToPage(BuildContext context, String page) {
    switch (page) {
      case 'top':
        Navigator.pushNamed(context, '/home');
        break;
      case 'news':
        Navigator.pushNamed(context, '/news');
        break;
      case 'artists':
        Navigator.pushNamed(context, '/artists');
        break;
      case 'live':
        Navigator.pushNamed(context, '/live');
        break;
      case 'release':
        Navigator.pushNamed(context, '/release');
        break;
      case 'shop':
        _launchURL('https://yuika-store.jp');
        Navigator.pushNamed(context, '/home');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$page 頁面尚未實現'),
            duration: Duration(seconds: 1),
          ),
        );
    }
  }

  static Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $urlString');
    }
  }
}
