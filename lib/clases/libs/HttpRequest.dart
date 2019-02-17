import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:async';
import 'dart:io';
import 'package:crypto/src/digest_sink.dart';
//import 'package:flutter/material.dart';
import 'dart:convert';

class Post {


  //String IPAddress = 'https://192.168.0.48:8181/';
  String IPAddress = 'https://178.134.198.58:8181/';

  Future<Map> fetchPost(Map<String, String> body, String path,{context}) async {

    String hsh = 'myshstring:';
    Map<String, String> snd = body;

    snd.forEach((String key, String value){
      if(key != 'hsh' && key != 'permissions')
        hsh += key+''+value.toString();
    });
    //var hmacSha256 = new Hmac(sha1, utf8.encode(hsh));
    var ds = new DigestSink();
    var s = sha1.startChunkedConversion(ds);
    s.add(utf8.encode(hsh));
    s.close();
    snd['hsh'] = ds.value.toString();


    //var client = new http.Client();

    bool trustSelfSigned = true;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => trustSelfSigned);
    http.IOClient client = new http.IOClient(httpClient);
    //print("dialog status is: "+dialogStatus.toString());
    http.Response res;
    // ignore: unused_local_variable
    int statusCode = 0;


    try{

      res = await client.post(
        IPAddress+path,
        headers: {
          "Accept": "*/*",
          "Accept-Language": "en-US,en;q=0.5",
          "Content-Type": "application/x-www-form-urlencoded",
          "Connection": "keep-alive",
          "User-Agent": "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:35.0) Gecko/20100101 Firefox/35.0 its_operator_browser"
        },
        body: snd,
        //encoding: Utf8Codec()
      );

      statusCode = res.statusCode;

      print(IPAddress+path);
      print(res.body);
      var data = await json.decode(res.body);
      if(data != null && (data is List<dynamic>) == false) {
        return data;
      }else
        throw new Exception('custom');
    }catch(e){
      print(e.toString());


      return await Map<String, dynamic>();
    }



  }

}