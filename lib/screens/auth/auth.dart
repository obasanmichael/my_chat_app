import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_chat_app/widgets/user_image_picker.dart';

final firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  Widget addHeight(double height) => SizedBox(height: height.h);
  Widget addWidth(double width) => SizedBox(width: width.w);
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredUserName = '';
  var _enteredPassword = '';
  File? _selecetedImage;
  var _isAuthenticating = false;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || !_isLogin && _selecetedImage == null) {
      return;
    }
    _formKey.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        // ignore: unused_local_variable
        final userCredentials = await firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentials = await firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');

        await storageRef.putFile(_selecetedImage!);
        final imageURL = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUserName,
          'email': _enteredEmail,
          'image-url': imageURL
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearMaterialBanners();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication failed.')));
    }
    setState(() {
      _isAuthenticating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Card(
          margin: EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(_isLogin
                            ? 'Sign in to your account'
                            : 'Create a New Account'),
                        addHeight(5),
                        if (!_isLogin)
                          UserImagePicker(
                            onPickImage: (_pickedImage) {
                              _selecetedImage = _pickedImage;
                            },
                          ),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your Email address'),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredEmail = value!;
                          },
                        ),
                        addHeight(5),
                        if (!_isLogin)
                          TextFormField(
                            enableSuggestions: false,
                            decoration: InputDecoration(
                              labelText: 'Username',
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length < 4) {
                                return 'Please enter at least 4 characters';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredUserName = value!;
                            },
                          ),
                        addHeight(5),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Password can\'t have less than 6 characters';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredPassword = value!;
                          },
                        ),
                        addHeight(5),
                        if (!_isAuthenticating)
                          _isLogin
                              ? Row(
                                  children: [
                                    Text('Don\'t have an account?'),
                                    addWidth(3),
                                    TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _isLogin = !_isLogin;
                                          });
                                        },
                                        child: Text('Create one'))
                                  ],
                                )
                              : Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isLogin = !_isLogin;
                                        });
                                      },
                                      child: Text('I already have an account'),
                                    )
                                  ],
                                ),
                        addHeight(5),
                        if (_isAuthenticating)
                          const CircularProgressIndicator(),
                        if (!_isAuthenticating)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(),
                            onPressed: () {
                              _submit();
                            },
                            child: Text(_isLogin ? 'Sign in' : 'Sign up'),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
