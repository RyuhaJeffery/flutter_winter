import 'dart:async';

import 'package:agora_flutter_quickstart/src/utils/settings.dart';

import 'pie_chart.dart';
import 'heart.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';

import 'dart:math' as math;

class CallPage_helper extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String? channelName;
  const CallPage_helper({Key? key, this.channelName}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage_helper> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool videoOnOff = false;
  late RtcEngine _engine;
  int? streamId;
  late Offset change;
  bool heart = false;
  int helper_one = 0;
  late String uid_check;
  int count = 1;
  bool get_uid = true;
  bool pass_check = true;

  //원 그리기 변수
  late Timer timer;
  bool _isPlaying = false;
  var value = 0;
  Offset? location;
  late String getdetails;
  late double nomalizationDx;
  late double nomalizationDy;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
//원 그리기 변수
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();

    streamId = await _engine.createDataStream(false, false);

    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    //configuration.dimensions = VideoDimensions(1920, 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(null, widget.channelName!, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.Communication);
    //만약에 1to1으로 만들려면 LiveBroadcasting이거 대신에 Communication으로 넣으면 일대일이 가능해짐
    //await _engine.setClientRole(ClientRole.Broadcaster);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
      },
      leaveChannel: (stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          _users.add(uid);
        });
        if (get_uid) {
          uid_check = uid.toString();
          get_uid = false;
        }
      },
      userOffline: (uid, elapsed) {
        setState(() {
          final info = 'userOffline: $uid';
          _infoStrings.add(info);
          _users.remove(uid);
        });
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        pass_check = false;
        setState(() {
          final info = 'firstRemoteVideo: $uid ${width}x $height';
          _infoStrings.add(info);
        });
      },
      streamMessage: (_, __, coordinates) {
        if (coordinates.compareTo('end') == 0) {
          Navigator.pop(context);
        } else if (coordinates.compareTo('onoffVideo') == 0) {
          setState(() {
            videoOnOff = !videoOnOff;
          });
        } else if (coordinates.compareTo('heart') == 0) {
          popUp();
        } else if (coordinates.compareTo(uid_check) == 0) {
          if (pass_check) {
            Navigator.pop(context);
          }
        }
      },
      streamMessageError: (_, __, error, ___, ____) {
        final String info = "here is the error $error";
        print(info);
      },
    ));
  }

  // Helper function to get list of native views
  List<Widget> _getRenderViews() {
    print("check po11int 156");

    final List<StatefulWidget> list = [];
    //if (widget.role == ClientRole.Broadcaster) {}
    _users.forEach((int uid) => list.add(
        RtcRemoteView.SurfaceView(uid: uid, renderMode: VideoRenderMode.FILL)));
    list.add(RtcLocalView.SurfaceView(renderMode: VideoRenderMode.FILL));
    return list;
  }

  // Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  // Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  // Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container();
      case 2:
        CircularProgressIndicator();
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
          ],
        ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      //if (heart == true) heartPop(),
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          //   child: MaterialButton(
          //     minWidth: 0,
          //     onPressed: () async {},
          //     child: Icon(
          //       Icons.favorite,
          //       color: Color(0xffe82b50),
          //       size: 30.0,
          //     ),
          //     padding: const EdgeInsets.all(12.0),
          //   ),
          // ),
        ],
      ),
    );
  }

  //bool heart = false;
  final _random = math.Random();
  late Timer _timer;
  double height = 0.0;
  int _numConfetti = 10;
  var len;
  bool accepted = false;
  bool stop = false;

  void popUp() async {
    setState(() {
      heart = true;
    });

    _timer = Timer.periodic(Duration(milliseconds: 125), (Timer t) {
      setState(() {
        height += _random.nextInt(20);
      });
    });

    Timer(
        Duration(seconds: 4),
        () => {
              _timer.cancel(),
              setState(() {
                heart = false;
              })
            });
  }

  Widget heartPop() {
    final size = MediaQuery.of(context).size;
    final confetti = <Widget>[];
    for (var i = 0; i < _numConfetti; i++) {
      final height = _random.nextInt(size.height.floor());
      final width = 0;
      confetti.add(HeartAnim(
        height % 300.0,
        //width.toDouble(),
        1,
      ));
    }

    return Container(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            //height: 0,
            width: (MediaQuery.of(context).size.width / 2),
            child: Stack(
              children: confetti,
            ),
          ),
        ),
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return Text(
                    "null"); // return type can't be null, a widget was required
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    _engine.sendStreamMessage(streamId!, "end");
    // Get.back();
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
      print(muted);
    });
    _engine.muteLocalAudioStream(muted);
  }

  Widget _turnoffcamera() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage("https://i.ibb.co/nsVhXLq/black-background.jpg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black, BlendMode.dstATop),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "카메라가 꺼져있습니다\nCamera is off",
              style: TextStyle(
                color: Color(0xffffffff),
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "음성으로 도움을 주세요!\nHelp with your voice",
              style: TextStyle(
                color: Color(0xff979797),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget circleDrawing(BuildContext context) {
    return Container(
      //보낼 때
      child: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTapDown: (TapDownDetails details) {
                setState(() {
                  location = details.localPosition;
                });
                value = 0;
                timer = Timer.periodic(Duration(milliseconds: 2), (t) {
                  setState(() {
                    if (value < 100) {
                      value++;
                    } else {
                      timer.cancel();
                      nomalizationDx = details.localPosition.dx /
                          MediaQuery.of(context).size.width;
                      nomalizationDy = details.localPosition.dy /
                          MediaQuery.of(context).size.height;
                      getdetails = nomalizationDx.toString() +
                          " " +
                          nomalizationDy.toString() +
                          "a";
                      _engine.sendStreamMessage(streamId!, getdetails);
                    }
                  });
                  //print('value $value');
                });
              },
            ),
          ),
          CustomPaint(
            size: Size(100, 100),
            painter: PieChart(
              percentage: value,
              location: location,
            ),
          ),
        ],
      ),
    );
  }

  Widget voiceOff(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "음성이 꺼져 있습니다.\nVoice is off",
            style: TextStyle(
              color: Color(0xff7EA68D),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: videoOnOff
            ? Center(
                child: Stack(
                  children: <Widget>[
                    _turnoffcamera(),
                    if (heart == true) heartPop(),
                    // _panel(),
                    muted ? voiceOff(context) : Container(),
                    _toolbar(),
                  ],
                ),
              )
            : Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      _viewRows(),
                      if (heart == true) heartPop(),
                      // _panel(),
                      muted ? voiceOff(context) : Container(),
                      circleDrawing(context),
                      _toolbar(),
                    ],
                  ),
                ),
              ));
  }
}

