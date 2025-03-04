import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  TextEditingController? controller;
  bool? ispassword = false;
  String? hint;

  TextInput({this.controller, this.ispassword, this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      alignment: Alignment.topRight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(7)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 5,
            color: Colors.black.withOpacity(1),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: ispassword!,
        style: TextStyle(fontSize: 17 , color:Colors.black),
        decoration: InputDecoration(
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(fontSize: 17 , color:Colors.grey),
        ),
      ),
    );
  }
}
