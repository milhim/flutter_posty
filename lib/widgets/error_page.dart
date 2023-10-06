import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:posty/models/shared_class.dart';

class ErrorPage extends StatelessWidget {
  final String errorMessage;
  final Function()? callBack;

  const ErrorPage({Key? key, this.callBack, required this.errorMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.error,
              size: MediaQuery.of(context).size.height / 4, color: Colors.red),
          Text(
            errorMessage,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Padding(padding: EdgeInsets.only(bottom: 15)),
          ElevatedButton(
            onPressed: callBack,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
