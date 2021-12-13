import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flyerchat/auth/sign_up.dart';
import 'auth/authentication.dart';
import 'package:flyerchat/models/chatitem.dart';
import 'package:flyerchat/flyerchat.dart';
import 'package:flyerchat/models/datarepository.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key, required User user})
      : _user = user,
        super(key: key);
  final User _user;

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late User _firebaseUser;
  late types.User _flyerchatUser;
  int _selectIndex = 0;
  bool _isSigningOut = false;

  @override
  void initState() {
    _firebaseUser = widget._user;
    _flyerchatUser = types.User(id: _firebaseUser.uid);
    super.initState();
  }

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const Signup(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accApp = Scaffold(
        backgroundColor: Colors.blueGrey,
        body: Center(
            child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(),
                    _firebaseUser.photoURL != null
                        ? ClipOval(
                            child: Material(
                              color: Colors.orange.withOpacity(0.3),
                              child: Image.network(
                                _firebaseUser.photoURL!,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          )
                        : ClipOval(
                            child: Material(
                              color: Colors.orange.withOpacity(0.3),
                              child: const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Logged in as',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      _firebaseUser.displayName == null
                          ? 'Anonymous'
                          : _firebaseUser.displayName.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text('(${_firebaseUser.email!})',
                        style: (const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 0.5,
                        ))),
                    const SizedBox(height: 16.0),
                    _isSigningOut
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: SignInButtonBuilder(
                              text: "Logout From FlyerChat",
                              icon: Icons.logout,
                              onPressed: () async {
                                setState(() {
                                  _isSigningOut = true;
                                });
                                await Authentication.signOut(context: context);
                                setState(() {
                                  _isSigningOut = false;
                                });
                                Navigator.of(context)
                                    .pushReplacement(_routeToSignInScreen());
                              },
                              backgroundColor: Colors.blueGrey[700]!,
                            )),
                  ],
                ))));

    Widget _buildContactList(BuildContext context, types.User user) {
      return Card(
        elevation: 3.0,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration:
              const BoxDecoration(color: Color.fromRGBO(34, 105, 196, 0.9)),
          child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              leading: Container(
                  padding: const EdgeInsets.only(right: 12.0),
                  decoration: const BoxDecoration(
                      border: Border(
                          right: BorderSide(width: 1.0, color: Colors.white))),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orange.withOpacity(0.9),
                      child: Image.network(
                        _firebaseUser.photoURL!,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  )),
              title: Text(
                user.firstName!,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: <Widget>[
                  const Icon(Icons.linear_scale, color: Colors.yellow),
                  Text(
                      DateTime.fromMillisecondsSinceEpoch(
                              user.createdAt!.toInt())
                          .toString(),
                      style: const TextStyle(
                          color: Colors.amber, fontWeight: FontWeight.bold)),
                ],
              ),
              trailing: InkWell(
                  child: const Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.white,
                    size: 30.0,
                  ),
                  onTap: () {})),
        ),
      );
    }

    final chatListApp = StreamBuilder<List<types.User>>(
        stream: FirebaseChatCore.instance.users(),
        initialData: const [],
        builder: (context, snapshot) {
          return ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 20.0),
            children: snapshot.data!
                .map((e) => _buildContactList(context, e))
                .toList(),
          );
        });

    final agentScheduleApp = Container(child: (Text('Agent Schedule')));

    final flyerChatSelections = DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              flexibleSpace: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  TabBar(
                    tabs: [
                      Tab(text: 'Chat'),
                      Tab(text: 'Schedules'),
                    ],
                  )
                ],
              ),
            ),
            body: TabBarView(
              children: [chatListApp, agentScheduleApp],
            )));

    final List<Widget> _pages = <Widget>[flyerChatSelections, accApp];

    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: const Color.fromRGBO(108, 66, 6, 0.0),
      title: const Text(
          'FlyerChat'), //Image.asset('assets/icon/Seeker Logo.png',height: 64,),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.list),
          onPressed: () {},
        )
      ],
    );

    return Scaffold(
      appBar: topAppBar,
      body: IndexedStack(
        index: _selectIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 15,
        selectedIconTheme:
            const IconThemeData(color: Colors.amberAccent, size: 40),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        selectedItemColor: Colors.amberAccent,
        backgroundColor: Colors.orangeAccent,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Account',
          ),
        ],
        currentIndex: _selectIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
