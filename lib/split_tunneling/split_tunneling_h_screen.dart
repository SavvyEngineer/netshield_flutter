import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:netshield/Secure/secure_storage.dart';

import '../colors.dart';

class SplitTunnelingScreen extends StatefulWidget {
  static const String routeName = '/split_tunneling';
  SplitTunnelingScreen({Key? key}) : super(key: key);

  @override
  State<SplitTunnelingScreen> createState() => _SplitTunnelingScreenState();
}

class _SplitTunnelingScreenState extends State<SplitTunnelingScreen> {
  late Future _list_packages_future;
  late List<AppInfo> apps;
  List selected_apps = [];
  SecureLs secureLs = new SecureLs();

  Future<List<AppInfo>> getPackegesFuture() async {
    apps = await InstalledApps.getInstalledApps(true, true);
    await secureLs.getLsData().then((value) {
      if (value['split_app_list'] != null) {
        selected_apps = json.decode(value['split_app_list']);
      }
      if (selected_apps.length == 0) {
        apps.forEach((element) {
          selected_apps.add(element.packageName);
        });
        setState(() {});
      }
    });
    return apps;
  }

  @override
  void initState() {
    super.initState();
    _list_packages_future = getPackegesFuture();
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.maxFinite,
                height: 100,
                child: Center(
                  child: Card(
                    child: Center(child: Text('Your Applications')),
                  ),
                ),
              ),
            ),
            FutureBuilder(
                future: _list_packages_future,
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
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: Colors.transparent,
                          elevation: 15,
                          child: Container(
                            child: ListView.separated(
                              physics: BouncingScrollPhysics(),
                              separatorBuilder: (context, index) => SizedBox(
                                height: 10,
                              ),
                              shrinkWrap: true,
                              itemCount: apps.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  elevation: 15,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      leading: Image.memory(
                                          apps[index].icon as Uint8List),
                                      title: Text(apps[index].name.toString()),
                                      trailing: Switch(
                                          value: selected_apps.contains(
                                              apps[index].packageName),
                                          onChanged: (state) {
                                            if (state) {
                                              selected_apps.add(apps[index]
                                                  .packageName
                                                  .toString());
                                              setState(() {});
                                            } else {
                                              if (selected_apps.contains(
                                                  apps[index]
                                                      .packageName
                                                      .toString())) {
                                                selected_apps.remove(apps[index]
                                                    .packageName
                                                    .toString());
                                                setState(() {});
                                              }
                                            }
                                          }),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }
                  }
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.done_outline),
          onPressed: () async{
            if (selected_apps.length == 0) {
              await secureLs.remove_a_key('split_app_list');
            } else {
              await secureLs.writeSingleKeyLs(
                  'split_app_list', json.encode(selected_apps));
            }
            Navigator.of(context).pop();
          }),
    );
  }
}
