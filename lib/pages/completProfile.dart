import 'package:flutter/material.dart';
import '../../data/color.dart';

class CompletProfile extends StatefulWidget {
  const CompletProfile({super.key});

  @override
  State<CompletProfile> createState() => _CompletProfileState();
}

class _CompletProfileState extends State<CompletProfile> {

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      color: mzhColorThem1[0],
    );
  }
}
