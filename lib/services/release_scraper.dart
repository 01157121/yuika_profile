import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class Track {
  final String number;
  final String title;
  final String titleEn;

  Track({
    required this.number,
    required this.title,
    required this.titleEn,
  });
}

class AlbumItem {
  final String title;
  final String imageUrl;
  final List<Track> tracks;

  AlbumItem({
    required this.title,
    required this.imageUrl,
    required this.tracks,
  });
}

class ReleaseItem {
  final String title;
  final String date;
  final String imageUrl;
  final String url;
  final String? spotifyUrl;
  final String? appleUrl;

  ReleaseItem({
    required this.title,
    required this.date,
    required this.imageUrl,
    required this.url,
    this.spotifyUrl,
    this.appleUrl,
  });
}

class ReleaseScraper {
  static Future<AlbumItem> fetchAlbumInfo() async {
    final url = 'https://www.universal-music.co.jp/yuika/products/uv1aa-00334/';
    final response = await http.get(Uri.parse(url));
    final document = parser.parse(response.body);
    
    // 從新的HTML結構中抓取標題和圖片URL
    final title = document.querySelector('.disco-main__title')?.text.trim() ?? '';
    final imageUrl = document.querySelector('.disco-main__item img')?.attributes['src'] ?? '';

    // 抓取曲目列表
    final tracks = <Track>[];
    final trackElements = document.querySelectorAll('.program__item');
    for (var element in trackElements) {
    final trackNumber = element.querySelector('.program__number')?.text.trim() ?? '';
    final trackTitle = element.querySelector('.track__title')?.text.trim() ?? '';
    final trackTitleEn = element.querySelector('.track__title--en')?.text.trim() ?? '';
    
    
    tracks.add(Track(
      number: trackNumber,
      title: trackTitle, 
      titleEn: trackTitleEn,
    ));
  }
    
    return AlbumItem(
      title: title,
      imageUrl: imageUrl,
      tracks: tracks,
    );
  }

  static Future<List<ReleaseItem>> fetchDigitalReleases() async {
    final url = 'https://www.universal-music.co.jp/yuika/discography/';
    final response = await http.get(Uri.parse(url));
    final document = parser.parse(response.body);
    
    final releases = <ReleaseItem>[];
    final items = document.querySelectorAll('.article--product');
    
    for (var item in items) {
      // 抓取標題、日期、圖片URL和產品URL
      final titleElement = item.querySelector('.prod-name a');
      final dateElement = item.querySelector('.prod-data__text');
      final imageElement = item.querySelector('.column__fig--l img');
      final linkElement = item.querySelector('.column__fig--l a');
      
      final title = titleElement?.text.trim() ?? '';
      final date = dateElement?.text.trim() ?? '';
      final imageUrl = imageElement?.attributes['src'] ?? '';
      final productUrl = linkElement?.attributes['href'] ?? '';
      
      // 檢查是否有 modal 元素以獲取 Spotify 和 Apple Music 連結
      final modalElement = item.querySelector('.buy-modal__inner');
      String? spotifyUrl;
      String? appleUrl;
      
      if (modalElement != null) {
        // 尋找 Spotify 連結
        final spotifyElement = modalElement.querySelector('a[href*="spotify.com"]');
        spotifyUrl = spotifyElement?.attributes['href'];
        
        // 尋找 Apple Music 連結
        final appleElement = modalElement.querySelector('a[href*="music.apple.com"]');
        appleUrl = appleElement?.attributes['href'];
      }
      
      if (title.isNotEmpty && date.isNotEmpty) {
        releases.add(ReleaseItem(
          title: title,
          date: date,
          imageUrl: imageUrl,
          url: productUrl,
          spotifyUrl: spotifyUrl,
          appleUrl: appleUrl,
        ));
      }
    }
    
    return releases;
  }
  
  // 如果需要獲取更多詳細信息，可以添加一個方法來抓取單個產品頁面
  static Future<ReleaseItem?> fetchReleaseDetails(String url) async {
    final response = await http.get(Uri.parse(url));
    final document = parser.parse(response.body);
    
    // 獲取基本資訊
    final titleElement = document.querySelector('.prod-name');
    final dateElement = document.querySelector('.prod-data__text');
    final imageElement = document.querySelector('.column__fig--l img');
    
    // 獲取 Spotify 和 Apple Music 連結
    final spotifyElement = document.querySelector('a[href*="spotify.com"]');
    final appleElement = document.querySelector('a[href*="music.apple.com"]');
    
    if (titleElement != null && dateElement != null) {
      return ReleaseItem(
        title: titleElement.text.trim(),
        date: dateElement.text.trim(),
        imageUrl: imageElement?.attributes['src'] ?? '',
        url: url,
        spotifyUrl: spotifyElement?.attributes['href'],
        appleUrl: appleElement?.attributes['href'],
      );
    }
    
    return null;
  }
}