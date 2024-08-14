import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hussein TV',
      theme: ThemeData(
        primaryColor: Color(0xFF512da8), // لون البار العلوي والسفلي
        scaffoldBackgroundColor: Color(0xFF673ab7), // لون خلفية الشاشة الرئيسية
        cardColor: Colors.white, // لون بطاقات المحتوى
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF512da8), // لون شريط التطبيق العلوي
          foregroundColor: Colors.white, // لون النص في شريط التطبيق العلوي
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF512da8), // لون شريط التنقل السفلي
          selectedItemColor: Colors.white, // لون العناصر المحددة
          unselectedItemColor: Colors.white54, // لون العناصر غير المحددة
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            color: Color(0xFF673ab7), // لون العناوين
            fontWeight: FontWeight.bold,
            fontSize: 28, // زيادة حجم العنوان
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF424242), // لون النص
            fontSize: 18, // زيادة حجم النص
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late Future<List<dynamic>> channelCategories;
  late Future<List<dynamic>> newsArticles;
  late Future<List<dynamic>> matches;

  @override
  void initState() {
    super.initState();
    channelCategories = fetchChannelCategories();
    newsArticles = fetchNews();
    matches = fetchMatches();
  }

  Future<List<dynamic>> fetchChannelCategories() async {
    try {
      final response = await http.get(Uri.parse('https://st2-5jox.onrender.com/api/channel-categories?populate=channels'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('خطأ في استرجاع القنوات: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ: $e');
      throw Exception('خطأ في استرجاع القنوات');
    }
  }

  Future<List<dynamic>> fetchNews() async {
    final response = await http.get(Uri.parse('https://st2-5jox.onrender.com/api/news?populate=*'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('خطأ في استرجاع الأخبار');
    }
  }

  Future<List<dynamic>> fetchMatches() async {
    final response = await http.get(Uri.parse('https://st2-5jox.onrender.com/api/matches?populate=*'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('خطأ في استرجاع المباريات');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hussein TV'),
      ),
      body: _selectedIndex == 0
          ? ChannelsSection(channelCategories: channelCategories)
          : _selectedIndex == 1
          ? LiveSection(newsArticles: newsArticles, matches: matches)
          : MatchesSection(matches: matches),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.tv),
            label: 'القنوات',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.video), // استخدام أيقونة الفيديو
            label: 'مباشر',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.futbol),
            label: 'المباريات',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ChannelsSection extends StatelessWidget {
  final Future<List<dynamic>> channelCategories;

  ChannelsSection({required this.channelCategories});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: channelCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('خطأ في استرجاع القنوات'));
        } else {
          final categories = snapshot.data!;
          return ListView.separated(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return ChannelBox(category: categories[index]);
            },
            separatorBuilder: (context, index) => SizedBox(height: 16), // زيادة المسافة
          );
        }
      },
    );
  }
}

class ChannelBox extends StatelessWidget {
  final dynamic category;

  ChannelBox({required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Center(
          child: Text(
            category['attributes']['name'],
            style: TextStyle(
              color: Color(0xFF673ab7), // لون اسم القناة
              fontSize: 30, // تكبير حجم الخط
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CategoryChannelsScreen(channels: category['attributes']['channels']['data']),
            ),
          );
        },
      ),
    );
  }
}

class CategoryChannelsScreen extends StatelessWidget {
  final List<dynamic> channels;

  CategoryChannelsScreen({required this.channels});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('القنوات'),
      ),
      body: ListView.separated(
        itemCount: channels.length,
        itemBuilder: (context, index) {
          return ChannelTile(channel: channels[index]);
        },
        separatorBuilder: (context, index) => SizedBox(height: 16), // زيادة المسافة
      ),
    );
  }
}

class ChannelTile extends StatelessWidget {
  final dynamic channel;