// class PieChart extends CustomPainter {
//   int percentage = 0;
//   Offset? location;

//   PieChart({required this.percentage, this.location});

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint() // 화면에 그릴 때 쓸 Paint를 정의합니다.
//       ..strokeWidth = 10.0 // 선의 길이를 정합니다.
//       ..style =
//           PaintingStyle.stroke // 선의 스타일을 정합니다. stroke면 외곽선만 그리고, fill이면 다 채웁니다.
//       ..strokeCap =
//           StrokeCap.round; // stroke의 스타일을 정합니다. round를 고르면 stroke의 끝이 둥글게 됩니다.

//     double radius = min(
//         size.width / 2 - paint.strokeWidth / 2,
//         size.height / 2 -
//             paint.strokeWidth / 2); // 원의 반지름을 구함. 선의 굵기에 영향을 받지 않게 보정함.
//     Offset? center = location; // 원이 위젯의 가운데에 그려지게 좌표를 정함.

//     canvas.drawCircle(center!, radius, paint); // 원을 그림.

//     double arcAngle =
//         2 * pi * (percentage / 100); // 호(arc)의 각도를 정함. 정해진 각도만큼만 그리도록 함.

//     paint..color = Colors.deepPurpleAccent; // 호를 그릴 때는 색을 바꿔줌.

