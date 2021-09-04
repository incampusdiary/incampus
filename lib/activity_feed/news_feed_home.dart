import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:incampusdiary/vetometer/vetometer_screen_astra.dart';

var firestore = FirebaseFirestore.instance;

class NewsFeedHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // var providerFalse = Provider.of<NewsFeedData>(context, listen: false);

    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            child: InkWell(
                onTap: () {
                  print('Profile Pressed');
                },
                child:
                    Image.network(FirebaseAuth.instance.currentUser.photoURL)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            width: 100,
            height: 100,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                  onTap: () {
                    print('Category Pressed');
                  },
                  child: Icon(
                    Icons.category_outlined,
                    color: Colors.blue,
                    size: 100,
                  )),
              InkWell(
                  onTap: () {
                    print('Settings pressed');
                  },
                  child: Icon(Icons.settings_sharp,
                      size: 100, color: Colors.grey)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  print('Vetometer Pressed');
                  Navigator.pushNamed(context, VetometerScreen.id);
                },
                child: Image.asset(
                  'images/vetometer-logo.png',
                  height: 100,
                  width: 100,
                ),
              ),
              InkWell(
                onTap: () async {
                  print('Notes pressed');
                },
                child: SvgPicture.asset(
                  'images/notes.svg',
                  height: 100,
                  width: 100,
                ),
              ),
            ],
          ),
          InkWell(
              onTap: () {
                print('Add new Post pressed');
              },
              child: Image.asset('images/button.png', height: 80, width: 80)),
        ],
      ),
    );
  }
}
