
import 'package:engaztask/components/custom_text_field.dart';
import 'package:engaztask/pages/map.dart';
import 'package:engaztask/services/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../home.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _phone = TextEditingController();

  final TextEditingController _password = TextEditingController();
  bool _passwordSecure = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(70),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 25,
              ),
              Image.asset(
                'assets/logos/logo.jpg',
              ),
              Column(
                children: [
                  CustomTextField(title: 'Phone', controller: _phone,type: TextInputType.phone),
                  const SizedBox(height: 16),
                  CustomTextField(
                      title: 'Password',
                      controller: _password,
                      secureText: _passwordSecure,
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            _passwordSecure = !_passwordSecure;
                          });
                        },
                        icon: _passwordSecure
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                      )),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(onPressed: (){}, child:  const Text('Forget your Password?',style: TextStyle(color: Colors.black),)),
                ],
              ),
              if(_isLoading)
                Center(child: Transform.scale(scale: 0.5,child: CircularProgressIndicator()),),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async{
                  setState(() {
                    _isLoading= true;
                  });
                  final fcmToken = await FirebaseMessaging.instance.getToken();
                  await Provider.of<APIService>(context,listen: false).login(userPhone: _phone.text, password: _password.text, userFirebaseToken: fcmToken.toString()).then((val){
                    setState(() {
                      _isLoading= false;
                    });
                    if(val == false){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wrong username or password')));
                    }else{
                      print(val);
                      setState(() {
                        Provider.of<APIService>(context,listen: false).token = val['data']['UserToken'];
                        Provider.of<APIService>(context,listen: false).userId = val['data']['UsersID'];
                      });
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>  map(),));
                    }
                  });

                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.lightBlueAccent),
                    fixedSize: MaterialStateProperty.all(
                        Size(MediaQuery.of(context).size.width, 40))),
                child: const Text('Login'),
              ),
              const SizedBox(
                height: 20,
              ),
              Visibility(
                visible: _isLoading,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 25,
              ),

            ],
          ),
        ),
      ),
    );
  }
}