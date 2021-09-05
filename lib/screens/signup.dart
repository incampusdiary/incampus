import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:incampusdiary/vetometer/vetometer_screen_astra.dart';
import 'login_astra.dart';
import '../widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  static const id = "signup";
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  bool rememberMe = false;

  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,

        decoration: BoxDecoration(
          gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF0052D4), Color(0xFF6FB1FC)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    /* InCampus Logo */
                    Padding(
                      padding: const EdgeInsets.only(top: 48.0, left: 16.0),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: logoTitle('InCampus', 22.0),
                      ),
                    ),
                    SizedBox(height: 100),

                    /* Connect to the World Heading */
                    Text(
                      'Connect to the World !',
                      style: TextStyle(
                        fontFamily: "Nunito",
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),

                    /* TextField Widgets */
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0),
                      child: TextFieldWidget(
                        hintText: 'Name',
                        obscureText: false,
                        prefixIconData: Icons.person,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius : BorderRadius.circular(10),
                          border: Border.all(width: 1, color: Colors.white),
                        ),
                        child: TextField(
                          obscureText: false,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                          ),
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
                          }
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius : BorderRadius.circular(10),
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
                          onChanged: (value) {
                            setState(() {
                              password = value;
                            });
                          }
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                      child: TextFieldWidget(
                        hintText: 'Confirm Password',
                        obscureText: false,
                        prefixIconData: Icons.lock_outline,
                      ),
                    ),

                    SizedBox(height: 40),

                    /* Permission for Volunteering */
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 8.0, bottom: 8),
                          child: Container(
                            child: GestureDetector(
                              onTap: () {
                                rememberMe = !rememberMe;
                                setState(() {
                                });
                              },
                              child: SvgPicture.asset(
                                rememberMe ? 'images/check_box.svg' : 'images/uncheck_box.svg',
                                height: 16,
                                width: 16,
                              ),
                            )
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Do You want to Volunteer others ?',
                            style: TextStyle(
                              color: Colors.white70,
                            )
                          ),
                        )
                      ],
                    ),

                    /* Register Button */
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, left: 16.0, right: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: email, password: password)
                              .then((signedInUser) {
                                FirebaseFirestore.instance.collection('users')
                                  .add({'email': email, 'pass' : password })
                                .then((value){
                                  if(signedInUser != null) {
                                    Navigator.pushNamed(context, VetometerScreen.id);
                                  }
                                }).catchError((e) {
                                  print(e);
                              });
                            }).catchError((e){
                              print(e);
                          });
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
                          ),
                          child: Center(
                            child: Text(
                              'REGISTER',
                              style: TextStyle(
                                fontFamily: "Nunito",
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              )
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 75),

                    /* Navigation to Sign in Page */
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already Have an Account',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          )
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                          },
                          child: Text(
                              '? Sign in',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              )
                          ),
                        ),
                      ],
                    ),
                  ]
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}
