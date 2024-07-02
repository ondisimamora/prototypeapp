import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:prototypeapp/screens/resultScreen.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  int inProgress = 0;
  Future<String> _convertImageToBase64(String path) async {
    setState(() {
      inProgress = 1;
    });
      File imageFile = File(path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      return base64Image;
    }
  
  Future<String> _getAccessToken() async {
    try {
      Dio dio = Dio();
      Response response = await dio.post(
        "https://get-jwt-token-vtd66tbjxq-et.a.run.app/getToken",
        options: Options(
          headers: {'access_token': "test"},
        ),
        data: {
          'username': 'test',
          'password': 'test1'
        },
      );
      print(response);
      if (response.statusCode == 200) {
        return response.data['access_token'];
      } else {
        throw Exception('Failed to get access token. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting access token: $e');
    }
  }

   Future<void> _sendImageToServer(String base64Image, String accessToken) async {
    try {
      Dio dio = Dio();
      Response response = await dio.post(
        "https://verify-image2-vtd66tbjxq-et.a.run.app/verify",
        // "https://verify-image-vtd66tbjxq-et.a.run.app/verify",
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        data: {
          'image_base64': base64Image,
          'sequence': 0
        },
      );
      if (response.statusCode == 200) {
        setState(() {
      inProgress = 0;
    });
        print('Response: ${response.data}');
        String result = response.data['result'];
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ResultScreen(resultFlag: result,)));
        
      } else {
        setState(() {
      inProgress = 0;
    });
        print('Failed to send image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending image: $e');
      Navigator.push(context, MaterialPageRoute(builder: (context)=> ResultScreen(resultFlag: "fake",)));
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: const Text('Review Image')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, children: [
          Image.file(File(widget.picture.path), fit: BoxFit.cover, width: 250),
          const SizedBox(height: 24),
          MaterialButton(onPressed: inProgress == 1? null:() async {
                String base64Image = await _convertImageToBase64(widget.picture.path);
                String accessToken = await _getAccessToken();
                await _sendImageToServer(base64Image, accessToken);
          }, child: Padding(
            padding: const EdgeInsets.fromLTRB(80, 2, 80, 2),
            child: inProgress==1? SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(color: Colors.white,)):
              Text("VERIFY", style: TextStyle(color: Colors.white)),
          ), disabledColor: Colors.grey,color: Colors.green,)
          
        ]),
      ),
    );
  }
}