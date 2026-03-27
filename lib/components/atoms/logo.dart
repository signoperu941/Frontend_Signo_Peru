import 'package:flutter/material.dart';

class Logo extends StatelessWidget{
  final String location;
  final double width;
  final double height;
  final Color color;
  const Logo({super.key, required this.width, required this.color, required this.location, required this.height});

  @override
  Widget build(BuildContext context) {
      return Image.asset(location, width: width, height:height, color: color);
  }
  
}