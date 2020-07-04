import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:places_app/model/user.dart';

class AuthForm extends StatefulWidget {
  AuthForm(
    this.submitFn,
    this.isLoading,
  );
  final bool isLoading;
  final void Function(
    User user,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> with TickerProviderStateMixin {
  bool _isLogin = true;

  final _formKey = GlobalKey<FormState>();

  User _user = User();

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(_user, _isLogin, context);
    }
  }

  Widget _buildEmailField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      key: ValueKey('email'),
      validator: (value) {
        if (value.isEmpty || !value.contains('@')) {
          return 'Please enter a valid email address.';
        }
        return null;
      },
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
      ),
      onSaved: (value) {
        _user.email = value;
      },
    );
  }

  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Widget _buildDisplayName() {
    return TextFormField(
      key: ValueKey('displayName'),
      validator: (value) {
        if (value.isEmpty || value.length < 4) {
          return 'Please enter at least 4 characters';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Display name',
      ),
      onSaved: (value) {
        _user.displayName = value;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      key: ValueKey('password'),
      validator: (value) {
        if (value.isEmpty || value.length < 6) {
          return 'Password must be at least 6 characters long.';
        }
        return null;
      },
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: 'Password',
        suffixIcon: GestureDetector(
          onTap: _toggle,
          child: _obscureText == false
              ? Icon(Icons.visibility)
              : Icon(Icons.visibility_off),
        ),
      ),
      onSaved: (value) {
        _user.password = value;
      },
    );
  }

  Widget _buildButton() {
    return Container(
      // height: 66,
      padding: EdgeInsets.all(16),
      width: 300,
      child: RaisedButton(
        child: Text(
          _isLogin ? 'LOG IN ' : 'SIGN UP',
        ),
        padding: EdgeInsets.all(15),
        color: Colors.blue[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 12.0,
        textColor: Colors.white,
        onPressed: () => _trySubmit(),
      ),
    );
  }

  TabController _controller;

  Future<void> resetPassword() async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();

      try {
        setState(() {
          _isLoadingResetPassword = true;
        });
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _user.email);
      } catch (err) {
        var message = 'An error occurred, pelase check your credentials!';

        if (err.message != null) {
          message = err.message;
        }
        setState(() {
          _isLoadingResetPassword = false;
        });
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      }
      setState(() {
        _isLoadingResetPassword = false;
      });
    }
  }

  @override
  void initState() {
    _controller = new TabController(length: 2, vsync: this);
    super.initState();
  }

  var _isLoadingResetPassword = false;
  var _resetPassord = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  AuthCredential authCredential;
  void googleSignIn() async {
    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      authCredential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    } catch (err) {}
    FirebaseUser user = (await _auth.signInWithCredential(authCredential)).user;

    Firestore.instance
        .collection('Users')
        .reference()
        .document(user.uid)
        .setData({
      'username': user.displayName,
      'email': user.email,
    }, merge: true);

    //  return user;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.20,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue[900], Colors.blue[200]]),
              ),
            ),
            Container(
              height: 48,
              color: Colors.transparent,
              child: DefaultTabController(
                length: 2,
                initialIndex: 0,
                child: Column(
                  children: [
                    TabBar(
                        controller: _controller,
                        labelStyle: TextStyle(fontSize: 17),
                        onTap: (index) {
                          setState(() {
                            index == 0 ? _isLogin = true : _isLogin = false;
                            FocusScope.of(context).unfocus();
                          });
                        },
                        labelColor: Colors.black,
                        indicator: UnderlineTabIndicator(
                            borderSide: BorderSide(
                                width: 5.0,
                                color: Color.fromRGBO(27, 65, 204, 1))),
                        unselectedLabelColor: Colors.white,
                        unselectedLabelStyle:
                            TextStyle(fontWeight: FontWeight.bold),
                        tabs: <Widget>[
                          Tab(
                            text: 'Sign in',
                          ),
                          Tab(text: 'Sign up')
                        ]),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              color: Colors.grey[100],
              height: MediaQuery.of(context).size.height * 0.80,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _controller,
                    children: [
                      Column(
                        children: <Widget>[
                          if (_resetPassord != false) ...[
                            Text(
                              'Reset Password',
                              style: TextStyle(fontSize: 18),
                            ),
                            _buildEmailField(),
                            SizedBox(
                              height: 18,
                            ),
                            _isLoadingResetPassword == true
                                ? CircularProgressIndicator()
                                : MaterialButton(
                                    color: Colors.yellow,
                                    child: Text('Submit'),
                                    onPressed: () {
                                      setState(() {
                                        resetPassword();
                                      });
                                    },
                                  ),
                            SizedBox(
                              height: 25,
                            ),
                            InkWell(
                              child: Text('Return to Sign in'),
                              onTap: () {
                                setState(() {
                                  _resetPassord = false;
                                });
                              },
                            ),
                          ] else ...[
                            _buildEmailField(),
                            SizedBox(
                              height: 20,
                            ),
                            _buildPasswordField(),
                            SizedBox(
                              height: 16,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: InkWell(
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline),
                                  textAlign: TextAlign.end,
                                ),
                                onTap: () {
                                  setState(() {
                                    _resetPassord = true;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            if (widget.isLoading) CircularProgressIndicator(),
                            if (!widget.isLoading) _buildButton(),
                            SizedBox(
                              height: 30,
                            ),
                            MaterialButton(
                              onPressed: () => googleSignIn(),
                              child: Text('Sign in with google'),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 52,
                              width: 52,
                              child: RaisedButton(
                                padding: EdgeInsets.all(0),
                                onPressed: googleSignIn,
                                child: Image.asset(
                                    'assets/images/google_icon.png'),
                                color: Colors.grey[200],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          _buildEmailField(),
                          SizedBox(
                            height: 20,
                          ),
                          _buildPasswordField(),
                          SizedBox(
                            height: 20,
                          ),
                          _buildDisplayName(),
                          if (widget.isLoading) CircularProgressIndicator(),
                          if (!widget.isLoading) _buildButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
