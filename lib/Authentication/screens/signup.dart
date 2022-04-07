import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:netshield/Authentication/provider/auth_provider.dart';
import 'package:netshield/Authentication/screens/email_verification_screen.dart';
import 'package:netshield/Secure/secure_storage.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  Map userData = {};

  final name_txt_controller = TextEditingController();

  final last_name_txt_controller = TextEditingController();

  final email_txt_controller = TextEditingController();

  final password_txt_controller = TextEditingController();

  @override
  void dispose() {
    name_txt_controller.dispose();
    last_name_txt_controller.dispose();
    email_txt_controller.dispose();
    password_txt_controller.dispose();
    super.dispose();
  }

  Future<void> _submit_signup_data(BuildContext context, Map enUserData) async {
    Provider.of<AuthProvider>(context, listen: false)
        .signUpUser(userData)
        .then((value) {
      if (value == 'success') {
        SecureLs secureLs = new SecureLs();
        secureLs.writeInitialLs({
          "first_name":enUserData['first_name'],
          "last_name":enUserData['last_name']
        });
        Navigator.of(context).pushReplacementNamed(
            EmailVerificationScreen.routeName,
            arguments: enUserData);
      } else {
        print(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Sign up with",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFF3D657),
            height: 2,
          ),
        ),
        Text(
          "NETSHIELD",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF3D657),
            letterSpacing: 2,
            height: 1,
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: TextField(
                controller: name_txt_controller,
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF3F3C31),
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              flex: 2,
              child: TextField(
                controller: last_name_txt_controller,
                decoration: InputDecoration(
                  hintText: 'LastName',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF3F3C31),
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
        TextField(
          controller: email_txt_controller,
          decoration: InputDecoration(
            hintText: 'Email',
            hintStyle: TextStyle(
              fontSize: 16,
              color: Color(0xFF3F3C31),
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
        ),
        SizedBox(
          height: 16,
        ),
        TextField(
          controller: password_txt_controller,
          decoration: InputDecoration(
            hintText: 'Password',
            hintStyle: TextStyle(
              fontSize: 16,
              color: Color(0xFF3F3C31),
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
        ),
        SizedBox(
          height: 24,
        ),
        GestureDetector(
          onTap: () {
            userData['first_name'] = name_txt_controller.text;
            userData['last_name'] = last_name_txt_controller.text;
            userData['email'] = email_txt_controller.text;
            userData['password'] = password_txt_controller.text;
            userData['name'] = email_txt_controller.text.replaceFirst("@", "_");
            userData.forEach((key, value) {
              print('key===$key---value==$value');
            });
            _submit_signup_data(context, userData);
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFFF3D657),
              borderRadius: BorderRadius.all(
                Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFF3D657).withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 4,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "SIGN UP",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1C),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 24,
        ),
        Text(
          "Or Signup with",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFF3D657),
            height: 1,
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Entypo.facebook_circled,
              size: 32,
              color: Color(0xFFF3D657),
            ),
            SizedBox(
              width: 24,
            ),
            Icon(
              Entypo.google_circles,
              size: 32,
              color: Color(0xFFF3D657),
            ),
          ],
        )
      ],
    );
  }
}
