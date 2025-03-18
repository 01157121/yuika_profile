import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class LiveItem {
  final String title;
  final String date;
  final String url;
  final String content;

  LiveItem({
    required this.title,
    required this.date,
    required this.url,
    this.content = '',
  });
}

class LiveScraper {
  static Future<List<LiveItem>> fetchLiveInfo() async {
    final url = 'https://www.universal-music.co.jp/yuika/news/cat/live/';
    final response = await http.get(Uri.parse(url));
    final document = parser.parse(response.body);
    
    final liveItems = <LiveItem>[];
    final newsElements = document.querySelectorAll('.list-row');
    
    for (var element in newsElements) {
      // 從 a 標籤獲取 URL
      final linkElement = element.querySelector('a');
      final url = linkElement?.attributes['href'] ?? '';
      
      // 從 tags__date 獲取日期
      final date = element.querySelector('.tags__date')?.text.trim() ?? '';
      
      // 從 list-row__detail 中的 p 標籤獲取標題
      // 根據您的HTML結構，標題是在 list-row__detail 下的第二個 p 標籤
      final titleElement = element.querySelector('.list-row__detail > p:last-child');
      final title = titleElement?.text.trim() ?? '';
      
      // 可以選擇性地獲取新聞類別
      final category = element.querySelector('.tags__icon')?.text.trim() ?? '';
      
      if (title.isNotEmpty && date.isNotEmpty) {
        liveItems.add(LiveItem(
          title: title,
          date: date,
          url: url,
        ));
      }
    }
    
    return liveItems;
  }
}