  ChannelTile({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Center(
          child: Text(
            channel['attributes']['name'],
            style: TextStyle(
              color: Color(0xFF673ab7), // لون اسم القناة
              fontSize: 30, // تكبير حجم الخط
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          launchURL(channel['attributes']['streamLink']);
        },
      ),
    );
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class LiveSection extends StatelessWidget {
  final Future<List<dynamic>> newsArticles;
  final Future<List<dynamic>> matches;

  LiveSection({required this.newsArticles, required this.matches});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: newsArticles,
      builder: (context, newsSnapshot) {
        if (newsSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (newsSnapshot.hasError) {
          return Center(child: Text('خطأ في استرجاع الأخبار'));
        } else {
          final news = newsSnapshot.data!;
          return FutureBuilder<List<dynamic>>(
            future: matches,
            builder: (context, matchesSnapshot) {
              if (matchesSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (matchesSnapshot.hasError) {
                return Center(child: Text('خطأ في استرجاع المباريات'));
              } else {
                final matches = matchesSnapshot.data!;
                return ListView(
                  children: [
                    ...news.map((article) => NewsBox(article: article)).toList(),
                    SizedBox(height: 16), // إضافة مسافة بين الأخبار والمباريات
                    ...matches.map((match) => MatchBox(match: match)).toList(),
                  ],
                );
              }
            },
          );
        }
      },
    );
  }
}

class NewsBox extends StatelessWidget {
  final dynamic article;

  NewsBox({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article['attributes']['title'],
              style: TextStyle(
                color: Color(0xFF673ab7), // لون عنوان الخبر
                fontSize: 20, // زيادة حجم الخط
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Image.network(article['attributes']['image']['data']['attributes']['url']),
            SizedBox(height: 8),
            Text(
              article['attributes']['content'],
              style: TextStyle(
                color: Color(0xFF424242), // لون نص المحتوى
              ),
            ),
            SizedBox(height: 8),
            Text(
              'تاريخ النشر: ${DateTime.parse(article['attributes']['date']).toLocal()}',
              style: TextStyle(
                color: Color(0xFF9e9e9e), // لون تاريخ النشر
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchesSection extends StatelessWidget {
  final Future<List<dynamic>> matches;

  MatchesSection({required this.matches});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: matches,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('خطأ في استرجاع المباريات'));
        } else {
          final matchList = snapshot.data!;
          return ListView.separated(
            itemCount: matchList.length,
            itemBuilder: (context, index) {
              return MatchBox(match: matchList[index]);
            },
            separatorBuilder: (context, index) => SizedBox(height: 16), // زيادة المسافة
          );
        }
      },
    );
  }
}

class MatchBox extends StatelessWidget {
  final dynamic match;

  MatchBox({required this.match});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${match['attributes']['teamA']} vs ${match['attributes']['teamB']}',
              style: TextStyle(
                color: Color(0xFF673ab7), // لون أسماء الفرق
                fontSize: 20, // زيادة حجم الخط
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(match['attributes']['logoA']['data']['attributes']['url']),
                SizedBox(width: 16),
                Text(
                  'VS',
                  style: TextStyle(
                    color: Color(0xFF673ab7),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 16),
                Image.network(match['attributes']['logoB']['data']['attributes']['url']),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'المعلق: ${match['attributes']['commentator']}',
              style: TextStyle(
                color: Color(0xFF424242), // لون اسم المعلق
              ),
            ),
            SizedBox(height: 8),
            Text(
              'اسم القناة: ${match['attributes']['channel']}',
              style: TextStyle(
                color: Color(0xFF424242), // لون اسم القناة
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                openVideo(context, match['attributes']['streamLink']);
              },
              child: Text('مشاهدة المباراة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF673ab7), // لون زر المشاهدة
                foregroundColor: Colors.white, // لون نص الزر
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openVideo(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(url: url),
      ),
    );
  }
}

class VideoPlayerScreen extends StatelessWidget {
  final String url;

  VideoPlayerScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مشغل الفيديو'),
      ),
      body: Center(
        child: VideoPlayerWidget(url: url),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  VideoPlayerWidget({required this.url});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}