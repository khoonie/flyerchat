import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flyerchat/auth/authentication.dart';
import 'package:flyerchat/auth/email_login.dart';
import 'package:flyerchat/auth/email_signup.dart';
import 'package:flyerchat/menu.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class Signup extends StatelessWidget {
  const Signup({Key? key}) : super(key: key);

  final String title = "Sign Up";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("FlyerChat Sign Up",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          fontFamily: 'Roboto')),
                ),
                FutureBuilder(
                    future: Authentication.initializeFirebase(context: context),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Error Initializing Firebase');
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        return const GoogleSignInButton();
                      }
                      return const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange,
                        ),
                      );
                    }),
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SignInButton(
                      Buttons.Email,
                      text: "Sign up with Email",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EmailSignUp()),
                        );
                      },
                    )),
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SignInButtonBuilder(
                      text: "Sign in Anonymously",
                      icon: Icons.cake,
                      onPressed: () async {
                        UserCredential user =
                            await FirebaseAuth.instance.signInAnonymously();
                        // TODO: set call to sign in

                        if (user.user != null) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => Menu(
                                user: user.user!,
                              ),
                            ),
                          );
                        }
                      },
                      backgroundColor: Colors.blueGrey[700]!,
                    )),
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                        child: const Text("Log In Using Email",
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EmailLogIn()),
                          );
                        }))
              ]),
        ));
  }
}

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({Key? key}) : super(key: key);

  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 0.0),
        child: _isSigningIn
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : SignInButton(
                Buttons.Google,
                text: "Sign in with Google",
                onPressed: () async {
                  setState(() {
                    _isSigningIn = true;
                  });

                  User? user =
                      await Authentication.signInWithGoogle(context: context);
                  // TODO: set call to sign in

                  setState(() {
                    _isSigningIn = false;
                  });

                  if (user != null) {
                    await FirebaseChatCore.instance.createUserInFirestore(
                      types.User(
                          firstName: user.displayName,
                          id: user.uid,
                          imageUrl: user.photoURL,
                          lastName: user.displayName),
                    );

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => Menu(
                          user: user,
                        ),
                      ),
                    );
                  }
                },
              ));
  }
}
