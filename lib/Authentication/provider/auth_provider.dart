import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:netshield/Secure/secure_storage.dart';
import 'package:netshield/home_screen.dart';

class AuthProvider with ChangeNotifier {
  Future<void> loginUser(BuildContext context,String userName, String password) async {
    // print('userName=$userName----password=$password');
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('https://api.netshield.ir/public/consumer/login'));
    request.body = json.encode({"username": userName, "password": password});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String raw_userData = await response.stream.bytesToString();
      Map userData = json.decode(raw_userData);
      _auth_success(context,userData);
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> _auth_success(BuildContext context,Map userData) async {
    SecureLs secureLs = new SecureLs();
    secureLs.writeInitialLs(userData).then((value) {
      print('Successful write in LS');
      Navigator.of(context).pushReplacementNamed(MyHomePage.routeName);
    });
  }

  Future<void> signUpUser(Map userData) async {}
}
