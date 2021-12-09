import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flyerchat/auth/sign_up.dart';

import 'auth/authentication.dart';

class FlyerChat extends StatefulWidget {
  const FlyerChat({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _FlyerChatState createState() => _FlyerChatState();
}

class _FlyerChatState extends State<FlyerChat> {
  final List<types.Message> _messages = [];
  //final _user = const types.User(id: '');
  var _user;
  late User _firebaseUser;
  int _selectIndex = 0;
  bool _isSigningOut = false;

  @override
  void initState() {
    _firebaseUser = widget._user;
    _user = types.User(id: widget._user.uid);
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

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: 144,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleImageSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Photo'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleFileSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('File'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleFileSelection() async {}

  void _handleImageSelection() async {}

  void _handleMessageTap(types.Message message) async {
    if (message is types.FileMessage) {
      await OpenFile.open(message.uri);
    }
  }

  void _handlePreviewDataFetched(
      types.Message message, types.PreviewData previewData) {}

  void _handleSendPressed(types.PartialText message) {}

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
                    SizedBox(height: 8.0),
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
                              text: "Logout From LivingCo",
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

    //   final agentChatApp = Container(child: (Text('Agent Chat')));

    final agentChatApp = SafeArea(
        child: Chat(
      messages: _messages,
      onAttachmentPressed: _handleAtachmentPressed,
      onMessageTap: _handleMessageTap,
      onPreviewDataFetched: _handlePreviewDataFetched,
      onSendPressed: _handleSendPressed,
      user: _user,
    ));

    final agentScheduleApp = Container(child: (Text('Agent Schedule')));

    final flyerChatSelections = DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              flexibleSpace: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const TabBar(
                    tabs: [
                      const Tab(text: 'Chat'),
                      const Tab(text: 'Schedules'),
                    ],
                  )
                ],
              ),
            ),
            body: TabBarView(
              children: [agentChatApp, agentScheduleApp],
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

/*        body: SafeArea(
            bottom: false,
            child: Chat(
              messages: _messages,
              onAttachmentPressed: _handleAtachmentPressed,
              onMessageTap: _handleMessageTap,
              onPreviewDataFetched: _handlePreviewDataFetched,
              onSendPressed: _handleSendPressed,
              user: _user,
            )), */
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