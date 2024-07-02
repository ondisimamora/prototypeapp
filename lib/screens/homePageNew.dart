import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:prototypeapp/screens/CameraPage.dart';

class HomeNew extends StatefulWidget {
  const HomeNew({super.key});

  @override
  State<HomeNew> createState() => _HomeNewState();
}

class _HomeNewState extends State<HomeNew> {
  @override
  void initState() {
    checkCamera();
    super.initState();
  }

  checkCamera()async{
    await availableCameras().then((value) => Navigator.push(context,
                MaterialPageRoute(builder: (_) => CameraPage(cameras: value))));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Home Page")),
      body: SafeArea(
        child: Center(
            child:
            CircularProgressIndicator(color: Colors.black)
        //     ElevatedButton(
        //   onPressed: () async {
        //     await availableCameras().then((value) => Navigator.push(context,
        //         MaterialPageRoute(builder: (_) => CameraPage(cameras: value))));
        //   },
        //   child: const Text("Take a Picture"),
        // )
        ),
      ),
    );
  }
}