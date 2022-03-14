import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class ColorizedText extends StatelessWidget {

final colorizeColors = [
// //  Color(0xffF9F871),
//   Color(0xffC86497),
//   // Color(0xffAE67A6),
//   Color(0xff8E6BAE),
//   Color(0xff6B6FAF),

//   Color(0xff4670A9),
//   Color(0xff1F6F9C),


// Color(0xff845EC2),
// Color(0xff2C73D2),
// Color(0xff0081CF),
// Color(0xff0089BA),
// Color(0xff008E98),
// Color(0xff008F7A),

Color(0xff4FAF44),
Color(0xffF6EB14),
Color(0xffFF9526),
Color(0xffEF4423),
Color(0xff2A3492),
];

final colorizeTextStyle = TextStyle(
  fontSize: 50.0,
  //fontWeight: FontWeight.bold,
  fontFamily: 'MrRobot',
);


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: AnimatedTextKit(
        pause: Duration(milliseconds: 1),
        animatedTexts: [
          ColorizeAnimatedText(
            'Net Shield',
            textStyle: colorizeTextStyle,
            colors: colorizeColors,
            textAlign: TextAlign.center,
            speed: Duration(milliseconds: 200),
          ),
        ],
        repeatForever: true,
        isRepeatingAnimation: true,
        onTap: () {
          print("Tap Event");
        },
      ),
    );
  }
}