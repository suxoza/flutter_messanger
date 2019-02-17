import 'dart:async';

import 'package:notifications_only/clases/libs/Model.dart';
//import 'package:flutter_new/clases/libs/RestartApp.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
//import 'package:notifications_only/clases/libs/Parent.dart';
import 'package:notifications_only/clases/Welcome.dart';
import 'package:notifications_only/clases/Login.dart';
import 'package:async_loader/async_loader.dart';
import 'package:notifications_only/clases/libs/Database.dart';




void main() => runApp(new MyApp());

class MyApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _MyApp();

}

class _MyApp extends State<MyApp> with WidgetsBindingObserver, RouteAware{
  // This widget is the root of your application.
  final Connectivity _connectivity = Connectivity();
  String _connectionStatus = 'ConnectivityResult.wifi';
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  MyModel model;




  final GlobalKey<AsyncLoaderState> _asyncLoaderState = GlobalKey<AsyncLoaderState>();


  void activePage(){
    num status;
    if(_connectionStatus == 'ConnectivityResult.none')
      status = 0;
    else
      status = 1;
    model.setConnectionStatus(status);
  }

  Future<int> asyncWait() async {
    int user_id = 0;
    try {
      user_id = await DBProvider.db.getUserID();
    }catch(e){

    }
    return user_id;
  }

  @override
  Widget build(BuildContext context){
    print("rebuild wholl application..............");
    AsyncLoader _asyncLoader = new AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await DBProvider.db.getUserID(),
        renderLoad: () => Scaffold(body: Center(child: new CircularProgressIndicator())),
        renderError: ([error]) =>
        new Text('Sorry, there was an error loading your joke '+error.toString()),
        renderSuccess: ({data}) => data == null || data == 0?Login():Welcome(userID: data,)
    );



    return ScopedModel<MyModel>(

        model: model,
        child: MaterialApp(
          title: 'Booker',
          debugShowCheckedModeBanner: false,
          //theme: getTheme(),
          theme: ThemeData.light(),
          //home: (RestartWidget.status)?Login():Settings(model: MyModel.of(context),),
          home: _asyncLoader,
          routes: <String, WidgetBuilder>{
            "/login"   : (BuildContext context) => Login(),
            "/welcome" : (BuildContext context) => Welcome()
          },

        )
    );

  }


  bool isBackButtonActivated = false;

  //-------------------------Required For WidgetsBindingObserver

  Future<Null> initConnectivity() async{
    String connectionStatus;
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } on PlatformException catch (e) {
      print(e.toString());
      connectionStatus = 'Failed to get connectivity.';
    }

    if (!mounted) {
          return Null;
    }
    if(_connectionStatus != connectionStatus) {
      // setState(() {
      _connectionStatus = connectionStatus;
      activePage();
      // });
    }



  }

  @override
  void initState() {
    model = new MyModel();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          if(result.toString() != _connectionStatus){
            //setState(() {
            _connectionStatus = result.toString();
            //});
            activePage();
            print("connection status was changed............."+result.toString()+' => '+_connectionStatus);
          }
        });



    super.initState();
    WidgetsBinding.instance.addObserver(this);



  }


  void showInthernetErrorWindow(){
    showDialog(
        barrierDismissible: true,
        context: context,

        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Error!"),
            content: Card(child: Text("შეამოწმეთ ინტერნეტ კავშირი!")),
          );
        }
    ).then((_){
      print("window was closed");
    });

  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  didPushRoute(String route){
    print("route was changed on...........................: "+route);
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
//    if(state == AppLifecycleState.paused){}

  }



}

