import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? const CupertinoActivityIndicator(color: Color.fromRGBO(0, 79, 229, 1))
        : const CircularProgressIndicator(color: Color.fromRGBO(0, 79, 229, 1));
  }
}
