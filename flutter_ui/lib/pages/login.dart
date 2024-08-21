import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_ui/main.dart';
import 'package:flutter_ui/pages/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const users = {
  'dribbble@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
};

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  final String basePath =
      'https://m1yf7zt55f.execute-api.us-east-2.amazonaws.com/Dev';

  Future<String?> _authUser(LoginData data) async {
    debugPrint('Email: ${data.name}, Password: ${data.password}');
    //TODO implement authentication
    var headers = {
      'Content-Type': 'application/json',
    };

    var postBody = {
      "email": data.name,
      "password": data.password,
    };

    final response = await http.post(
      Uri.parse('$basePath/login'),
      headers: headers,
      body: json.encode(postBody),
    );

    if (response.statusCode == 200) {
      //Success return null to return user to the Home Page
      auth = response.body;
      email = data.name;
      debugPrint('Auth: $auth');
      return null;
    } else {
      //Error print the response error as a snack bar at the bottom.
      return response.body;
    }
  }

  Future<String?> _signupUser(SignupData data) async {
    //Communicates with aws API gateway and posts a user to the db
    debugPrint('Signup Email: ${data.name}, Password: ${data.password}');
    var postBody = {
      "email": data.name,
      "password": data.password,
    };
    final response = await http.post(
      Uri.parse('$basePath/user'),
      body: json.encode(postBody),
    );

    debugPrint('Response Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      //Success return null to return user to the Home Page
      auth = response.body;
      debugPrint('Auth: $auth');
      return null;
    } else {
      //Error print the response error as a snack bar at the bottom.
      return response.body;
    }
  }

  Future<String?> _recoverPassword(String name) async {
    debugPrint('Name: $name');
    var postBody = {
      "email": name,
    };
    final response = await http.post(
      Uri.parse('$basePath/user/forgot-password'),
      body: json.encode(postBody),
    );
    if (response.statusCode == 200) {
      //Success return null to return user to the Home Page
      auth = response.body;
      debugPrint('Auth: $auth');
      return null;
    } else {
      //Error print the response error as a snack bar at the bottom.
      return response.body;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave'),
        backgroundColor: const Color.fromARGB(255, 103, 80, 164),
      ),
      body: FlutterLogin(
        title: 'Data Sculptor',
        scrollable: true,
        userType: LoginUserType.email,
        logo: const AssetImage('assets/images/Logo.png'),
        onLogin: _authUser,
        onSignup: _signupUser,
        onSubmitAnimationCompleted: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const HomePage(),
          ));
        },
        onRecoverPassword: _recoverPassword,
        onConfirmRecover: _confirmRecoverPassword,
      ),
    );
  }

  Future<String?>? _confirmRecoverPassword(String p1, LoginData p2) async {
    debugPrint('p1: $p1, LoginData: $p2');

    final response = await http.put(
      Uri.parse('$basePath/user'),
      body: json.encode(
        {
          "email": p2.name,
          "old_password": p1,
          "new_password": p2.password,
        },
      ),
    );
    auth = response.body;
    return null;
  }
}
