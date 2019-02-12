import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:notifications_only/clases/Welcome.dart';
import 'package:notifications_only/clases/libs/HttpRequest.dart';
import 'package:notifications_only/clases/libs/Parent.dart';
import 'package:notifications_only/clases/libs/UserModel.dart';


enum ThemeColor{
  DEFAULT,
  LIGTH,
  DARK
}

ThemeData blackTheme = ThemeData(
  brightness: Brightness.light,
//          primarySwatch: Colors.brown,
  primarySwatch: Colors.red,
  accentColor: Colors.green, //button
  scaffoldBackgroundColor: Color.fromRGBO(46, 55, 72, 1.0),// background
  textTheme: new TextTheme( // text
    body1: new TextStyle(color: Colors.white),
    title: TextStyle(
        color: Colors.white
    ),



  ),

  primaryColorLight: Colors.greenAccent,
  primaryColorDark: Colors.green,
  canvasColor: Colors.white,
  accentTextTheme: TextTheme(
    body1: TextStyle(color: Colors.white),
  ),
  primaryTextTheme: TextTheme(
    body1: TextStyle(color: Colors.white),
    display1: TextStyle(color: Colors.white),

  ),
  highlightColor: Colors.black,
  splashColor: Colors.green,
  secondaryHeaderColor: Colors.yellow,
  textSelectionHandleColor: Colors.limeAccent,
  indicatorColor: Colors.amberAccent,
  hintColor: Colors.white,
  textSelectionColor: Colors.white,
  iconTheme: IconThemeData(color: Colors.white),
  accentIconTheme: IconThemeData(color: Colors.white),
  primaryIconTheme: IconThemeData(color: Colors.white),


  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.green,
          width: 2.0,

        )
    ),
    labelStyle: TextStyle(
      color: Colors.green,
      decorationColor: Colors.white,


    ),
    hintStyle: TextStyle(color: Colors.white),
    //border: UnderlineInputBorder(borderSide: BorderSide.none),
    fillColor: Colors.green,
  ),

);

class MyModel extends Model{
  int _counter = 0;

  int get counter => _counter;
  void set counter(int cnt) => _counter = cnt;

  num ConnectionStatus = 1;

  User user;

  User get getUser => user;

  void setUser(User user){
    this.user = user;
  }

  void setConnectionStatus(num status){
    ConnectionStatus = status;
    print("set connection status to ${status.toString()}...............");
    notifyListeners();
  }

  static bool NotificationsStatus = false;
  static num LastPersonalDataMessageId = 0;


  static Map<String, Map<String, dynamic>> routeKeysWithNotifications = Map<String, Map<String, dynamic>>();




  MyModel(){
    //print("enter in contructor");

  }



  static MyModel of(BuildContext context) {
    return ScopedModel.of<MyModel>(context);
  }


}