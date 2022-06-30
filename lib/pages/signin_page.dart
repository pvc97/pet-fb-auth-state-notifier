import '../models/custom_error.dart';
import '../providers/providers.dart';
import '../utils/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:provider/provider.dart';

import 'signup_page.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);

  static const String routeName = "/signin";

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  String? _email, _password;

  Future<void> _submit() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    final form = _formKey.currentState;

    if (form == null || !form.validate()) return;

    form.save();

    print('email: $_email, password: $_password');

    try {
      await context
          .read<SigninProvider>()
          .signin(email: _email!, password: _password!);
    } on CustomError catch (e) {
      errorDialog(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SigninState signinState = context.watch<SigninState>();

    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidateMode,
                child: ListView(
                  shrinkWrap: true,
                  reverse: true,
                  children: [
                    Image.asset(
                      'assets/images/flutter_logo.png',
                      width: 250,
                      height: 250,
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        filled: true,
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email required";
                        }

                        if (!isEmail(value.trim())) {
                          return "Enter a valid email";
                        }

                        return null;
                      },
                      onSaved: (String? value) {
                        _email = value;
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      autocorrect: false,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                        filled: true,
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Password required";
                        }

                        if (value.trim().length < 6) {
                          return "Password is at least 6 characters long";
                        }

                        return null;
                      },
                      onSaved: (String? value) {
                        _password = value;
                      },
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed:
                          signinState.signinStatus == SigninStatus.submitting
                              ? null
                              : _submit,
                      child: Text(
                        signinState.signinStatus == SigninStatus.submitting
                            ? "Loading..."
                            : "Sign In",
                      ),
                    ),
                    SizedBox(height: 10.0),
                    TextButton(
                      onPressed:
                          signinState.signinStatus == SigninStatus.submitting
                              ? null
                              : () {
                                  Navigator.pushNamed(
                                      context, SignupPage.routeName);
                                },
                      child: Text('Not a member? Sign up!'),
                      style: TextButton.styleFrom(
                        textStyle: TextStyle(
                          fontSize: 20.0,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ].reversed.toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
