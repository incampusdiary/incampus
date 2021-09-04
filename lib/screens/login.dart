import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incampusdiary/vetometer/vetometer_screen_astra.dart';
import '../services/google.dart';
import 'signup.dart';
import '../widgets.dart';
import 'package:validators/validators.dart';
import 'package:flutter_svg/svg.dart';

class LoginScreen extends StatefulWidget {
  static const id = "login";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;

  String email;
  String password;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: kGradientColor,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      /* InCampus Logo */
                      Padding(
                        padding: const EdgeInsets.only(top: 48.0, left: 16.0),
                        //Todo: Add duration later on.
                        child: Hero(
                          tag: "logo",
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: logoTitle('InCampus Diary', 22.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 100),

                      /* Sign In Heading */
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontFamily: "Nunito",
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),

                      /* Email TextField Widget */
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 16.0, left: 16.0, right: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 1, color: Colors.white),
                          ),

                          //Todo: Add validator() in email and password.

                          child: TextField(
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.singleLineFormatter,
                              FilteringTextInputFormatter.deny(RegExp("[, ]")),
                            ],
                            decoration: InputDecoration(
                              enabledBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.white),
                              prefixIcon: Icon(
                                Icons.mail_outline,
                                size: 18,
                                color: Colors.white,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                email = value;
                              });
                            },
                          ),
                        ),
                      ),

                      /* Password TextField Widget */
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 16.0, left: 16.0, right: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 1, color: Colors.white),
                          ),
                          child: TextField(
                              obscureText: true,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                              decoration: InputDecoration(
                                enabledBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Colors.white),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.singleLineFormatter
                              ],
                              onChanged: (value) {
                                setState(() {
                                  password = value;
                                });
                              }),
                        ),
                      ),

                      /* Forgot Password */
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 16.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: () {
                              //Todo: Navigate to Phone Verification screen.
                              print("Print: Forget Password");
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.grey[200],
                              ),
                            ),
                          ),
                        ),
                      ),

                      /* Remember Me */
                      Row(
                        children: [
                          Theme(
                            data: ThemeData(
                              unselectedWidgetColor: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, left: 16.0, bottom: 8),
                              child: Checkbox(
                                value: rememberMe,
                                activeColor: Colors.lightGreenAccent[700],
                                onChanged: (value) {
                                  rememberMe = value;
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                          Text(
                            'Remember Me',
                            style: TextStyle(
                              color: Colors.blueGrey[50],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      /* Sign In Button */
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 5.0, left: 16.0, right: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            if (email == null || email.isEmpty)
                              showSnackBar("Enter Email");
                            else if (!isEmail(email))
                              showSnackBar("Enter a Valid Email.");
                            else if (password == null || password.isEmpty)
                              showSnackBar('Enter Password');
                            else if (password.length > 15)
                              showSnackBar("Wrong Password");
                            else {
                              FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: email, password: password)
                                  .then((value) {
                              }).catchError((e) {
                                print(e);
                                String _snackText, msg = e.code;
                                if (msg == 'user-not-found') {
                                  _snackText = "No User Found";
                                } else if (msg == 'wrong-password') {
                                  _snackText = "Wrong Password";
                                } else {
                                  _snackText = "Something Went Wrong";
                                }
                                showSnackBar(_snackText);
                              });
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xFF5192FE),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(5, 10),
                                    blurRadius: 10),
                              ],
                            ),
                            child: Center(
                              child: Text('Sign in',
                                  style: TextStyle(
                                    fontFamily: "Nunito",
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Container(
                        height: 2,
                        width: 100,
                        color: Colors.lightGreenAccent.shade700,
                      ),
                      SizedBox(height: 30),

                      /* Sign in with Authentication */
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            /*Sign in Google */
                            GestureDetector(
                              onTap: () async {
                                  var currentUser = await signInWithGoogle();
                                  if(currentUser != null) {
                                    Navigator.pushNamed(context, VetometerScreen.id);
                                  }
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SvgPicture.asset(
                                    'images/google.svg',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),

                      /* Navigation to Sign up Page */
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No Account',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              )),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUp()));
                            },
                            child: Text(' ?    Create New Account',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }

  final kGradientColor = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF0052D4), Color(0xFF6FB1FC)],
    ),
  );

  showSnackBar(String _snackText) {
    final snackBar = SnackBar(
      content: Text(
        _snackText,
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.red.shade700,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
