import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:notifications_only/clases/libs/Model.dart';
import 'package:flutter/material.dart';
import 'package:notifications_only/clases/libs/HttpRequest.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


abstract class Parent {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static Timer timer;
  String _currentRoute;
  GetSlots getSlots;
  Post requests;
  BuildContext _context;
  List<String> _items;
  Timer RebuildTimer;

  Future TimerAjax([dtParams]) async {
    Map<String, String> dt = {
      'method_name': 'getStream',
      'route': 'Welcome',
      "device_id": '11'
    };
    print(dt);

    if (dtParams.length != 0) {
      dt.addAll(dtParams);
    }
    //print(dt);
    try {
      return await getSlots.Gibrid(dt);
    } catch (e) {
      print("error is: " + e.toString());
    }
  }

  void callInDispose() {
    Parent.timer?.cancel();
    Parent.timer = null;
    RebuildTimer?.cancel();
    RebuildTimer = null;
  }

  Timer makeInterval(Function beforeCallback, Function afterCallback) {
    print(MyModel.NotificationsStatus);

    try {
      timer = new Timer.periodic(Duration(seconds: 5), (timer) {
        //print("send interval messages: "+MyModel.NotificationsStatus.toString());

        var params = beforeCallback();
        TimerAjax(params).then((responce) {
          if (MyModel
              .of(_context)
              .ConnectionStatus != 1) return null;

          if (responce['notifications'] != null) {
            getNotifications(responce['notifications'], _context);
          }

          afterCallback(responce);
        });
      });
    } catch (e) {
      print("............error was found: " + e.toString());
      timer?.cancel();
      timer = null;
      return null;
    }
  }



  List entered(String route, context){
    timer?.cancel();
    timer = null;
    requests = new Post();
    //MyModel.defaultRoute = route;
    _context = context;
    getSlots = new GetSlots(context: context, request: requests,);
    //print("route is "+route);
    _currentRoute = route;

    String route_name = _currentRoute.split('/')[1];
    if(MyModel.routeKeysWithNotifications[route_name] != null) {
      num current_num = MyModel.routeKeysWithNotifications[route_name]['num'];
      if (current_num > 0) {
      }
    }

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        selectNotification: onSelectNotification);
    return [getSlots, requests];
  }




  Future<Null> getNotifications(notifications, BuildContext context) async{
    //print('currrent route is: '+_currentRoute);
    //if(!MyModel.NotificationsStatus)return null;
    //notifications.forEach((v) => print(v));


    if(notifications['Bar'] != null){
      print("current route is: "+_currentRoute);
      if(_currentRoute != '/Bar'){
        num current_num = MyModel.routeKeysWithNotifications['Bar']['num'];
      }
      //print(notifications);
      int last_id = int.parse(notifications['Bar']['id']);

      if(MyModel.NotificationsStatus) {
        Map<String, dynamic> settings = {
          'id': last_id,
          'chanel_id': notifications['Bar']['insertDate'],
          'changel_name': notifications['Bar']['smNom'],
          "changel_description": notifications['Bar']['id'],
          "title": notifications['Bar']['notification_title'],
          "text": notifications['Bar']['notification_text'],
          "callback": "Bar"
        };
        showNotification(settings);
      }
    }

  }

  Future<Null> onSelectNotification(String payload){
    num ind = _items.indexOf(payload);
    //Redirect(_context, ind, MyModel.of(_context));
  }



  Future<Null> showNotification(Map<String, dynamic> params) async{
    var vibrationPattern = new Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;
    var android = new AndroidNotificationDetails(
      params['chanel_id'], params['changel_name'], params['changel_description'],
      priority: Priority.High,importance: Importance.Max, enableVibration: true, vibrationPattern: vibrationPattern,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        params['id'], params['title'], params['text'], platform,
        payload: params['callback']);



  }

  Future<Null> showOldNotification() async{
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High,importance: Importance.Max
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOSPlatformChannelSpecifics);




    await flutterLocalNotificationsPlugin.show(
        0, 'New Video is out', 'Flutter Local Notification', platform,
        payload: 'Nitish Kumar Singh is part time Youtuber');
    //await flutterLocalNotificationsPlugin.show


  }
}

class GetSlots{

  Post request;
  BuildContext context;

  GetSlots({@required this.context, this.request});


  //for comment block
  Future<Map<String, dynamic>> Gibrid(Map<String, String> dt, [String path = 'flutterStream/']) async {
    return await request.fetchPost(dt, path, context: this.context);

  }
}