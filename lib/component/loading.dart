import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final Color backgroundColor;
  const Loading({Key? key, this.backgroundColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: const Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
          valueColor: AlwaysStoppedAnimation(Colors.blue),
          strokeWidth: 2,
        ),
      ),
    );
  }
}
