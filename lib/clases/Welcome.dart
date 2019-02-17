import 'package:flutter/material.dart';
import 'package:notifications_only/clases/libs/HttpRequest.dart';
import 'package:notifications_only/clases/libs/Model.dart';
import 'package:notifications_only/clases/libs/Parent.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:notifications_only/clases/libs/UserModel.dart';
import 'package:notifications_only/clases/libs/Database.dart';
import 'dart:async';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sqflite/sqflite.dart';



class Welcome extends StatefulWidget {
  static String route = '/welcome';
  int userID;

  Welcome({Key key, this.userID}):super(key: key);
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with Parent{

  Post requests;
  GetSlots getSlots;
  bool rady = false;

  Scaffold sc = Scaffold();



  @override
  void initState() {
    // TODO: implement initState
    print("enter in welcome, deviceID: ");
    __init__();
    callTimer();




  }

  void callTimer(){
    makeInterval((){
      print("was done 1");
      return {
        'user_id': widget.userID.toString()
      };
    }, (responce) {
      //print(responce);

    });
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    getSlots = null;
    requests = null;
    callInDispose();
  }

  void __init__(){
    var GlobalK = entered(Welcome.route, context);
    getSlots = GlobalK[0];
    requests = GlobalK[1];

    //debugPrint(MyModel.of(context).user.permissions.toString());
    getAndAddDataToDB();


  }


  Future<void> getAndAddDataToDB() async {
    var dt = {
      'method_name': 'getStream',
      'user_id': widget.userID.toString()
    };
    bool userIsNull = false;
    if(MyModel.of(context).getUser == null){
      dt['getUserPermission'] = '1';
      userIsNull = true;
    }else{
      dt['permissions'] = MyModel.of(context).getUser.permToMap()['permissions'];
    }
    getSlots.Gibrid(dt).then((value) async {
      try {
        if (userIsNull && value['user']['permissions'] != null) {
          User user = User.fromMap(value['user']);
          MyModel.of(context).setUser(user);
          print("reload user");
          print(MyModel.of(context).getUser.permissions);
        }
        if (value['data']['count'] > 0) {
//          print(value['data']['permKeys']);
//          print(MyModel.of(context).getUser.permKeys());
        print('vv is: ');
        print(value['data']['body']);
          value['data']['body'].forEach((v) {
            try {
              DBProvider.db.addMessages(Message.fromMap(v));
            } on DatabaseException catch(e) {

            }
          });
          //print(data);
        }

      }catch(e){
          print("internet error was found!");
          print(MyModel.of(context).getUser);
      }finally{
        setState(() {
          rady = true;
        });
      }
    });
  }




  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Messages"),

          bottom: TabBar(
              tabs: [
                Tab(
                  text: 'ყველა',
                ),
                Tab(
                  text: 'ფავორიტები',
                )
              ]
          )

        ),
        body: rady?TabBarView(children: <Widget>[
          MyList(getSlots: getSlots, requests: requests, userID: widget.userID, favorited: false, ),
          MyList(getSlots: getSlots, requests: requests, userID: widget.userID, favorited: true, ),
        ],):Center(child: CircularProgressIndicator(),)



      ),
    );
  }

}

class MyList extends StatefulWidget {

  GetSlots getSlots;
  Post requests;
  int userID;
  bool favorited;
  Function callback;

  MyList({Key key, this.getSlots, this.requests, this.userID, this.favorited, this.callback}): super(key: key);

  @override
  _MyListState createState() => _MyListState();
}

class _MyListState extends State<MyList> {
  List<Message> data = [];
  int maxLength = 50;
  int currentPage = 1;
  int messagesCount = 0;
  bool loading = false;
  int _activeMeterIndex = null;

