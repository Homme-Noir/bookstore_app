import 'package:flutter/material.dart';
import 'login.dart';
import 'signUp.dart';

class AuthenticatePage extends StatefulWidget {
  const AuthenticatePage({super.key});

  @override
  _AuthenticatePageState createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<AuthenticatePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(237, 237, 237, 1.0),
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text('Book Store'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.lock), text: "Login"),
              Tab(icon: Icon(Icons.person), text: 'Register'),
            ],
            indicatorColor: Colors.pink,
            indicatorWeight: 5.0,
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ///RegisterPage(),
            Login(),
            Register(),
          ],
        ),
      ),
    );
  }
}
