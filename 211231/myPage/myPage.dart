import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:plzzzzzzz/myPage/myId.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "마이 페이지",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.settings_sharp,
              color: Colors.black,
            ),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(28, 0, 28, 0),
        alignment: Alignment.topCenter,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(57),
              child: SvgPicture.asset(
                "assets/profile.svg",
                height: 114,
                width: 114,
                fit: BoxFit.fill,
              ),
            ),
            //수정가능ㅇ
            SizedBox(
              height: 13,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Color(0xFFFBC02D),
                    borderRadius: BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                  ),
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  '위고레고',
                  style: TextStyle(
                    color: Colors.purple[800],
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '님',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              '오늘도 행복하세요!',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              height: 74,
              decoration: BoxDecoration(
                color: Color(0xFFF5F3FF),
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 17,
                          child: SvgPicture.asset(
                            "assets/heartIcon.svg",
                          ),
                        ),
                        SizedBox(
                          height: 13,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "받은 하트",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Column(
                              children: [
                                Text(
                                  "9",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFFF57F17),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 19,
                          child: SvgPicture.asset(
                            "assets/answerIcon.svg",
                          ),
                        ),
                        SizedBox(
                          height: 13,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "응답 횟수",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Column(
                              children: [
                                Text(
                                  "9",
                                  style: TextStyle(
                                      fontSize: 9, color: Color(0xFFF57F17)),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 18,
                          child: SvgPicture.asset(
                            "assets/questionIcon.svg",
                          ),
                        ),
                        SizedBox(
                          height: 13,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "질문 횟수",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Column(
                              children: [
                                Text(
                                  "9",
                                  style: TextStyle(
                                      fontSize: 9, color: Color(0xFFF57F17)),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Expanded(
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                children: ListTile.divideTiles(context: context, tiles: [
                  ListTile(
                    title: Text(
                      "계정 정보",
                      style: TextStyle(fontSize: 14, color: Color(0xFF495057)),
                    ),
                    trailing: Container(
                      height: 24,
                      width: 24,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFADB5BD),
                      ),
                    ),
                    onTap: () {
                      // Get.to(myIdPage());
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => myIdPage()),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(
                      "1:1 문의",
                      style: TextStyle(fontSize: 14, color: Color(0xFF495057)),
                    ),
                    trailing: Container(
                      height: 24,
                      width: 24,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFADB5BD),
                      ),
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text(
                      "내가 쓴 게시글 모아보기",
                      style: TextStyle(fontSize: 14, color: Color(0xFF495057)),
                    ),
                    trailing: Container(
                      height: 24,
                      width: 24,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFADB5BD),
                      ),
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text(
                      "활동 상태 변경하기",
                      style: TextStyle(fontSize: 14, color: Color(0xFF495057)),
                    ),
                    trailing: Container(
                      height: 24,
                      width: 24,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFADB5BD),
                      ),
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text(
                      "앱 버전 정보",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF495057),
                      ),
                    ),
                    trailing: Text(
                      "0.5.0",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFADB5BD),
                      ),
                    ),
                    onTap: () {},
                  ),
                ]).toList(),
              ),
            ),
            // Container(
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Colors.blueAccent),
            //   ),
            //   height: 40,
            // ),
            // Container(
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Colors.blueAccent),
            //   ),
            //   height: 40,
            // ),
            // Container(
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Colors.blueAccent),
            //   ),
            //   height: 40,
            // ),
            // Container(
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Colors.blueAccent),
            //   ),
            //   height: 40,
            //   child: Row(children: [Text('계인')],),
            // ),
            // Container(
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Colors.blueAccent),
            //   ),
            //   height: 40,
            // ),
          ],
        ),
      ),
    );
  }
}
