import 'package:flutter/material.dart';
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/screens/chatbot/chat_bot_ai.dart';
import 'package:testing_pet/screens/message/message_screen.dart';
import 'package:testing_pet/screens/pet_add/pet_list_screen.dart';
import 'package:testing_pet/screens/video_screen/video_chat_screen.dart';
import 'package:testing_pet/widgets/service_guide_dialog.dart';

class HomeScreenContent extends StatelessWidget {
  late KakaoAppUser appUser;

  HomeScreenContent({Key? key, required this.appUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        return buildMobileLayout(context);
      }),
    );
  }

  Widget buildMobileLayout(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          floating: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: Color(0xFFD4ECEA),
              child: Card(
                elevation: 1.5,
                color: Color(0xFFD4ECEA),
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ServiceGuideDialog();
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Image.asset(
                                'assets/images/index_images/demo_dialog.png'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(10),
          sliver: SliverGrid.count(
            crossAxisCount: 2,
            children: [
              buildCard(
                context,
                '영상 통화',
                'assets/images/index_images/demo_video_call.png',
                VideoChatScreen(callerId: appUser.user_id),
              ),
              buildCard(
                context,
                '채팅',
                'assets/images/index_images/demo_chat.png',
                MessageScreen(
                  appUser: appUser,
                  petIdentity: '',
                ),
              ),
              buildCard(
                context,
                '펫 봇',
                'assets/images/index_images/demo_chatbot.png',
                ChatBotAi(),
              ),
              buildCard(
                context,
                '반려 프로필',
                'assets/images/index_images/demo_community.png',
                PetListScreen(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCard(
      BuildContext context, String title, String imagePath, Widget route) {
    return Card(
      color: Color(0xFFD4ECEA),
      elevation: 1.5,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return route;
          }));
        },
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath, width: 100, height: 100),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
