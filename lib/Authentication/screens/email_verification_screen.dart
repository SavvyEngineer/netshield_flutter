import 'package:flutter/material.dart';
import 'package:netshield/Authentication/provider/auth_provider.dart';
import 'package:netshield/Secure/secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:timer_button/timer_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  static const String routeName = '/email_verification';

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late Future _account_status_future;
  bool _is_init = true;
  late Map<String, dynamic> arguments;
  late String userEmail;
  late String userPassword;

  Future<void> _obtain_account_status({bool from_btn:false}) async {
    arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    userEmail = arguments['email'].toString();
    userPassword = arguments['password'].toString();

    return await Provider.of<AuthProvider>(context, listen: false)
        .getAccountStatus(userEmail)
        .then((value) {
      // value.forEach((key, value) {
      //   print('key==$key----value===$value');
      // });
      if (value['status'] == 1 && value['token'] == '') {
        Provider.of<AuthProvider>(context, listen: false)
            .loginUser(context, userEmail, userPassword);
      } else {
        if (from_btn) {
          showAlertDialog(context, userEmail, value['token']);
          print('status---${value['status']}');
          print('token----${value['token']}');
        }
      }
    });
  }

  showAlertDialog(BuildContext context, String userEmail, String token) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Send Mail"),
      onPressed: () {
        Provider.of<AuthProvider>(context, listen: false)
            .send_mail(userEmail, 'Nethsield',
                'https://api.netshield.ir/public/app/backend/user/activate/$token')
            .then((value) {
          Navigator.of(context).pop();
          print('Mail sent!!!');
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text("Would you like us to resend activation mail?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _account_status_future = _obtain_account_status();
  // }

  @override
  void didChangeDependencies() {
    if (_is_init) {
      _account_status_future = _obtain_account_status();
    }
    _is_init = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _obtain_account_status,
        child: FutureBuilder(
            future: _account_status_future,
            builder: (context, dataSnapShot) {
              if (dataSnapShot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (dataSnapShot.error != null) {
                  print(dataSnapShot.error);
                  return Center(
                    child: Text('An error occured'),
                  );
                } else {
                  return Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Awaiting Email Verification",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      new TimerButton(
                        label: "Send Verification mail Again",
                        timeOutInSeconds: 20,
                        onPressed: () {
                          _obtain_account_status(from_btn: true);
                        },
                        resetTimerOnPressed: true,
                        disabledColor: Colors.red,
                        color: Colors.deepPurple,
                        disabledTextStyle: new TextStyle(fontSize: 20.0),
                        activeTextStyle:
                            new TextStyle(fontSize: 20.0, color: Colors.white),
                      )
                    ],
                  ));
                }
              }
            }),
      ),
    );
  }
}
