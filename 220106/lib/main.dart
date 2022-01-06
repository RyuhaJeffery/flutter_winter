import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme_pratice/theme/text_style.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //1. Text
  buildTextButton() {
    return TextButton(
      onPressed: () {},
      child: Text(
        '텍스트버튼 트스트',
        style: AppTextStyle.koHeadline5,
      ),

      // style: ButtonStyle(
      //   backgroundColor: MaterialStateProperty.resolveWith(
      //     (states) {
      //       if (states.contains(MaterialState.disabled)) {
      //         return Colors.grey;
      //       } else if (states.contains(MaterialState.dragged)) {
      //         return Colors.purple;
      //       } else if (states.contains(MaterialState.hovered)) {
      //         return Colors.amber;
      //       } else if (states.contains(MaterialState.pressed)) {
      //         return Colors.cyan;
      //       } else if (states.contains(MaterialState.values)) {
      //         return Colors.redAccent;
      //       }
      //     },
      //   ),
      // ),
      // style: TextButton.styleFrom(
      //   primary: Colors.red,
      //   // onSurface: Colors.green, //onPressed가 비활성화 되어 있을 때 보여지는 color
      //   backgroundColor: Colors.yellow,
      //   shadowColor: Colors.purple,
      //   elevation: 10.0,
      //   padding: EdgeInsets.all(15),
      //   textStyle: TextStyle(
      //     fontWeight: FontWeight.bold,
      //   ),
      // minimumSize: Size(300, 200),
      // ),
    );
  }

  //2. Elevated Button
  buildElevatedButton() {
    return ElevatedButton(
      onPressed: () {},
      child: Text('Elevated Button'),
      // style: ElevatedButton.styleFrom(
      //   primary: Colors.red, //이게 바로 background color
      //   onPrimary: Colors.purple, //primary위에 글씨 색깔
      //   // onSurface: Colors.green, //onPressed가 비활성화 되어 있을 때 보여지는 color
      //   shadowColor: Colors.purple,
      //   elevation: 10.0,
      //   padding: EdgeInsets.all(15),
      //   textStyle: TextStyle(
      //     fontWeight: FontWeight.bold,
      //   ),
      // minimumSize: Size(300, 200),
      // ),
    );
  }

  //3. Outlined Button
  buildOutlinedButton() {
    return OutlinedButton(
      onPressed: () {},
      child: Text('Outlined Button'),
      // style: OutlinedButton.styleFrom(
      //   primary: Colors.red,
      //   backgroundColor: Colors.amber,
      //   shadowColor: Colors.purple,
      //   elevation: 10.0,
      //   padding: EdgeInsets.all(15),
      //   textStyle: TextStyle(
      //     fontWeight: FontWeight.bold,
      //   ),
      //   // minimumSize: Size(300, 200),
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Button Theme"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTextButton(),
            SizedBox(height: 10),
            buildElevatedButton(),
            SizedBox(height: 10),
            buildOutlinedButton(),
          ],
        ),
      ),
    );
  }
}
