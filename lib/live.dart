import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/navigation_service.dart';
import 'services/live_scraper.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  final List<String> menuItems = ['top', 'news', 'artists', 'live', 'release', 'shop'];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<LiveItem> liveItems = [];
  bool isLoading = true;
  final PageController _pageController = PageController();
  final List<Map<String, dynamic>> currentLives = [
    {
      'image': 'assets/image/barnew2.jpg',
      'title': '『ユイカ』presents「時計草」',
      'url': 'https://t.pia.jp/pia/event/event.do?eventBundleCd=b2557168',
    },
    {
      'image': 'assets/image/barnew3.jpg',
      'title': '『ユイカ』TOUR 「Tsukimisou」',
      'url': 'https://t.pia.jp/pia/event/event.do?eventBundleCd=b2556502',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchLiveInfo();
  }

  Future<void> _fetchLiveInfo() async {
    try {
      final items = await LiveScraper.fetchLiveInfo();
      setState(() {
        liveItems = items;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching live info: $e');
      setState(() => isLoading = false);
    }
  }

  void _navigateToPage(BuildContext context, String page) {
    Navigator.pop(context);
    NavigationService.navigateToPage(context, page);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Live'),
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
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 40,
            color: Colors.blue[50],
            child: Center(
              child: Text(
                'CURRENT LIVE',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: _pageController,
              itemCount: currentLives.length,
              itemBuilder: (context, index) {
                final live = currentLives[index];
                return Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () async {
                          final url = Uri.parse(live['url']);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Image.asset(
                              live['image'],
                              fit: BoxFit.cover,
                              height: 200,
                            ),
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                live['title'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            height: 40,
            color: Colors.blue[50],
            child: Center(
              child: Text(
                'LIVE NEWS',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : liveItems.isEmpty
                    ? const Center(child: Text('No live information available'))
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 16),
                        itemCount: liveItems.length,
                        itemBuilder: (context, index) {
                          final item = liveItems[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text(item.title),
                              subtitle: Text(item.date),
                              onTap: () async {
                                final url = Uri.parse(item.url);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
