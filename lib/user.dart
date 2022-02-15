import 'package:flutter/material.dart';

class UserCommponent extends StatefulWidget {
  const UserCommponent({Key? key}) : super(key: key);

  @override
  _UserCommponentState createState() => _UserCommponentState();
}

class _UserCommponentState extends State<UserCommponent> {
  @override
  Widget build(BuildContext context) {
    return const Text('user');
  }
}
