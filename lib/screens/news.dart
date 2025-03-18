import 'package:flutter/material.dart';
import '../news_scraper.dart';

class NewsWidget extends StatelessWidget {
  const NewsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: FutureBuilder<List<NewsItem>>(
        future: NewsScraper.scrapeNews(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return Card(
                  child: ListTile(
                    title: Text(item.title),
                    subtitle: Text(item.date),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ).paddingAll(8),
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

extension PaddingExtension on Widget {
  Widget paddingAll(double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: this,
    );
  }
}
