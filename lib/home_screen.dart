import 'dart:async';
import 'dart:io';

import 'package:bottom_drawer/bottom_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:netshield/Authentication/provider/auth_provider.dart';
import 'package:netshield/Authentication/provider/status_provider.dart';
import 'package:netshield/Authentication/screens/pieChartScreen.dart';
import 'package:netshield/Secure/secure_storage.dart';
import 'package:netshield/colors.dart';
import 'package:netshield/theme.dart';
import 'package:netshield/widgets/colorized_text.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rolling_switch/rolling_switch.dart';
import 'package:vibration/vibration.dart';

class MyHomePage extends StatefulWidget {
  static const String routeName = '/home';
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BottomDrawerController controller = BottomDrawerController();
  bool isInit = true;
  late OpenVPN openvpn;
  dynamic status;
  String stage = 'Awaiting Data';
  late bool swBtnState = false;
  String serverCert = '';
  late Future _open_vpn_initilze_future;
  late Future _user_status_future;
  Map userData = {};
  bool _is_init = true;

  @override
  void didChangeDependencies() {
    if (_is_init) {
      _open_vpn_initilze_future = loadAsset();
    }
    _is_init = false;
    super.didChangeDependencies();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _open_vpn_initilze_future = loadAsset();
  // }

  Future<void> loadAsset() async {
    SecureLs secureLs = new SecureLs();
    await secureLs.getLsData().then((value) {
      userData = value;
      userData.forEach((key, value) {
        print('$key==$value');
      });
    });

    if (userData['ovpn-url'] == null) {
      Provider.of<AuthProvider>(context, listen: false)
          .getAccountData(userData['token']);
    } else {
      await Provider.of<AuthProvider>(context, listen: false)
          .getServerConfig(userData['ovpn-url'], userData['token'])
          .then((value) {
        if (userData['ovpn-config'] == null) {
          userData['ovpn-config'] = value;
        } else {
          serverCert = userData['ovpn-config'];
        }
      });
    }
    setState(() {});
    //String config = await rootBundle.loadString('assets/vpn_config.txt');
    openvpn = await OpenVPN(
        onVpnStatusChanged: _onVpnStatusChanged,
        onVpnStageChanged: _onVpnStageChanged);
    await openvpn.initialize(
        groupIdentifier: "ir.netshield.app",

        ///Example 'group.com.laskarmedia.vpn'
        providerBundleIdentifier: "ir.netshield.app.network",

        ///Example 'id.laskarmedia.openvpnFlutterExample.VPNExtension'
        localizedDescription: "NetShield"

        ///Example 'Laskarmedia VPN'
        );
    //print(config);
    _user_status_future = fetch_status_data();
    new Timer.periodic(Duration(seconds: 5), (Timer t) {
      fetch_status_data();
    });
  }

  Future fetch_status_data() async {
    return await Provider.of<StatusProvider>(context, listen: false)
        .getUserStatusCounter(userData['token']);
    
  }

  dynamic _onVpnStatusChanged(VpnStatus? vpnStatus) {
    setState(() {
      this.status = vpnStatus;
    });
  }

  dynamic _onVpnStageChanged(VPNStage stage, String status) {
    setState(() {
      this.stage = status;
      if (status == 'connected') {
        swBtnState = true;
      } else {
        swBtnState = false;
      }
      // print('netshield:${status.toString()}');
    });
  }

  static Future<String> getLocalIpAddress() async {
    final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4, includeLinkLocal: true);

    try {
      // Try VPN connection first
      NetworkInterface vpnInterface =
          interfaces.firstWhere((element) => element.name == "tun0");
      return vpnInterface.addresses.first.address;
    } on StateError {
      // Try wlan connection next
      try {
        NetworkInterface interface =
            interfaces.firstWhere((element) => element.name == "wlan0");
        return interface.addresses.first.address;
      } catch (ex) {
        // Try any other connection next
        try {
          NetworkInterface interface = interfaces.firstWhere((element) =>
              !(element.name == "tun0" || element.name == "wlan0"));
          return interface.addresses.first.address;
        } catch (ex) {
          return '';
        }
      }
    }
  }

