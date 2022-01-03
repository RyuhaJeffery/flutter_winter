import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_tutorial/signaling.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Signaling signaling = Signaling(); //
  RTCVideoRenderer _localRenderer =
      RTCVideoRenderer(); //flutter webrtc 패키지에서 가져옴
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId; //room id
  TextEditingController textEditingController =
      TextEditingController(text: ''); //room id 넣을 때 사용

  bool local = true;
  bool turnCamera = false;
  bool createRoom = true;
  bool joinRoom = true;
  bool hangupCall = false;

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    //
    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to Flutter Explained - WebRTC"),
      ),
      body: Column(
        children: [
          SizedBox(height: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 8,
              ),
              turnCamera
                  ? Container()
                  : ElevatedButton(
                      onPressed: () async {
                        await signaling.openUserMedia(
                            _localRenderer, _remoteRenderer);
                        roomId = await signaling.createRoom(_remoteRenderer);
                        print(roomId);
                        textEditingController.text = roomId!;
                        setState(() {
                          turnCamera = true;
                          local = true;
                        });
                      },
                      child: Text("Create room"),
                    ),
              SizedBox(
                width: 8,
              ),
              turnCamera
                  ? Container()
                  : ElevatedButton(
                      onPressed: () async {
                        await signaling.openUserMedia(
                            _localRenderer, _remoteRenderer);
                        await signaling.joinRoom(
                          textEditingController.text,
                          _remoteRenderer,
                        );
                        setState(() {
                          turnCamera = true;
                          local = false;
                        });
                      },
                      child: Text("Join room"),
                    ),
              SizedBox(
                width: 8,
              ),
              turnCamera
                  ? ElevatedButton(
                      onPressed: () {
                        setState(() {
                          turnCamera = false;
                        });

                        // Navigator.pushAndRemoveUntil(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => MyHomePage()),
                        //     (route) => false);
                        signaling.hangUp(_localRenderer);
                      },
                      child: Text("Hangup"),
                    )
                  : Container(),
            ],
          ),
          SizedBox(height: 8),
          //video 가져오는 부분
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: turnCamera
                        ?
                        // local
                        // ?
                        RTCVideoView(
                            local ? _localRenderer : _remoteRenderer,
                          )
                        // : RTCVideoView(_remoteRenderer),
                        : Container(),
                  ),
                  // Expanded(
                  //   child: turnCamera
                  //       ?
                  //       // local
                  //       // ?
                  //       RTCVideoView(
                  //           local ? _remoteRenderer : _localRenderer,
                  //         )
                  //       // : RTCVideoView(_remoteRenderer),
                  //       : Container(),
                  // ),
                  // Expanded(child: RTCVideoView(_remoteRenderer)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Join the following Room: "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 8)
        ],
      ),
    );
  }
}
