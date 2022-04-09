import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:netshield/Authentication/screens/email_verification_screen.dart';
import 'dart:convert';

import 'package:netshield/Secure/secure_storage.dart';
import 'package:netshield/home_screen.dart';
import 'package:provider/provider.dart';

class AuthProvider with ChangeNotifier {
  SecureLs secureLs = new SecureLs();

  Future<Map> refreshToken() async {
    String refresh_token = '';
    await secureLs.fetchDataFromLs('refresh_token').then((value) {
      value = refresh_token;
    });
    var headers = {
      'Authorization':
          'Basic MDdhZDQ4ZmItY2U1OS00YjBhLWFkZGMtYzMyMmNlNzFlZWMwOjY2NzliNzg1NzA4NTU4MDdhYmNiMmQwNTg1YzY4NjM3NDQyOWI2MDFiNWYyYjUyMzY1NGIxMzkxOTlhYjZhMTM=',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://api.netshield.ir/public/index.php/authorization/token'));
    request.body = json.encode(
        {"grant_type": "refresh_token", "refresh_token": refresh_token});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    // print(await response.stream.bytesToString());

    if (response.statusCode == 200) {
      String raw_result = await response.stream.bytesToString();
      print('refreshing token ::::$raw_result');
      Map auth_data = json.decode(raw_result);
      Map refined_data = {
        'token': auth_data['access_token'],
        'refresh_token': auth_data['refresh_token'],
        'expires_in': auth_data['expires_in']
      };
      await secureLs.writeInitialLs(refined_data).then((value) async {
        await secureLs.getLsData();
        return refined_data;
      });
    } else {
      print(response.reasonPhrase);
      ///////////////////log out user
    }
    return {};
  }

  Future<void> loginUser(
      BuildContext context, String userName, String password) async {
    print('userName=$userName----password=$password');
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('https://api.netshield.ir/public/consumer/login'));
    request.body = json.encode({"username": userName, "password": password});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String raw_userData = await response.stream.bytesToString();
      Map userData = json.decode(raw_userData);
      _auth_success(context, userData);
    } else if (response.statusCode == 400) {
      String raw_userData = await response.stream.bytesToString();
      Map userData = json.decode(raw_userData);
      userData.forEach((key, value) {
        print('key===$key----value==$value');
      });
      if (userData['message'] == "Invalid name or password") {
        print('Invalid-----Pass');
        getAccountStatus(userName)
            .then((value) => {
                  if (value['status'] == 0)
                    {
                      send_mail(userName, 'Activation Netshield',
                              'https://api.netshield.ir/public/app/backend/user/activate/${value['token']}')
                          .then((value) => print('Mail successfully sent!!!'))
                    }
                })
            .then((value) {
          Navigator.of(context).pushReplacementNamed(
              EmailVerificationScreen.routeName,
              arguments: {'email': userName, 'password': password});
        });
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> send_mail(String email, String subject, String body) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://api.netshield.ir/public/app/backend/mailer/send/data'));
    request.body = json.encode({
      "subject": subject,
      "body": body,
      "to": email,
      "from": "hello@netshield.ir"
    });

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> _auth_success(BuildContext context, Map userData) async {
    secureLs.writeInitialLs(userData).then((value) {
      print('Successful write in LS');
      Navigator.of(context).pushReplacementNamed(MyHomePage.routeName);
    });
  }

  Future<String> signUpUser(Map userData) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('https://api.netshield.ir/public/consumer/register'));
    request.body = json.encode({
      "name": userData['name'],
      "email": userData['email'],
      "password": userData['password']
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      return 'success';
    } else if (response.statusCode == 400) {
      return 'User name already exists';
    } else {
      print(response.reasonPhrase);
      return 'SomeThing Went Wrong';
    }
  }

  Future<Map> getAccountStatus(String user_email) async {
    print('Checking Status for $user_email');
    var headers = {
      'Content-Type': 'application/json',
    };
    Map resp_user_status = {};
    var request = http.Request(
        'GET',
        Uri.parse(
            'http://api.netshield.ir/public/app/backend/user/status/$user_email'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String raw_userStatus = await response.stream.bytesToString();
      Map userStatus = json.decode(raw_userStatus);
      return userStatus;
    } else if (response.statusCode == 404) {
      print('wrong user name cause error 404!!!');
      return {'error': 'wrong username'};
    } else {
      print(response.reasonPhrase);
      return {'error': response.reasonPhrase};
    }
  }

  Future<void> getAccountData(String token) async {
    print('getting account data $token');
    Map userAccountData = {};
    var headers = {'Authorization': 'Bearer $token'};
    var request = http.Request(
        'GET', Uri.parse('https://api.netshield.ir/public/consumer/account'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String raw_resp_data = await response.stream.bytesToString();
      print(raw_resp_data);
      userAccountData = json.decode(raw_resp_data);
      if (userAccountData['attributes'] == null) {
        Map userData = {};
        secureLs.getLsData().then((value) {
          value = userData;
        });
        await initial_config_server(
                token, userAccountData['id'], userAccountData['name'])
            .then((value) async => await putAccountData(userData, token));
      } else {
        await secureLs.writeSingleKeyLs(
            'ovpn-url', userAccountData['attributes']['ovpn-url']);
        // print(userAccountData['attributes']['ovpn-url'].toString());
      }
    } else if (response.statusCode == 401) {
      await refreshToken()
          .then((value) async => await getAccountData(value['token']));
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<String> getServerConfig(String id, String token) async {
    print('Getting server config for id $id');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.Request('GET',
        Uri.parse('https://api.netshield.ir/public/app/backed/conf/get/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print('Getting server config status code ${response.statusCode}');

    if (response.statusCode == 200) {
      String config = await response.stream.bytesToString();
      print(config);
      await secureLs.writeSingleKeyLs('ovpn-config', config);
      return config;
    } else if (response.statusCode == 401) {
      refreshToken()
          .then((value) async => await getServerConfig(id, value['token']));
    } else {
      print(response.reasonPhrase);
      return response.reasonPhrase.toString();
    }
    return '';
  }

  Future<void> initial_config_server(
      String token, String user_id, String user_name) async {
    var headers = {'Authorization': 'Bearer $token'};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://api.netshield.ir/public/app/backend/config/init/$user_id/$user_name'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      getAccountData(token);
    } else if (response.statusCode == 401) {
      refreshToken().then(
          (value) => initial_config_server(value['token'], user_id, user_name));
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> putAccountData(Map userData, String token) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String _deviceType = '';
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _deviceType =
          '${androidInfo.model.toString()}---${androidInfo.androidId.toString()}';
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _deviceType = iosInfo.model.toString();
    }

    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'PUT', Uri.parse('https://api.netshield.ir/public/consumer/account'));
    request.body = json.encode({
      "email": "spotify.khashi1998@gmail.com",
      "attributes": {
        "first_name": userData['first_name'],
        "last_name": userData['last_name'],
        "account_exp": DateTime.now()
            .add(Duration(days: 30))
            .millisecondsSinceEpoch
            .toString(),
        "device-info": _deviceType,
        "trial": "eligible"
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else if (response.statusCode == 401) {
      refreshToken().then(
          (value) async => await putAccountData(userData, value['token']));
    } else {
      print(response.reasonPhrase);
    }
  }
}
