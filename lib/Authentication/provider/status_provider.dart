import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:netshield/Secure/secure_storage.dart';
import 'package:http/http.dart' as http;

class StatusProvider with ChangeNotifier {
  String localIpaddr = '10.8.0.16';

  Future<Map> getUserStatusCounter(String token) async {
    if (localIpaddr == '') {
      final interfaces = await NetworkInterface.list(
          type: InternetAddressType.IPv4, includeLinkLocal: true);

      try {
        // Try VPN connection first
        NetworkInterface vpnInterface =
            interfaces.firstWhere((element) => element.name == "tun0");
        localIpaddr = vpnInterface.addresses.first.address;
      } on StateError {
        // Try wlan connection next
        try {
          NetworkInterface interface =
              interfaces.firstWhere((element) => element.name == "wlan0");
          localIpaddr = interface.addresses.first.address;
        } catch (ex) {
          // Try any other connection next
          try {
            NetworkInterface interface = interfaces.firstWhere((element) =>
                !(element.name == "tun0" || element.name == "wlan0"));
            localIpaddr = interface.addresses.first.address;
          } catch (ex) {}
        }
      }
    }
    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://api.netshield.ir/public/engine/query/data/blocked/get'));
    request.body = json.encode({"client": localIpaddr});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    var requestdnsData = http.Request(
        'POST',
        Uri.parse(
            'https://api.netshield.ir/public/engine/query/data/cached/get'));
    requestdnsData.body = json.encode({"client": localIpaddr});
    requestdnsData.headers.addAll(headers);

    http.StreamedResponse dnsDataResponse = await requestdnsData.send();

    if (response.statusCode == 200 && dnsDataResponse.statusCode == 200) {
      String resp_data = await response.stream.bytesToString();
      String dnsData_resp_data = await dnsDataResponse.stream.bytesToString();
      Map resp_data_map = {
        "blockedStatus": json.decode(resp_data),
        "dnsStatus": json.decode(dnsData_resp_data)
      };

      // resp_data_map.forEach(
      //   (key, value) {
      //     print('key===$key----value===$value');
      //   },
      // );

      // print(
      //     'total blocked Ads Are :::: ${resp_data_map["totalResults"].toString()}');

      notifyListeners();
      return resp_data_map;
    } else {
      print(response.reasonPhrase);
      return {'error': response.reasonPhrase};
    }
  }
}
