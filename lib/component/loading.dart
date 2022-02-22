import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final Color backgroundColor;
  const Loading({Key? key, this.backgroundColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: CircularProgressIndicator(
          backgroundColor: backgroundColor,
          valueColor:
              AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
          strokeWidth: 2,
        ),
      ),
    );
  }
}
