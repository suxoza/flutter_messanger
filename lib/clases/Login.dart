import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:notifications_only/clases/libs/HttpRequest.dart';
import 'package:notifications_only/clases/libs/Model.dart';
import 'package:notifications_only/clases/libs/Parent.dart';
import 'package:notifications_only/clases/libs/Database.dart';
import 'package:notifications_only/clases/libs/UserModel.dart';
import 'package:notifications_only/clases/Welcome.dart';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';
import 'package:device_id/device_id.dart';
import 'package:device_info/device_info.dart';


class Login extends StatefulWidget {

  Login({Key key}): super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  bool _inAsyncCall = false;
  bool _obscureText = true;
  bool _buttonStatus = false;
  bool sendStatus = false;

  TextEditingController _userName = TextEditingController();
  TextEditingController _password = TextEditingController();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Post requests;
  GetSlots getSlots;


  DeviceInfoPlugin deviceInfo;
  var platrofmInfo;
  Map<String, String> deviceInfoObject = {};


  @override
  void initState() {
    // TODO: implement initState
    __init__();
    super.initState();
  }

  void __init__(){
    requests = new Post();
    getSlots = new GetSlots(context: context, request: requests,);
  }

  void formOnChange(){
    bool status = (_userName.text.length > 2 && _password.text.length > 2)
        ? true
        : false;
    setState(() {
      _buttonStatus = status;
    });
  }

  void get _displaySnackbar {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        duration: Duration(seconds: 3),
        content: Text("მომხმარებელი ვერ მოიძებნა!")));
  }

  Future<void> initDeviceID(Map<String, String> deviceInfo) async {
    GetSlots getSlots = GetSlots(request: requests, context: context);
    await getSlots.Gibrid(deviceInfo);
  }

  Future<void> registerDevice(User user, MyModel model) async {
    try {

      deviceInfo = DeviceInfoPlugin();

      bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
      if (isIOS) {
        platrofmInfo = await deviceInfo.iosInfo;
      } else {
        platrofmInfo = await deviceInfo.androidInfo;
      }
      deviceInfoObject = {
        'method_name': 'initDevice',
        'user_id': user.user_id.toString(),
        'board': platrofmInfo.board,
        'bootloader': platrofmInfo.bootloader,
        'brand': platrofmInfo.brand,
        'display': platrofmInfo.display,
        'fingerprint': platrofmInfo.fingerprint,
        'hardware': platrofmInfo.hardware,
        'host': platrofmInfo.host,
        'dvID': platrofmInfo.id,
        'manufacturer': platrofmInfo.manufacturer,
        'model': platrofmInfo.model,
        'product': platrofmInfo.product,
        'device': platrofmInfo.device,
        'type': platrofmInfo.type,
        'deviceID': platrofmInfo.androidId,
      };
      await initDeviceID(deviceInfoObject);
      await DBProvider.db.newUser(user);

    }catch(e){
      print("error is: "+e.toString());
    }
  }

  Future<void> saveForm(model) async{
    if(sendStatus)return;

    setState(() {
      _inAsyncCall = true;
    });

    sendStatus = true;
    if(_formKey.currentState.validate()){
      Map<String, String> dt = {
        "user": _userName.text.trim(),
        "password":_password.text.trim(),
        "device_id": 'some_id',
        "method_name": 'Login'
      };
      print("devide info");
      getSlots.Gibrid(dt).then((Map<String, dynamic> value){
          try{
              if(value['status'] == 0){
                _displaySnackbar;
                setState(() {
                  _userName.text = '';
                  _password.text = '';
                  sendStatus = false;
                  _buttonStatus = false;
                  _inAsyncCall = false;
                });

              }else{
                  model.user = User.fromMap(value['data']);
                  registerDevice(model.user, model).then((_){
                    Navigator.pushReplacement(context,  MaterialPageRoute(
                        builder: (context) => Welcome(userID: model.user.user_id,),
                      ));
                  });
              }
          }catch(e){
              print(e.toString());
          }
      });


    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("welcome"),),
      body: ScopedModelDescendant<MyModel>(
          builder: (BuildContext context, child, model){
            return ModalProgressHUD(
              inAsyncCall: _inAsyncCall,
              opacity: 0.5,
              progressIndicator: CircularProgressIndicator(),
              child: Center(
                child: Form(
                  key: _formKey,
                  onChanged: () => formOnChange(),

                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(left: 24.0, right: 24.0),
                    children: <Widget>[
                      //avatar
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 48.0,
                        child: Image.asset('images/logo.png'),
                      ),

                      SizedBox(height: 48.0),

                      //email

                      new ListTile(
                        leading: Icon(
                          Icons.person,
                        ),
                        title: new TextFormField(
                            controller: _userName,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'please enter username!';
                              }
                            },
                            keyboardType: TextInputType
                                .emailAddress, // Use email input type for emails.
                            decoration: new InputDecoration(
                              hintText: 'მომხმარებელი',
                              labelText: 'User',
                            )),
                      ),
                      SizedBox(height: 8.0),
                      //password

                      ListTile(
                        leading: Icon(
                          Icons.security,
                        ),
                        title: new TextFormField(
                            controller: _password,
                            validator: (value) {
                              if(value.isEmpty) {
                                return 'please enter password!';
                              }
                            },
                            obscureText:
                            _obscureText, // Use secure text for passwords.
                            decoration: new InputDecoration(
                              hintText: 'პაროლი',
                              labelText: 'Password',
                              suffixIcon: new GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: new Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            )),
                      ),
                      SizedBox(height: 24.0),
                      //button

                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          onPressed: _buttonStatus? () => saveForm(model):null,
                          padding: EdgeInsets.all(12),
                          color: Colors.lightBlueAccent,
                          child: Text('Log In', style: TextStyle(color: Colors.white)),
                        ),
                      )

                    ],
                  ),
                ),
              ),
            );
          }
      )
    );



  }




}