//     canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
//         arcAngle, false, paint);
//     // canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
//     //     arcAngle, false, paint); // 호(arc)를 그림.
//   }

//   @override
//   bool shouldRepaint(PieChart old) {
//     return old.percentage != percentage;
//   }
// }

// class _DrawingPainter extends CustomPainter {
//   final List<DrawingPoint> drawingPoints;

//   _DrawingPainter(this.drawingPoints);

//   List<Offset> offsetsList = [];

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (int i = 0; i < drawingPoints.length; i++) {
//       if (drawingPoints[i] != null && drawingPoints[i + 1] != null) {
//         canvas.drawLine(drawingPoints[i].offset, drawingPoints[i + 1].offset,
//             drawingPoints[i].paint);
//       } else if (drawingPoints[i] != null && drawingPoints[i + 1] == null) {
//         offsetsList.clear();
//         offsetsList.add(drawingPoints[i].offset);

//         canvas.drawPoints(
//             PointMode.points, offsetsList, drawingPoints[i].paint);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// class DrawingPoint {
//   Offset offset;
//   Paint paint;

//   DrawingPoint(this.offset, this.paint);
// }


//드로임

// import 'dart:async';
// import 'dart:io';
// import 'dart:ui';

// import 'package:agora_flutter_quickstart/src/utils/heart.dart';
// import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:math' as math;
// import 'package:favorite_button/favorite_button.dart';

// import '../utils/settings.dart';

// class CallPage_helper extends StatefulWidget {
//   /// non-modifiable channel name of the page
//   final String? channelName;
//   const CallPage_helper({Key? key, this.channelName}) : super(key: key);

//   @override
//   _CallPageState createState() => _CallPageState();
// }

// class _CallPageState extends State<CallPage_helper> {
//   final _users = <int>[];
//   final _infoStrings = <String>[];
//   bool muted = false;
//   bool videoOnOff = false;
//   late RtcEngine _engine;
//   int? streamId;
//   late Offset change;
//   bool heart = false;
//   int helper_one = 0;
//   late String uid_check;
//   int count = 1;
//   bool get_uid = true;
//   bool pass_check = true;

//   @override
//   void dispose() {
//     // clear users
//     _users.clear();
//     // destroy sdk
//     _engine.leaveChannel();
//     _engine.destroy();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     // initialize agora sdk
//     initialize();
//   }

//   Future<void> initialize() async {
//     if (APP_ID.isEmpty) {
//       setState(() {
//         _infoStrings.add(
//           'APP_ID missing, please provide your APP_ID in settings.dart',
//         );
//         _infoStrings.add('Agora Engine is not starting');
//       });
//       return;
//     }

//     await _initAgoraRtcEngine();

//     streamId = await _engine.createDataStream(false, false);

//     _addAgoraEventHandlers();
//     await _engine.enableWebSdkInteroperability(true);
//     VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
//     //configuration.dimensions = VideoDimensions(1920, 1080);
//     await _engine.setVideoEncoderConfiguration(configuration);
//     await _engine.joinChannel(null, widget.channelName!, null, 0);
//   }

//   /// Create agora sdk instance and initialize
//   Future<void> _initAgoraRtcEngine() async {
//     _engine = await RtcEngine.create(APP_ID);
//     await _engine.enableVideo();
//     await _engine.setChannelProfile(ChannelProfile.Communication);
//     //만약에 1to1으로 만들려면 LiveBroadcasting이거 대신에 Communication으로 넣으면 일대일이 가능해짐
//     //await _engine.setClientRole(ClientRole.Broadcaster);
//   }

//   /// Add agora event handlers
//   void _addAgoraEventHandlers() {
//     _engine.setEventHandler(RtcEngineEventHandler(
//       error: (code) {
//         setState(() {
//           final info = 'onError: $code';
//           _infoStrings.add(info);
//         });
//       },
//       joinChannelSuccess: (channel, uid, elapsed) {
//         setState(() {
//           final info = 'onJoinChannel: $channel, uid: $uid';
//           _infoStrings.add(info);
//         });
//       },
//       leaveChannel: (stats) {
//         setState(() {
//           _infoStrings.add('onLeaveChannel');
//           _users.clear();
//         });
//       },
//       userJoined: (uid, elapsed) {
//         // helper_one++;
//         // if (helper_one > 1) {
//         //   Navigator.pop(context);
//         // }

//         setState(() {
//           final info = 'userJoined: $uid';
//           _infoStrings.add(info);
//           _users.add(uid);
//         });
//         if (get_uid) {
//           uid_check = uid.toString();
//           get_uid = false;
//         }
//       },
//       userOffline: (uid, elapsed) {
//         setState(() {
//           final info = 'userOffline: $uid';
//           _infoStrings.add(info);
//           _users.remove(uid);
//         });
//       },
//       firstRemoteVideoFrame: (uid, width, height, elapsed) {
//         pass_check = false;
//         setState(() {
//           final info = 'firstRemoteVideo: $uid ${width}x $height';
//           _infoStrings.add(info);
//         });
//       },
//       streamMessage: (_, __, coordinates) {
//         if (coordinates.compareTo('end') == 0) {
//           Navigator.pop(context);
//         } else if (coordinates.compareTo('onoffVideo') == 0) {
//           setState(() {
//             videoOnOff = !videoOnOff;
//           });
//         } else if (coordinates.compareTo('heart') == 0) {
//           popUp();
//         } else if (coordinates.compareTo(uid_check) == 0) {
//           if (pass_check) {
//             Navigator.pop(context);
//           }
//         }
//       },
//       streamMessageError: (_, __, error, ___, ____) {
//         final String info = "here is the error $error";
//         print(info);
//       },
//     ));
//   }

//   /// Helper function to get list of native views
//   List<Widget> _getRenderViews() {
//     print("check po11int 156");

//     final List<StatefulWidget> list = [];
//     //if (widget.role == ClientRole.Broadcaster) {}
//     _users.forEach((int uid) => list.add(
//         RtcRemoteView.SurfaceView(uid: uid, renderMode: VideoRenderMode.FILL)));
//     list.add(RtcLocalView.SurfaceView(renderMode: VideoRenderMode.FILL));

//     return list;
//   }

//   /// Video view wrapper
//   Widget _videoView(view) {
//     return Expanded(child: Container(child: view));
//   }

//   /// Video view row wrapper
//   Widget _expandedVideoRow(List<Widget> views) {
//     final wrappedViews = views.map<Widget>(_videoView).toList();
//     return Expanded(
//       child: Row(
//         children: wrappedViews,
//       ),
//     );
//   }

//   /// Video layout wrapper
//   Widget _viewRows() {
//     final views = _getRenderViews();
//     switch (views.length) {
//       case 1:
//         return Container();
//       case 2:
//         CircularProgressIndicator();
//         return Container(
//             child: Column(
//           children: <Widget>[
//             _expandedVideoRow([views[0]]),
//           ],
//         ));
//       default:
//     }
//     return Container();
//   }

//   /// Toolbar layout
//   Widget _toolbar() {
//     return Container(
//       //if (heart == true) heartPop(),
//       alignment: Alignment.bottomCenter,
//       padding: const EdgeInsets.symmetric(vertical: 48),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           RawMaterialButton(
//             onPressed: () => _onCallEnd(context),
//             child: Icon(
//               Icons.call_end,
//               color: Colors.white,
//               size: 35.0,
//             ),
//             shape: CircleBorder(),
//             elevation: 2.0,
//             fillColor: Colors.redAccent,
//             padding: const EdgeInsets.all(15.0),
//           ),
//           RawMaterialButton(
//             onPressed: _onToggleMute,
//             child: Icon(
//               muted ? Icons.mic_off : Icons.mic,
//               color: muted ? Colors.white : Colors.blueAccent,
//               size: 20.0,
//             ),
//             shape: CircleBorder(),
//             elevation: 2.0,
//             fillColor: muted ? Colors.blueAccent : Colors.white,
//             padding: const EdgeInsets.all(12.0),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
//             child: MaterialButton(
//               minWidth: 0,
//               onPressed: () async {},
//               child: Icon(
//                 Icons.favorite_border,
//                 color: Colors.white,
//                 size: 30.0,
//               ),
//               padding: const EdgeInsets.all(12.0),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   //bool heart = false;
//   final _random = math.Random();
//   late Timer _timer;
//   double height = 0.0;
//   int _numConfetti = 10;
//   var len;
//   bool accepted = false;
//   bool stop = false;

//   void popUp() async {
//     setState(() {
//       heart = true;
//     });

//     _timer = Timer.periodic(Duration(milliseconds: 125), (Timer t) {
//       setState(() {
//         height += _random.nextInt(20);
//       });
//     });

//     Timer(
//         Duration(seconds: 4),
//         () => {
//               _timer.cancel(),
//               setState(() {
//                 heart = false;
//               })
//             });
//   }

//   Widget heartPop() {
//     final size = MediaQuery.of(context).size;
//     final confetti = <Widget>[];
//     for (var i = 0; i < _numConfetti; i++) {
//       final height = _random.nextInt(size.height.floor());
//       final width = 0;
//       confetti.add(HeartAnim(
//         height % 300.0,
//         //width.toDouble(),
//         1,
//       ));
//     }

//     return Container(
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 20),
//         child: Align(
//           alignment: Alignment.bottomRight,
//           child: Container(
//             //height: 0,
//             width: (MediaQuery.of(context).size.width / 2),
//             child: Stack(
//               children: confetti,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   /// Info panel to show logs
//   Widget _panel() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 48),
//       alignment: Alignment.bottomCenter,
//       child: FractionallySizedBox(
//         heightFactor: 0.5,
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 48),
//           child: ListView.builder(
//             reverse: true,
//             itemCount: _infoStrings.length,
//             itemBuilder: (BuildContext context, int index) {
//               if (_infoStrings.isEmpty) {
//                 return Text(
//                     "null"); // return type can't be null, a widget was required
//               }
//               return Padding(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 3,
//                   horizontal: 10,
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Flexible(
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 2,
//                           horizontal: 5,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.yellowAccent,
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                         child: Text(
//                           _infoStrings[index],
//                           style: TextStyle(color: Colors.blueGrey),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   void _onCallEnd(BuildContext context) {
//     _engine.sendStreamMessage(streamId!, "end");
//     Navigator.pop(context);
//   }

//   void _onToggleMute() {
//     setState(() {
//       muted = !muted;
//     });
//     _engine.muteLocalAudioStream(muted);
//   }

//   Widget _turnoffcamera() {
//     return Container(
//       decoration: BoxDecoration(
//         image: DecorationImage(
//           image: NetworkImage("https://i.ibb.co/nsVhXLq/black-background.jpg"),
//           fit: BoxFit.cover,
//           colorFilter: ColorFilter.mode(Colors.black, BlendMode.dstATop),
//         ),
//       ),
//       child: Center(
//         child: Text(
//           "음성으로 소통하세요",
//           style: TextStyle(color: Colors.white70),
//         ),
//       ),
//     );
//   }

//   //drawing
//   Color selectedColor = Colors.purple;
//   double strokeWidth = 5;
//   List<DrawingPoint> drawingPoints = [];
//   List<Color> colors = [
//     Colors.pink,
//     Colors.red,
//     Colors.black,
//     Colors.yellow,
//     Colors.amberAccent,
//     Colors.purple,
//     Colors.green,
//   ];
//   late String getdetails;
//   late double nomalizationDx;
//   late double nomalizationDy;

//   @override
//   Widget drawing(BuildContext context) {
//     return Container(
//       child: Stack(
//         children: [
//           GestureDetector(
//             onPanStart: (details) {
//               getdetails = "erase";
//               _engine.sendStreamMessage(streamId!, getdetails);
//               setState(() {
//                 drawingPoints = [];
//                 drawingPoints.add(drawingPoints[-1]);
//                 drawingPoints.add(
//                   DrawingPoint(
//                     details.localPosition,
//                     Paint()
//                       ..color = selectedColor
//                       ..isAntiAlias = true
//                       ..strokeWidth = strokeWidth
//                       ..strokeCap = StrokeCap.round,
//                   ),
//                 );
//               });
//             },
//             onPanUpdate: (details) {
//               setState(() {
//                 drawingPoints.add(
//                   DrawingPoint(
//                     details.localPosition,
//                     Paint()
//                       ..color = selectedColor
//                       ..isAntiAlias = true
//                       ..strokeWidth = strokeWidth
//                       ..strokeCap = StrokeCap.round,
//                   ),
//                 );
//               });
//               nomalizationDx =
//                   details.localPosition.dx / MediaQuery.of(context).size.width;
//               nomalizationDy =
//                   details.localPosition.dy / MediaQuery.of(context).size.height;
//               getdetails = nomalizationDx.toString() +
//                   " " +
//                   nomalizationDy.toString() +
//                   "a";

//               _engine.sendStreamMessage(streamId!, getdetails);
//             },
//             onPanEnd: (details) {
//               setState(() {
//                 // drawingPoints = [];
//                 // drawingPoints.add(drawingPoints[-1]);
//               });
//             },
//             child: CustomPaint(
//               painter: _DrawingPainter(drawingPoints),
//               child: Container(
//                 height: MediaQuery.of(context).size.height,
//                 width: MediaQuery.of(context).size.width,
//               ),
//             ),
//           ),
//           Positioned(
//             top: 40,
//             right: 30,
//             child: Row(
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     setState(() => drawingPoints = []);
//                     _engine.sendStreamMessage(streamId!, "erase");
//                   },
//                   icon: Icon(Icons.clear),
//                   label: Text("Clear Board"),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildColorChose(Color color) {
//     bool isSelected = selectedColor == color;
//     return GestureDetector(
//       onTap: () => setState(() => selectedColor = color),
//       child: Container(
//         height: isSelected ? 47 : 40,
//         width: isSelected ? 47 : 40,
//         decoration: BoxDecoration(
//           color: color,
//           shape: BoxShape.circle,
//           border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.black,
//         body: videoOnOff
//             ? Center(
//                 child: Stack(
//                   children: <Widget>[
//                     _turnoffcamera(),
//                     _panel(),
//                     _toolbar(),
//                   ],
//                 ),
//               )
//             : Container(
//                 child: Center(
//                   child: Stack(
//                     children: <Widget>[
//                       _viewRows(),
//                       if (heart == true) heartPop(),
//                       _panel(),
//                       drawing(context),
//                       _toolbar(),
//                     ],
//                   ),
//                 ),
//               ));
//   }
// }

// class _DrawingPainter extends CustomPainter {
//   final List<DrawingPoint> drawingPoints;

//   _DrawingPainter(this.drawingPoints);

//   List<Offset> offsetsList = [];

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (int i = 0; i < drawingPoints.length; i++) {
//       if (drawingPoints[i] != null && drawingPoints[i + 1] != null) {
//         canvas.drawLine(drawingPoints[i].offset, drawingPoints[i + 1].offset,
//             drawingPoints[i].paint);
//       } else if (drawingPoints[i] != null && drawingPoints[i + 1] == null) {
//         offsetsList.clear();
//         offsetsList.add(drawingPoints[i].offset);

//         canvas.drawPoints(
//             PointMode.points, offsetsList, drawingPoints[i].paint);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// class DrawingPoint {
//   Offset offset;
//   Paint paint;

//   DrawingPoint(this.offset, this.paint);
// }
