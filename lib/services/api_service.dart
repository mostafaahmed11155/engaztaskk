import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart'  ;

class APIService with ChangeNotifier{
   String webBaseUrl = 'https://engaztechnology.net/Himam/User';
   final Dio _dio = Dio();
   String? token;
   String? userId;

  login({required String userPhone, required String password,required String userFirebaseToken})async{
    Options options = Options(
        followRedirects: false,
        validateStatus: (status) => true,
        headers: {});
    var formData = FormData.fromMap({
      'UserPhone': userPhone,
      'Password': password,
      'UserFirebaseToken': userFirebaseToken
    });
    final res = await _dio.post('$webBaseUrl/LoginUser.php',data: formData,options: options).then((value) {
      if(value.statusCode == 200){
        return jsonDecode(value.data);
      }else{
        return false;
      }
    }).catchError((error){
      print(error);
      throw error;
      return false;
     });

    return res;

  }



  getMarkers()async{
    final res = await http.post(Uri.parse('$webBaseUrl/getMarkers.php',),headers: {
      'usertoken' : token!,
    }).then((value) {
      print(value.body);
      if(value.statusCode == 200){
        return jsonDecode(value.body);
      }else{
        return false;
      }
    });

    return res;

  }
}