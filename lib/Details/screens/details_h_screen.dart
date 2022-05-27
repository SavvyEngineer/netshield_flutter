import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netshield/Details/widgets/pieChartScreen.dart';
import 'package:netshield/colors.dart';
import 'package:provider/provider.dart';

import '../../Authentication/provider/status_provider.dart';
import '../../Secure/secure_storage.dart';
import '../../widgets/colorized_text_counter.dart';

enum _Tab { one, two }

class DetailsHomeScreen extends StatefulWidget {
  static const String routeName = '/details_screen_home';
  DetailsHomeScreen({Key? key}) : super(key: key);

  @override
  State<DetailsHomeScreen> createState() => _DetailsHomeScreenState();
}

class _DetailsHomeScreenState extends State<DetailsHomeScreen> {
  Map userData = {};
  late Future _user_status_future;
  _Tab _selectedTab = _Tab.one;

  @override
  void initState() {
    _user_status_future = fetch_status_data();
    super.initState();
  }

  Future fetch_status_data() async {
    SecureLs secureLs = new SecureLs();
    await secureLs.getLsData().then((value) {
      userData = value;
      userData.forEach((key, value) {
        print('$key==$value');
      });
    });
    return await Provider.of<StatusProvider>(context, listen: false)
        .getUserStatusCounter(userData['token']);
  }

  @override
  Widget build(BuildContext context) {
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
            future: _user_status_future,
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
                  Map r_data = dataSnapShot.data as Map;
                  List blocked_domains = r_data["blockedStatus"]["entry"];
                  List cached_dns = r_data["dnsStatus"]["entry"];
                  PieChartSample2 pieChartSample2 = new PieChartSample2(rdata:blocked_domains);
                  return Column(children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ColorizedTextCounter(
                                    "Blocked Ads",
                                    TextStyle(
                                      fontSize: 21,
                                      //fontWeight: FontWeight.bold,
                                      fontFamily: 'Ubuntu',
                                    )),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ColorizedTextCounter(
                                      r_data["blockedStatus"]["totalResults"]
                                          .toString(),
                                      TextStyle(
                                        fontSize: 31,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: 'MrRobot',
                                      )),
                                ),
                                SizedBox(
                                  height: 3,
                                  width: 50,
                                  child: Container(color: Colors.amber),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ColorizedTextCounter(
                                    "Cached dns",
                                    TextStyle(
                                      fontSize: 21,
                                      //fontWeight: FontWeight.bold,
                                      fontFamily: 'Ubuntu',
                                    )),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ColorizedTextCounter(
                                      r_data["dnsStatus"]["totalResults"]
                                          .toString(),
                                      TextStyle(
                                        fontSize: 31,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: 'MrRobot',
                                      )),
                                ),
                                SizedBox(
                                  height: 3,
                                  width: 50,
                                  child: Container(color: Colors.amber),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Card(
                        child: Center(child: pieChartSample2),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Card(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 16),
                          CupertinoSegmentedControl<_Tab>(
                            selectedColor: Colors.black,
                            borderColor: Colors.black,
                            pressedColor: Colors.grey,
                            children: {
                              _Tab.one: Text('Blocked'),
                              _Tab.two: Text('Cached'),
                            },
                            onValueChanged: (value) {
                              setState(() {
                                _selectedTab = value;
                              });
                            },
                            groupValue: _selectedTab,
                          ),
                          SizedBox(height: 8),
                          Container(
                            child: Builder(
                              builder: (context) {
                                switch (_selectedTab) {
                                  case _Tab.one:
                                    return Container(
                                      height: 200,
                                child: ListView.builder(
                                  itemCount: blocked_domains.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return ListTile(
                                      leading: Icon(Icons.image),
                                      title:Text(blocked_domains[index]["domain"].toString()),
                                      trailing: Text(blocked_domains[index]["timestamp"].toString()),
                                    );
                                  },
                                ),
                                    );
                                  case _Tab.two:
                                    return Container(
                                      height: 200,
                                      child: ListView.builder(
                                  itemCount: blocked_domains.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return ListTile(
                                      leading: Icon(Icons.image),
                                      title:Text(cached_dns[index]["domain"].toString()),
                                      trailing: Text(cached_dns[index]["timestamp"].toString()),
                                    );
                                  },
                                ),
                                    );
                                }
                              },
                            ),
                          ),
                        ],
                      )),
                    ),
                  ]);
                }
              }
            }));
  }
}
