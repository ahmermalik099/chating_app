// ignore_for_file: prefer_const_constructors

import 'package:flash_chat/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/components/rounded_button.dart';

const colorizeColors = [
  Colors.lightBlue,
  Colors.blueAccent,
  Colors.black12,
  Colors.grey,
];

const colorizeTextStyle = TextStyle(
  fontSize: 50.0,
  fontFamily: 'Horizon',
);


class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    animation = ColorTween(begin: Colors.blueAccent, end: Colors.lightBlueAccent).animate(controller);

    controller.forward();

    animation.addStatusListener((status) {
        if(status == AnimationStatus.completed){
          controller.reverse(from: 1);
        }
        else if(status == AnimationStatus.dismissed){
          controller.forward();
        }
    });

    controller.addListener(() {
      //if(controller.status==)
      setState((){

        //print(animation.value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 60.0,
                  child: Image.asset('images/logo.png'),
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    ColorizeAnimatedText(
                      'Flash Chat',
                      textStyle: colorizeTextStyle,
                      colors: colorizeColors,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(color: Colors.lightBlueAccent, title: 'Log In', onPressed: () {
              Navigator.pushNamed(context, LoginScreen.id);
            },),
            RoundedButton(color: Colors.blueAccent, title: 'Register', onPressed: (){
              Navigator.pushNamed(context, RegistrationScreen.id);
            },),
          ],
        ),
      ),
    );
  }
}


