import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:netshield/home_screen.dart';

class SecureLs {
  final storage = new FlutterSecureStorage();
  final options = IOSOptions(accessibility: IOSAccessibility.first_unlock);

  late Map<String, String> allValues;

  Future<Map> getLsData() async {
    return allValues = await storage.readAll(iOptions: options);
  }

  Future<void> writeInitialLs(Map userData) async {
    await getLsData();
    if (allValues.isEmpty) {
      userData.forEach((key, value) async {
        await storage.write(key: key.toString(), value: value.toString());
      });
    }
  }

  Future<void> writeSingleKeyLs(String key, String value) async {
    await getLsData();
    await storage.write(key: key.toString(), value: value.toString());
  }

  Future<String> fetchDataFromLs(String key) async {
    await getLsData();
    if (allValues.isNotEmpty) {
      return await storage.read(key: key, iOptions: options).toString();
    }
    return '';
  }

  isUserLoggedIn(BuildContext context) async {
    await getLsData().then((value) {
      if (value['token'] != null) {
        Navigator.of(context).pushReplacementNamed(MyHomePage.routeName);
      }
    });
  }

  remove_a_key(String key) async {
    await storage.delete(key: key);
  }
}
