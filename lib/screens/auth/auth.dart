import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  var _enteredPassword = '';

  void _submit() {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    print(_enteredEmail);
    print(_enteredPassword);
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
                            : addHeight(5),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(),
                          onPressed: () {
                            _submit();
                            setState(() {
                              _isLogin = !_isLogin;
                            });
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