  ScrollController _scrollController = new ScrollController();


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController?.dispose();
  }

  @override
  void initState() {
    print("---inline initState");
    super.initState();
    getDataLength().then((_){
      getLocalData();
    });

    _scrollController.addListener(() async {
      //print(_scrollController.position.maxScrollExtent.toString()+' - '+_scrollController.offset.toString());
      if(_scrollController.position.maxScrollExtent == _scrollController.offset && !loading){
        await Future.delayed(Duration(seconds: 1));
        loading = true;
        currentPage = currentPage == 1? currentPage * maxLength: currentPage + maxLength;
        getLocalData(true).then((_){
          print("update list ${currentPage}");
          print("${data.length} - ${maxLength} - ${currentPage}");
          loading = false;
        });
      }
    });
  }






  Future<void> getDataLength() async {
    messagesCount = await DBProvider.db.MessagesCount(widget.favorited);
  }

  Future<void> getLocalData([bool append = false]) async {
    //MyModel.of(context).getUser.permKeys()
    print('get data: '+messagesCount.toString());

    List<int> permKeys = [];
    try{
      permKeys = MyModel.of(context).getUser.permKeys();
    }catch(e){}

    if(!append)
      data =  await DBProvider.db.getMessages(permKeys, currentPage, maxLength, widget.favorited);
    else{
      var dt = await DBProvider.db.getMessages(permKeys, currentPage, maxLength, widget.favorited);
      dt.forEach((m){
        data.add(m);
      });
    }

    //print(data);
    setState(() {

    });

  }



  @override
  Widget build(BuildContext context) {
    bool isLoading = true;

    return NestedScrollView(
      //controller: _scrollController,
        scrollDirection: Axis.vertical,

        headerSliverBuilder: (BuildContext context, bool inner){
          return [
            SliverAppBar(

              elevation: 10.0,
              automaticallyImplyLeading: false,
              backgroundColor: Color.fromRGBO(46, 55, 72, 1.0),
              title: Text("სულ: "+messagesCount.toString()),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(10.0),
                child: ScopedModelDescendant<MyModel>(builder: (context, child, model){
                  return model.ConnectionStatus == 0?Container(
                    height: 30.0,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(child: CircularProgressIndicator(strokeWidth: 3.0, valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),), height: 20.0, width: 20.0,),
                        SizedBox(width: 10.0,),
                        Text("ინტერნეტ კავშირი ვერ მოიძებნა"),
                      ],
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.yellow),
                  ):Container();
                })
              ),
            ),
          ];
        },
        body:
          ListView.builder(
            physics: ClampingScrollPhysics(),
            controller: _scrollController,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index){
              if(index < data.length){
                return getPanel(index);
              }

              return new Center(
                child: Opacity(
                  opacity: isLoading?1.0:0.0,
                  child: CircularProgressIndicator(),
                ),
              );
            },
            itemCount: (currentPage + maxLength) < (messagesCount)?data.length + 1:data.length,
          )


    );

  }





  Widget getPanel(int index){

    return Slidable(
      key: Key(data[index].id.toString()+'-'+index.toString()),
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      closeOnScroll: true,
      controller: SlidableController(
        onSlideIsOpenChanged: (bool isOpen){},
        onSlideAnimationChanged: (Animation<double> prm){



        }
      ),

      slideToDismissDelegate: SlideToDismissDrawerDelegate(
          onWillDismiss: (actionType) {
            return showDialog<bool>(
              context: context,
              builder: (context) {
                return new AlertDialog(
                  title: new Text('Delete'),
                  content: new Text('Item will be deleted'),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    new FlatButton(
                      child: new Text('Ok'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                );
              },
            );
          },
          dismissThresholds: <SlideActionType, double>{
            SlideActionType.primary: 1.0
          },

          closeOnCanceled: true,
          crossAxisEndOffset: 0.2,
          onDismissed:(actionType)  {
            if(actionType == SlideActionType.secondary)
               SecondaryAction(index);
          },

      ),
        actions: <Widget>[

            new IconSlideAction(

              closeOnTap: true,
              caption: data[index].viewed == 1?'Unread':'Read',
              color: Colors.blue,
              icon: Icons.archive,
              onTap: () => _viewed(index),
            ),
            new IconSlideAction(

              closeOnTap: true,
              caption: data[index].favorited == 1?'unfavorite':'favorite',
              color: Colors.green,
              icon: Icons.archive,
              onTap: () => _favorited(index),
            )
      ],
      secondaryActions: <Widget>[
        new IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => SecondaryAction(index),
        ),
      ],
      child: Card(
        //child: inlineExpesion(data, index)
          margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
          child: ExpensionPanel(index)
      )
    );


  }


  Future<void> SecondaryAction(int index) async { //remove

    DBProvider.db.DeleteMessage(data[index].id);
    if(widget.favorited){
      currentPage = 1;
    }
    setState(() {
      data.removeAt(index);
      print("will by remove: ${index}");
      messagesCount -= 1;
    });
  }

  Future<void> _favorited(int index) async {

    int oldVal = await DBProvider.db.getMessageField('favorited', data[index].id);
    int vls = oldVal == null?1:null;
    await DBProvider.db.UpdateMessage('favorited',vls, data[index].id);
    if(widget.favorited){

      currentPage = 1;
      setState(() {
        data.removeAt(index);
        messagesCount -= 1;
      });

    }else {
      setState(() {
        print("${oldVal} ${vls}");
        data[index].favorited = vls;
      });
    }
  }

  Future<void> _viewed(int index) async {

    int oldVal = await DBProvider.db.getMessageField('viewed', data[index].id);
    int vls = oldVal == null?1:null;
    await DBProvider.db.UpdateMessage('viewed',vls, data[index].id);
    setState(() {
      print("${oldVal} ${vls}");
      data[index].viewed = vls;
    });
  }

  Widget ExpensionPanel(int index){
    return new ExpansionTile(
      initiallyExpanded: false,
      onExpansionChanged: (bool target){
        if(target &&  data[index].viewed == null){
          _viewed(index);
        }
      },
      backgroundColor: Colors.black12,
      key: Key(data[index].title+'_'+index.toString()),
      leading: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 10.0,
            height: 5.0,
            decoration: BoxDecoration(
                color: data[index].viewed == null?Colors.red:null,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 10.0, style: BorderStyle.none)

            ),
          ),
          Container(
            child: data[index].favorited == null?Icon(Icons.star_border, color: Colors.blue, size: 25.0,):Icon(Icons.star, color: Colors.blue, size: 25.0,),
          ),
//              CircleAvatar(
//                child: Text(data[index].title[0]),
//                backgroundColor: Colors.amber,
//              ),
        ],
      ),
      title: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.spaceBetween,
        children: <Widget>[
          Text(data[index].title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 14.0),),
          Text(data[index].insert_date, maxLines: 2, style: TextStyle(fontSize: 14.0),),
        ],
      ),
      children: [
        //Text("some big data some big data some big data some big data some big data")
        ListTile(title: Text(data[index].body),)
      ],
    );
  }

  Widget ExpensionPanel2(int index){
    return new ExpansionPanelList(

      expansionCallback: (int ind, bool status) {

        setState(() {
          _activeMeterIndex = _activeMeterIndex == index ? null : index;
        });
        if(_activeMeterIndex != null && data[index].viewed == null){
          _viewed(index);
        }
      },
      children: [
        new ExpansionPanel(

            isExpanded: _activeMeterIndex == index,

            headerBuilder: (BuildContext context, bool isExpanded){
              return new  Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(width: 2.0,),
                  Container(
                    width: 10.0,
                    height: 5.0,
                    decoration: BoxDecoration(
                        color: data[index].viewed == null?Colors.red:null,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red, width: 10.0, style: BorderStyle.none)

                    ),
                  ),
                  SizedBox(width: 2.0,),
                  GestureDetector(
                    child: Container(
                      child: FittedBox(
                        child: data[index].favorited == null?Icon(Icons.star_border, color: Colors.blue, size: 30.0,):Icon(Icons.star, color: Colors.blue, size: 30.0,),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    onTap: () => _favorited(index),
                  ),
                  SizedBox(width: 5.0,),
                  //              CircleAvatar(
                  //                child: Text(data[index].title[0]),
                  //                backgroundColor: Colors.amber,
                  //              ),

                  Text(data[index].title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 14.0),),
                  SizedBox(width: 100.0,),
                  Text(data[index].insert_date, maxLines: 2, style: TextStyle(fontSize: 14.0),),
                ],

              );
            },
            body: ListTile(title: Text(data[index].body),)
        ),

      ],

    );
  }
}


