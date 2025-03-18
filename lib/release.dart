import 'package:flutter/material.dart';
import 'services/navigation_service.dart';
import 'services/release_scraper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';

class ReleasePage extends StatefulWidget {
  const ReleasePage({super.key});

  @override
  State<ReleasePage> createState() => _ReleasePageState();
}

class _ReleasePageState extends State<ReleasePage> with SingleTickerProviderStateMixin {
  final List<String> menuItems = ['top', 'news', 'artists', 'live', 'release', 'shop'];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  List<ReleaseItem> digitalReleases = [];
  bool isLoading = true;
  AlbumItem? albumInfo;
  final AudioPlayer audioPlayer = AudioPlayer();
  Track? currentTrack;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isControllerVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchReleases();
    _fetchAlbumInfo();
    _setupAudioPlayer();
  }

  Future<void> _fetchReleases() async {
    try {
      final releases = await ReleaseScraper.fetchDigitalReleases();
      setState(() {
        digitalReleases = releases;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching releases: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchAlbumInfo() async {
    try {
      final album = await ReleaseScraper.fetchAlbumInfo();
      setState(() {
        albumInfo = album;
      });
    } catch (e) {
      print('Error fetching album info: $e');
    }
  }

  void _setupAudioPlayer() {
    audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() => duration = newDuration);
      }
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() => position = newPosition);
      }
    });

    audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        _playNext();
      }
    });
  }

  void _playTrack(Track track) async {
    try {
      final source = AssetSource('video/${track.title}.m4a'); // Changed from m4a to mp3
      if (currentTrack?.title != track.title) {
        await audioPlayer.stop();
        await audioPlayer.play(source);
        if (mounted) {
          setState(() {
            currentTrack = track;
            isPlaying = true;
            isControllerVisible = true;
          });
        }
      } else {
        if (isPlaying) {
          await audioPlayer.pause();
        } else {
          await audioPlayer.resume();
        }
        if (mounted) {
          setState(() => isPlaying = !isPlaying);
        }
      }
    } catch (e) {
      print('Error playing track: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not play track: ${track.title}')),
      );
    }
  }

  void _playNext() {
    if (currentTrack == null || albumInfo == null) return;
    final currentIndex = albumInfo!.tracks.indexOf(currentTrack!);
    if (currentIndex < albumInfo!.tracks.length - 1) {
      _playTrack(albumInfo!.tracks[currentIndex + 1]);
    }
  }

  void _playPrevious() {
    if (currentTrack == null || albumInfo == null) return;
    final currentIndex = albumInfo!.tracks.indexOf(currentTrack!);
    if (currentIndex > 0) {
      _playTrack(albumInfo!.tracks[currentIndex - 1]);
    }
  }

  void _navigateToPage(BuildContext context, String page) {
    Navigator.pop(context);
    NavigationService.navigateToPage(context, page);
  }

  void _showStreamingDialog(ReleaseItem release) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(release.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (release.spotifyUrl != null)
              InkWell(
                onTap: () => launchUrl(Uri.parse(release.spotifyUrl!)),
                child: Image.network(
                  'https://www.universal-music.co.jp/yuika/wp-content/plugins/umj-pim2/assets/img/affiliates/240x60/spotify.jpg',
                  height: 60,
                ),
              ),
            SizedBox(height: 8),
            if (release.appleUrl != null)
              InkWell(
                onTap: () => launchUrl(Uri.parse(release.appleUrl!)),
                child: Image.network(
                  'https://www.universal-music.co.jp/yuika/wp-content/plugins/umj-pim2/assets/img/affiliates/240x60/AppleMusic.jpg',
                  height: 60,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioController() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      bottom: isControllerVisible ? 0 : -100,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentTrack != null) Text(
              currentTrack!.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: position.inSeconds.toDouble(),
              max: duration.inSeconds.toDouble(),
              onChanged: (value) async {
                await audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous),
                  onPressed: _playPrevious,
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () => currentTrack != null ? _playTrack(currentTrack!) : null,
                ),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: _playNext,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackList() {
    return Column(
      children: albumInfo!.tracks.map((track) => ListTile(
        title: Text(track.title),
        subtitle: Text(
          track.titleEn,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: IconButton(
          icon: Icon(
            currentTrack?.title == track.title && isPlaying 
                ? Icons.pause_circle_outline 
                : Icons.play_circle_outline,
            color: Colors.blue,
          ),
          onPressed: () => _playTrack(track),
        ),
      )).toList(),
    );
  }

  Widget _buildAlbumTab() {
    if (albumInfo == null) {
      return Center(child: CircularProgressIndicator());
    }
    
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: EdgeInsets.all(24),
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
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      albumInfo!.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  albumInfo!.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              _buildTrackList(),
              SizedBox(height: 100), // Space for controller
            ],
          ),
        ),
        _buildAudioController(),
      ],
    );
  }

  Widget _buildDigitalReleaseCard(ReleaseItem release) {
    return InkWell(
      onTap: () => _showStreamingDialog(release),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                release.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        color: Colors.grey[200],
                        child: Text(
                          '発売日',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        release.date,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    release.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Release'),
        backgroundColor: Colors.lightBlue[100],
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.blue),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'ALBUM'),
            Tab(text: 'DIGITAL'),
          ],
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlbumTab(),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: digitalReleases.length,
                  itemBuilder: (context, index) {
                    final release = digitalReleases[index];
                    return _buildDigitalReleaseCard(release);
                  },
                ),
        ],
      ),
    );
  }
}
