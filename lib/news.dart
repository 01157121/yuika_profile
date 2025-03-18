import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'news_scraper.dart';
import 'screens/news.dart';
import 'services/navigation_service.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  // 定義文字列表及其對應的功能
  final List<String> menuItems = ['top', 'news', 'artists', 'live', 'release', 'shop'];
  
  // 用來追蹤抽屜是否打開
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('News'),
        backgroundColor: Colors.lightBlue[100],
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.blue),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/image/drawback.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '『ユイカ』',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // 創建菜單項
              ...menuItems.map((item) => ListTile(
                title: Text(
                  item,
                  style: TextStyle(color: Colors.blue[700]),
                ),
                onTap: () {
                  // 關閉抽屜
                  Navigator.pop(context);
                  // 導航到選擇的頁面
                  _navigateToPage(context, item);
                },
              )).toList(),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 大型新聞圖片按鈕區域
            _buildNewsImageSection(),
            
            // 新聞列表區域
            _buildNewsListSection(),
          ],
        ),
      ),
    );
  }

  // 創建大型新聞圖片按鈕區域
  Widget _buildNewsImageSection() {
    return Container(
      height: 250,
      child: PageView(
        children: [
          _buildNewsImageButton('barnew1', 'https://youtu.be/-qSqMSsJ4AE?feature=shared'),
          _buildNewsImageButton('barnew2', 'https://t.pia.jp/pia/event/event.do?eventBundleCd=b2557168'),
          _buildNewsImageButton('barnew3', 'https://t.pia.jp/pia/event/event.do?eventBundleCd=b2556502'),
          _buildNewsImageButton('barnew4', 'https://yuika-store.jp/'),
        ],
      ),
    );
  }

  // 創建單個新聞圖片按鈕
  Widget _buildNewsImageButton(String imageAsset, String url) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () async {
            try {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            } catch (e) {
              debugPrint('Error launching URL: $e');
            }
          },
          child: Image.asset(
            'assets/image/$imageAsset.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // 創建新聞列表區域
  Widget _buildNewsListSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '最新消息',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          FutureBuilder<List<NewsItem>>(
            future: NewsScraper.scrapeNews(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: snapshot.data!.map((item) {
                    return _buildNewsItem(
                      date: item.date,
                      title: item.title,
                      url: item.url, // Pass URL instead of content
                    );
                  }).toList(),
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem({
    required String date,
    required String title,
    required String url,
  }) {
    return Container(
      width: double.infinity, // Make width consistent
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () async {
            try {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            } catch (e) {
              debugPrint('Error launching URL: $e');
            }
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 導航到不同頁面的方法
    void _navigateToPage(BuildContext context, String page) {
    Navigator.pop(context); // Close drawer first
    NavigationService.navigateToPage(context, page);
  }
}