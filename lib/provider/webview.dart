import 'package:flutter/cupertino.dart';

class WebViewProvider with ChangeNotifier {
  String currentUrl = "https://mymodus.ru/";

  changeUrl({String? oldUrl}) {
    currentUrl = oldUrl!;
    notifyListeners();
  }
}
