import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/provider/auth_provider.dart';
import 'package:testing_pet/screens/chatbot/chat_bot_ai.dart';
import 'package:testing_pet/screens/home_screen_content.dart';
import 'package:testing_pet/screens/message/message_screen.dart';
import 'package:testing_pet/screens/pet_add/pet_list_screen.dart';
import 'package:testing_pet/screens/routing/routing_helper.dart';
import 'package:testing_pet/widgets/buttom_navbar_items.dart';
import 'package:testing_pet/widgets/guest_dialog.dart';

class HomeScreen extends StatefulWidget {
  final KakaoAppUser appUser;

  const HomeScreen({Key? key, required this.appUser}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 변경: _selectedIndex를 상태로 선언
  bool _appBarVisible = true;
  late KakaoAppUser _appUser;

  @override
  void initState() {
    super.initState();
    print('widget.appUser type: ${widget.appUser.runtimeType}');

    if (widget.appUser is KakaoAppUser) {
      _appUser = widget.appUser;
    } else {
      // 예상치 못한 형식이라면 적절히 처리
      print('Unexpected type for widget.appUser');
    }
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    routingHelper(context, index, _selectedIndex);
  }

  void _performLogout(BuildContext context) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');

    await Navigator.pushNamedAndRemoveUntil(
        context, '/login', (Route<dynamic> route) => false);
  }

  static List<Widget> _widgetOptions(KakaoAppUser appUser) => [
    HomeScreenContent(appUser: appUser,),
    MessageScreen(appUser: appUser, petId: ''),
    ChatBotAi(),
    PetListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    print('widget.appUser: ${widget.appUser.user_id}');
    return Scaffold(
      endDrawer: buildDrawer(context),
      appBar: _appBarVisible
          ? AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        backgroundColor: Colors.white,
        toolbarHeight: 65,
        title: Row(
          children: [
            Center(
              child: Image.asset(
                'assets/images/index_images/WITDOG.png',
                width: 130,
                height: 100,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_none,
              color: Colors.grey,
              size: 30,
            ),
          ),
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                icon: Icon(
                  Icons.menu,
                  color: Colors.grey,
                  size: 30,
                ),
              );
            },
          ),
          SizedBox(width: 15),
        ],
      )
          : null,
      body: _selectedIndex == 0
        ? GestureDetector(
        onTap: () {
          print('print guest user :${widget.appUser}');

          if (widget.appUser == null) {
        
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GuestDialog()),
        );
      } else {
        
        setState(() {
          _selectedIndex = 0; 
        });
      }
    },
    child: HomeScreenContent(appUser: widget.appUser,), // 클릭 가능한 위젯
    )
        : _widgetOptions(widget.appUser)[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: bottomNavBarItems,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF6ABFB9),
        showUnselectedLabels: _appBarVisible,
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 150,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF6ABFB9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Text(
                '메뉴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              color: Colors.grey[850],
            ),
            title: Text('홈'),
            onTap: () {
              // 변경: 홈 아이콘을 누를 때마다 홈 화면으로 이동하도록 수정
              setState(() {
                _selectedIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.grey[850],
            ),
            title: Text('로그아웃'),
            onTap: () {
              _performLogout(context);
            },
          )
        ],
      ),
    );
  }

  void handleMenuItemClick(String selectedItem) {
    print('Selected item: $selectedItem');
  }
}