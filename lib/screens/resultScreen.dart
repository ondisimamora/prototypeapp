// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ResultScreen extends StatefulWidget {
  final String resultFlag;
  const ResultScreen({super.key, required this.resultFlag});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top:30,
            left:20,
            child: BackButton()),

          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            
            child: widget.resultFlag=='genuine'? 
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon(FontAwesomeIcons.circleCheck, color: Colors.green, size:65),
                Icon(Icons.check, color: Colors.green, size:65),
                SizedBox(height: 10),
                Text("Product is Genuine", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              ],
            ):
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon(FontAwesomeIcons.circleQuestion, color:Colors.yellow, size: 65),
                Icon(Icons.warning, color:Colors.yellow, size: 65),
                SizedBox(height: 10),
                Text("Product is Unverified", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                
              ],
            ),
          )
        ],
      ),
    );
  }
}