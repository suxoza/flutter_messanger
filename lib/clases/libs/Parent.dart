import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:notifications_only/clases/libs/Model.dart';
import 'package:flutter/material.dart';
import 'package:notifications_only/clases/libs/HttpRequest.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifications_only/clases/libs/UserModel.dart';


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
      'onlyNotifications': '1',
      //"device_id": '11',
      'getUserPermission': '1'
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
      timer = new Timer.periodic(Duration(seconds: 10), (timer) {
        //print("send interval messages: "+MyModel.NotificationsStatus.toString());
        if (MyModel.of(_context).ConnectionStatus != 1){
          print("connection error");
          return null;
        }
        var params = beforeCallback();
        print('params is: ');
        print(params);
        TimerAjax(params).then((value) {
          if (value['data']['count'] != 0) {
            print("get responce for notifications ${value['data']['count']}");
            if(value['data']['count'] == 1){
              try{
                Message message = Message.fromMap(value['data']['body'][0]);
                getSingleNotification(message, _context);
              }catch(e){
                print('error is: '+e.toString());
              }
              //print(notification);
              //getSingleNotification(data, context);
            }else if(value['data']['count'] > 1){
              value['data']['body'].forEach((v){
                getSingleNotification(Message.fromMap(v), _context);
              });
            }
            //getNotifications(responce, _context);
          }

          afterCallback(value);
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




  Future<Null> getSingleNotification(Message data, BuildContext context, {String chanelID = 'ch', String chanelName = 'ch1', String chanelDesc = 'ch2'}) async{


      if(MyModel.NotificationsStatus) {
        Map<String, dynamic> settings = {
          'id': data.id,
          'chanel_id': chanelID,
          'changel_name': chanelName,
          "changel_description": chanelDesc,
          "title": data.title+' '+data.id.toString(),
          "text": data.body,
          "callback": "Bar"
        };
        showNotification(settings);
      }


  }

  Future<Null> onSelectNotification(String payload){
    //print("selected "+payload.toString());
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
        params['id'], params['title'], params['body'], platform,
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