  _startVpn() async {
    if (serverCert == '') {
      await loadAsset();
    }
    print(serverCert);
    openvpn.connect(serverCert, 'netshield',
        bypassPackages: [], certIsRequired: true);
    Vibration.vibrate(duration: 150);
  }

  _stopVpn() {
    openvpn.disconnect();
    Vibration.vibrate(duration: 150);
  }

  String _vpnStage(String vpnCurrentStage) {
    String current_status;
    switch (vpnCurrentStage) {
      case 'Awaiting Data':
        current_status = 'Disconnected';
        break;
      case 'idle':
        current_status = 'Disconnected';
        break;
      case 'noprocess':
        current_status = 'Disconnected';
        break;
      case 'vpn_generate_config':
        current_status = 'Generating Congiguration';
        break;
      case 'wait_connection':
        current_status = 'Waiting for server to respond';
        break;
      case 'get_config':
        current_status = 'Getting server Configuration';
        break;
      case 'assign_ip':
        current_status = 'Assigning Ip';
        break;
      case 'connected':
        current_status = 'Connected!';
        break;
      case 'disconnected':
        current_status = 'Disconnected';
        break;
      default:
        current_status = 'Ready for Sheilding your AdNet';
    }
    return current_status;
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
        backgroundColor: Color(App_colors.screen_background_color),
        brightness: Brightness.light);
    return Scaffold(
        backgroundColor: Color(App_colors.screen_background_color),
        appBar: appBar,
        body: FutureBuilder(
            future: _open_vpn_initilze_future,
            builder: (context, dataSnapShot) {
              if (dataSnapShot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (dataSnapShot.error != null) {
                  return Center(
                    child: Text(
                        'An error occured error=${dataSnapShot.error.toString()}'),
                  );
                } else {
                  return Stack(
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                child: RollingSwitch.widget(
                                  initialState: swBtnState,
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
                                    margin:
                                        EdgeInsets.only(top: 30, bottom: 30),
                                    child: Text(
                                      _vpnStage(stage),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'Ubuntu',
                                          fontSize: 25,
                                          height: 1,
                                          color: Color(App_colors.text_color),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    _vpnStage(stage) == 'connected'
                                        ? 'you will never be bothered again by ads'
                                        : 'you are going to see ads because your not connected',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Ubuntu',
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            FutureBuilder(
                                future: _user_status_future,
                                builder: (context, dataSnapShot) {
                                  if (dataSnapShot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    if (dataSnapShot.error != null) {
                                      return Center(
                                        child: Text(
                                            'An error occured error=${dataSnapShot.error.toString()}'),
                                      );
                                    } else {
                                      return _StatusBoxWidget(
                                          context, dataSnapShot);
                                    }
                                  }
                                })
                          ],
                        ),
                      ),
                      //  _buildBottomDrawer(context),
                    ],
                  );
                }
              }
            }));
  }

  Widget _StatusBoxWidget(BuildContext context, AsyncSnapshot dataSnapShot) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: SizedBox(
        width: double.maxFinite,
        height: 230,
        child: Card(
          color: Colors.white60,
          child: Column(
            children: [
              Text('Status Box'),
              Divider(),
              SizedBox(
                height: 100,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Expanded(
                    flex: 1,
                    child: Card(
                      elevation: 15,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Blocked Ads"),
                            Text(dataSnapShot.data["blockedStatus"]["totalResults"].toString())
                          ]),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Card(
                      elevation: 15,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Cached dns"),
                            Text(dataSnapShot.data["dnsStatus"]["totalResults"].toString())
                            ]),
                    ),
                  )
                ]),
              ),
              Text("latest Blocked Domains"),
              Divider(),
              Container(
                width: double.maxFinite,
                height: 20,
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: Icon(Icons.account_balance_wallet_rounded),
                      title: Text("instagram.com"),
                    );
                  },
                ),
              ),
            ],
          ),
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
      color: Color(App_colors.text_color),
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
