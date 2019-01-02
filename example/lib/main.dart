import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:clipboard_manager/clipboard_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool result = false;
  String _pastedContent = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Builder(
          builder: (context) {
            return Center(
              child: Column(
                children: <Widget>[
                  Spacer(flex: 1,),
                  Text('Your coupon is xYZ1234AB'),
                  RaisedButton(
                    child: Text('Copy to Clipboard'),
                    onPressed: () {
                      _copyTextToClipboard(context);
                    },
                  ),
                  RaisedButton(
                    child: Text('Copy Image to Clipboard'),
                    onPressed: () {
                      _copyImageToClipboard(context);
                    },
                  ),
                  Spacer(flex: 1,),
                  Text(_pastedContent),
                  RaisedButton(
                    child: Text('Paste from Clipboard'),
                    onPressed: () {
                      _pasteFromClipboard();
                    },
                  ),
                  Spacer(flex: 1,),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _pasteFromClipboard() {
    ClipboardManager.pasteFromClipBoard().then((result) {
      setState(() {
        _pastedContent = result["contentType"];
      });
    });
  }

  void _copyTextToClipboard(BuildContext context) {
    ClipboardManager.copyToClipBoard(
            "xYZ1234AB", "text/plain")
        .then((result) {
      final snackBar = SnackBar(
        content: Text('Copied to Clipboard'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {},
        ),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

  void _copyImageToClipboard(BuildContext context) async {
    ByteData byteData = await rootBundle.load('images/sample.jpg');
    ClipboardManager.copyToClipBoard(byteData.buffer.asUint8List(), "image/jpeg").then((result) {
      final snackBar = SnackBar(
        content: Text('Copied sample image to Clipboard'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {},
        ),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    });
  }
}
