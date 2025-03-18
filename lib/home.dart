import 'package:flutter/material.dart';
import 'news.dart';
import 'services/navigation_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 定義文字列表及其對應的功能
  final List<String> menuItems = ['top', 'news', 'artists', 'live', 'release', 'shop'];
  
  // 用來追蹤每個項目是否應該顯示
  List<bool> _visibleItems = [];
  
  @override
  void initState() {
    super.initState();
    // 初始化所有項目為不可見
    _visibleItems = List.generate(menuItems.length, (_) => false);
    
    // 設定延遲動畫
    _setupAnimations();
  }
  
  void _setupAnimations() {
    // 基本延遲
    const baseDelay = 300;
    // 每個項目之間的額外延遲
    const itemDelay = 100;
    
    // 為每個項目設置延遲顯示
    for (int i = 0; i < menuItems.length; i++) {
      Future.delayed(Duration(milliseconds: baseDelay + (i * itemDelay)), () {
        if (mounted) {
          setState(() {
            _visibleItems[i] = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景圖片
          Image.asset(
            'assets/image/home.jpg',
            fit: BoxFit.cover,
          ),
          // 文字
          Positioned(
            left: 1,
            top: 60,
            child: Text(
              '『ユイカ』',
              style: TextStyle(
                fontSize: 50,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 菜單列表容器
          Positioned(
            left: 20,
            top: 150,
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(menuItems.length, (index) {
                  return AnimatedMenuItemEntry(
                    item: menuItems[index], 
                    isLast: index == menuItems.length - 1,
                    visible: _visibleItems[index],
                    onTap: () => _navigateToPage(context, menuItems[index]),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 導航到不同頁面的方法
    void _navigateToPage(BuildContext context, String page) {
    Navigator.pop(context); // Close drawer first
    NavigationService.navigateToPage(context, page);
  }
}

// 修正後的動畫組件
class AnimatedMenuItemEntry extends StatelessWidget {
  final String item;
  final bool isLast;
  final bool visible;
  final VoidCallback onTap;

  const AnimatedMenuItemEntry({
    Key? key,
    required this.item,
    required this.isLast,
    required this.visible,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: AnimatedSlide(
        offset: visible ? Offset.zero : Offset(-1, 0),
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isLast ? Colors.transparent : Colors.white24,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}