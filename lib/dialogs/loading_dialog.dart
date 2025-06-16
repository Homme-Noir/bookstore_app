import 'package:flutter/material.dart';
import '../widgets/loading_widget.dart';

class LoadingAlertDialog extends StatelessWidget {
  final String message;
  
  const LoadingAlertDialog({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const LoadingWidget(),
          const SizedBox(height: 10),
          Text(message),
        ],
      ),
    );
  }
}
