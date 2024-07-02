// import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

// class HomePage extends StatefulWidget {
  
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late List<CameraDescription> cameras;
//   late CameraController controller;
//   bool _isInited = false;
//   String _url='';

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       cameras = await availableCameras();
//       print("---------------");
//       print(cameras);
//       print("---------------");
//       // setState(() {});
//       controller = CameraController(cameras[0], ResolutionPreset.medium);
//       controller.initialize().then((value) => {
//             setState(() {
//               _isInited = true;
//             })
//           });
//     });
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     Future takePicture() async {
//   if (!controller.value.isInitialized) {return null;}
//   if (controller.value.isTakingPicture) {return null;}
//   try {
//     await controller.setFlashMode(FlashMode.always);
//     XFile picture = await controller.takePicture();
//     // Navigator.push(context, MaterialPageRoute(
//     //                builder: (context) => PreviewPage(
//     //                      picture: picture,
//     //                    )));
//   } on CameraException catch (e) {
//     debugPrint('Error occured while taking picture: $e');
//     return null;
//   }
// }
//     return Scaffold(
//       appBar: AppBar(),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.camera),
//         onPressed: () async {
//           final path = join(
//               (await getTemporaryDirectory()).path, '${DateTime.now()}.png');
//           await controller.takePicture().then((res) => {
//                 setState(() {
//                   _url = path;
//                 })
//               });
//         },
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       body: Container(
//         height: double.infinity,
//         width: double.infinity,
//         // child: _isInited ? CameraPreview(controller) : Container()
//         child: Column(
//           children: [
//             Expanded(
//               child: _isInited
//                   ? AspectRatio(
//                       aspectRatio: controller.value.aspectRatio,
//                       child: CameraPreview(controller),
//                     )
//                   : Container(),
//             ),
//             Container(
//               height: 152,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     height: 120,
//                     width: 120,
//                     // ignore: unnecessary_null_comparison
//                     child: _url != null
//                         ? Image.file(
//                             File(_url),
//                             height: 120,
//                             width: 120,
//                           )
//                         : Container(),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }