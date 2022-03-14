// @dart=2.9

import 'dart:async';
import 'dart:io';

import 'package:bottom_drawer/bottom_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netshield/theme.dart';
import 'package:netshield/widgets/colorized_text.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:rolling_switch/rolling_switch.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BottomDrawerController controller = BottomDrawerController();
  bool _connectionStatus = false;
  bool isInit = true;
  OpenVPN openvpn;
  dynamic status;
  dynamic stage;
  String serverCert = '';

  @override
  void initState() {
    super.initState();
    loadAsset();
    openvpn = OpenVPN(
        onVpnStatusChanged: _onVpnStatusChanged,
        onVpnStageChanged: _onVpnStageChanged);
    openvpn.initialize(
        groupIdentifier: "ir.netshield.app",

        ///Example 'group.com.laskarmedia.vpn'
        providerBundleIdentifier: "ir.netshield.app.network",

        ///Example 'id.laskarmedia.openvpnFlutterExample.VPNExtension'
        localizedDescription: "NetShield"

        ///Example 'Laskarmedia VPN'
        );
  }

  Future<String> loadAsset() async {
    String config = await rootBundle.loadString('assets/vpn_config.txt');
    serverCert = config;
    print(config);
    return config;
  }

  void _onVpnStatusChanged(VpnStatus vpnStatus) {
    setState(() {
      this.status = vpnStatus;
    });
  }

  dynamic _onVpnStageChanged(VPNStage stage, String status) {
    setState(() {
      this.stage = stage;
      print(status.toString());
    });
  }

  _startVpn() async {
    await loadAsset();
    openvpn.connect(serverCert, 'netshield',bypassPackages: [], certIsRequired: true);
  }

  _stopVpn() {
    openvpn.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final appBar = AppBar(
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.black,
                size: 40,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        brightness: Brightness.light);
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar,
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: mediaQuery.size.height * .08,
                  ),
                  ColorizedText(),
                  SizedBox(
                    height: mediaQuery.size.height * .02,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: Material(
                      elevation: 20,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      child: RollingSwitch.widget(
                        initialState: _connectionStatus,
                        width: mediaQuery.size.width / 2,
                        height: (mediaQuery.size.height -
                                appBar.preferredSize.height -
                                mediaQuery.padding.top) /
                            9,
                        innerSize: (mediaQuery.size.height -
                                appBar.preferredSize.height -
                                mediaQuery.padding.top) /
                            9.9,
                        onChanged: (bool state) {
                          if (state) {
                            _startVpn();
                          } else {
                            _stopVpn();
                          }
                        },
                        rollingInfoRight: RollingWidgetInfo(
                          backgroundColor: Color(0xff9CE883),
                          icon: Image.asset(
                            "assets/image/mLogo_active.png",
                          ),
                          //  text: Text('Flutter')
                        ),
                        rollingInfoLeft: RollingWidgetInfo(
                            icon: Image.asset(
                              "assets/image/mLogo_deactive.png",
                            ),
                            backgroundColor: Color(0xffE6F4F1)
                            // text: Text('Stacked'),
                            ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: mediaQuery.size.width / 1.7,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 30, bottom: 30),
                          child: Text(
                            'status===$status---stage===$stage',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Ubuntu',
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          _connectionStatus
                              ? 'you will never be bothered again by ads'
                              : 'you are going to see ads because your not connected',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Ubuntu', fontSize: 18),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            _buildBottomDrawer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomDrawer(BuildContext context) {
    return BottomDrawer(
      header: _buildBottomDrawerHead(context),
      body: _buildBottomDrawerBody(context),
      headerHeight: _headerHeight,
      drawerHeight: _bodyHeight,
      color: Colors.lightBlue,
      controller: _controller,
    );
  }

  Widget _buildBottomDrawerHead(BuildContext context) {
    return Container(
      height: _headerHeight,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 10.0,
              right: 10.0,
              top: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildButtons('', 1, 2),
            ),
          ),
          Spacer(),
          Divider(
            height: 1.0,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDrawerBody(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _bodyHeight,
      child: SingleChildScrollView(
        child: Column(
          children: _buildButtons('Body', 1, 25),
        ),
      ),
    );
  }

  List<Widget> _buildButtons(String prefix, int start, int end) {
    List<Widget> buttons = [];
    for (int i = start; i <= end; i++)
      buttons.add(TextButton(
        child: Text(
          '$prefix Button $i',
          style: TextStyle(
            fontSize: 15.0,
            color: Colors.black,
          ),
        ),
        onPressed: () {
          setState(() {
            _button = '$prefix Button $i';
          });
        },
      ));
    return buttons;
  }

  String _button = 'None';
  double _headerHeight = 60.0;
  double _bodyHeight = 180.0;
  BottomDrawerController _controller = BottomDrawerController();
}
