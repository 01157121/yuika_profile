import 'package:flutter/material.dart';
import 'services/navigation_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ArtistPage extends StatefulWidget {
  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  final List<String> menuItems = ['top', 'news', 'artists', 'live', 'release', 'shop'];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentLanguage = 'zh'; // 'zh' for Chinese, 'ja' for Japanese

  final Map<String, String> _introText = {
    'ja': '''奈良出身、20歳女性シンガーソングライター。

2021年にTikTokに投稿した「好きだから。」がティーンから絶大な共感を生み、
10代2万人が選んだ"恋したくなるラブソング"1位にも選ばれるほど人気が急上昇。

人気は日本にとどまらず、アジア各国のSpotifyバイラルチャートインを果たしヒット。
青春の光景をリアルタイムで伝えるアーティストとして熱い注目を集めている。

2024年にメジャーデビューが決定し、6月14日に1st Album『紺色に憧れて』をリリース。6月27日にKT Zepp Yokohamaにて行われた自身初のライブ、『ユイカ』1st LIVE「Agapanthus」は即完し、2025年1月には2nd LIVE「Sweet Alyssum」をKT Zepp Yokohama、Zepp Osaka Baysideにて開催。6月には初の企画ライブを豊洲PIT、9月には初の全国Zeppツアーの開催も決定している。''',
    'zh': '''Yuika來自奈良縣。

2005年生的高三生。截至2022年12月，身高為151.2公分。

從2020年起，她開始使用Twitter和TikTok，並上傳了一段以吉他自彈自唱的影片。

2021年7月，代表作〈好きだから。〉在 YouTube 上發表。並開始在Spotify等排行榜上占據榜首，曾被男歌手天月翻唱。 YouTube頻道的觀看次數已超過 9000 萬次。

2021年10月3日，自創的第二首歌曲〈そばにいて。〉首播 。這首歌被用作濱邊美波主演的 TikTok 短片《夏、ふたり》的主題曲。

2024年1月12日，宣布與環球音樂有限公司簽約出道。
2025年1月12日於20歲生日宣佈露臉繼續歌手活動。

其他：
• 將坂口有望的〈月には內緒で〉列為「世界上最喜歡的歌曲」
• 擅長模仿蟬的聲音
• 左右開弓。握鉛筆或筷子時用右手，投球時用左手
• 喜歡的漫畫是綾瀨羽美的《理想的男朋友》、星谷香織的《たまのごほうび》和湯木のじん的《普通的我們》'''
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Artist'),
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
              ...menuItems.map((item) => ListTile(
                title: Text(
                  item,
                  style: TextStyle(color: Colors.blue[700]),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToPage(context, item);
                },
              )).toList(),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(16),
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
                    child: Image.asset(
                      'assets/image/artist.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                ArtistSocialMedia(),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    _introText[_currentLanguage]!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue[700],
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 80), // Space for FAB
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              child: Text(_currentLanguage.toUpperCase()),
              onPressed: () {
                setState(() {
                  _currentLanguage = _currentLanguage == 'zh' ? 'ja' : 'zh';
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(BuildContext context, String page) {
    Navigator.pop(context);
    NavigationService.navigateToPage(context, page);
  }
}

class ArtistSocialMedia extends StatelessWidget {
  const ArtistSocialMedia({Key? key}) : super(key: key);

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $urlString');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon image
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          width: 200,
          height: 200,
          child: Image.asset(
            'assets/image/icon.png',
            fit: BoxFit.contain,
          ),
        ),
        // Social Media Icons Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                iconSize: 50,
                icon: Image.network(
                  'https://www.innovax.hk/wp-content/uploads/2022/10/%E2%80%94Pngtree%E2%80%94youtube-social-media-round-icon_8704829.png',
                  width: 50,
                  height: 50,
                ),
                onPressed: () => _launchURL('https://www.youtube.com/channel/UC2iRI4qf-H_BdpsS8mMEjZQ'),
              ),
            ),
            Container(
              width: 50,
              height: 50,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                iconSize: 50,
                icon: Image.network(
                  'https://w7.pngwing.com/pngs/676/1/png-transparent-x-icon-ex-twitter-tech-companies-social-media-thumbnail.png',
                  width: 50,
                  height: 50,
                ),
                onPressed: () => _launchURL('https://twitter.com/yuika_singuitar'),
              ),
            ),
            Container(
              width: 50,
              height: 50,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                iconSize: 50,
                icon: Image.asset(
                  'assets/image/ig.png',
                  width: 50,
                  height: 50,
                ),
                onPressed: () => _launchURL('https://instagram.com/yuika_singuitar/'),
              ),
            ),
            Container(
              width: 50,
              height: 50,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                iconSize: 50,
                icon: Image.network(
                  'https://static.vecteezy.com/system/resources/previews/020/964/382/non_2x/tiktok-circle-icon-for-web-design-free-png.png',
                  width: 50,
                  height: 50,
                ),
                onPressed: () => _launchURL('https://www.tiktok.com/@yuika_singuitar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
