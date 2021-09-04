// import 'dart:math';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:in_campus_diary/models/add_poll_model.dart';
// import 'package:provider/provider.dart';
// import '../rounded_button.dart';
// import 'package:in_campus_diary/models/add_poll_options_model.dart';
// import 'package:validators/validators.dart';
//
// class VetometerEditPoll extends StatefulWidget {
//   static const id = "vetometer_edit_poll";
//
//   @override
//   _VetometerEditPollState createState() => _VetometerEditPollState();
// }
//
// PollModel _pollModel = PollModel();
//
// class _VetometerEditPollState extends State<VetometerEditPoll> {
//   final firestore = FirebaseFirestore.instance;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   @override
//   void initState() {
//     super.initState();
//     try {
//       print(Provider.of<AddPollModel>(context, listen: false).optionsList);
//       print(_pollModel.pollOptions);
//       addInitialPoll();
//     } on Exception catch (e) {
//       print('Print: Error Occured: $e');
//     }
//   }
//
//   void exit() {
//     _pollModel.pollOptions.clear();
//     print(_pollModel.pollOptions);
//     Provider.of<AddPollModel>(context, listen: false).dispose();
//   }
//
//   void addInitialPoll() {
//     Provider.of<AddPollModel>(context, listen: false)
//         .addNewPollOption(0, _pollModel);
//     Provider.of<AddPollModel>(context, listen: false)
//         .addNewPollOption(1, _pollModel);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final Map documents = ModalRoute.of(context).settings.arguments as Map;
//     final document = documents['first'];
//     print('Edit Poll Entered: ${document.data()}');
//     Provider.of<AddPollModel>(context, listen: false).responseLimit =
//     document['responseLimit'];
//     // Provider.of<AddPollModel>(context, listen: false).privacy =
//     //     document['accessibility'];
//
//     return WillPopScope(
//       //Todo: Check its working
//       onWillPop: () async {
//         dispose();
//         return true;
//       },
//       child: Scaffold(
//         body: Container(
//           height: MediaQuery.of(context).size.height,
//           width: MediaQuery.of(context).size.width,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               colors: [Color(0xFF4364F7), Color(0xFF6FB1FC)],
//             ),
//           ),
//           child: Stack(
//             children: [
//               ClipPath(
//                 clipper: ThemeClipper(),
//                 child: Container(
//                   height: MediaQuery.of(context).size.height * 0.75,
//                   width: MediaQuery.of(context).size.width,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [Color(0xFF6FB1FC), Color(0xFF38597E)],
//                     ),
//                   ),
//                 ),
//               ),
//               SingleChildScrollView(
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 200.0),
//
//                       Padding(
//                         padding: EdgeInsets.only(left: 32.0, right: 32.0),
//                         child: Text(
//                           'Title of the Poll',
//                           style: kTextStyle,
//                         ),
//                       ),
//                       PollTextFormField(
//                         initialValue: document.get('title'),
//                         onSaved: (value) {
//                           _pollModel.title = value.trim();
//                         },
//                         radius: 10,
//                         onChanged: (value) {},
//                         validator: (String value) {
//                           if (value.isEmpty)
//                             return "Required";
//                           else if (isNumeric(value))
//                             return 'Invalid Title';
//                           else if (value.toLowerCase().trim() == 'mass bunk')
//                             return 'Mention Stream';
//                           return null;
//                         },
//                         color: Color(0xFF0077FF),
//                         fontWeight: FontWeight.w900,
//                         verticalPadding: 8,
//                         contentPadding: false,
//                       ),
//
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 32),
//                         child: Text(
//                           'Poll Description',
//                           style: kTextStyle,
//                         ),
//                       ),
//                       PollTextFormField(
//                         initialValue: document['pollDescription'],
//                         onSaved: (value) {
//                           _pollModel.pollDescription = value.trim();
//                         },
//                         radius: 10.0,
//                         contentPadding: false,
//                         verticalPadding: 8,
//                         textAlign: false,
//                         automaticNext: false,
//                         maxLength: null,
//                         minLines: 4,
//                         maxLines: 6,
//                         validator: (value) {
//                           if (value == null || value.isEmpty)
//                             return "Required";
//                           else if (isNumeric(value))
//                             return 'Invalid Description';
//                           return null;
//                         },
//                       ),
//
//                       Padding(
//                         padding:
//                         const EdgeInsets.only(left: 32, right: 32, top: 32),
//                         child: Text(
//                           'Poll Options',
//                           style:
//                           kTextStyle.copyWith(fontStyle: FontStyle.normal),
//                         ),
//                       ),
//
//                       //Polling Fields
//                       ListView.builder(
//                         itemCount: Provider.of<AddPollModel>(context).listSize,
//                         itemBuilder: (context, index) {
//                           var currentPollOption =
//                           Provider.of<AddPollModel>(context, listen: false)
//                               .currentPollOption(index);
//                           if (currentPollOption != null)
//                             return currentPollOption;
//                           else
//                             return SizedBox(height: 0, width: 0);
//                         },
//                         physics: NeverScrollableScrollPhysics(),
//                         shrinkWrap: true,
//                       ),
//
//                       //Add New Poll Button
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 8),
//                         child: Stack(
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: GestureDetector(
//                                 onTap: () {
//                                   var pollOptionsCount =
//                                       Provider.of<AddPollModel>(context,
//                                           listen: false)
//                                           .pollOptionsCountValue;
//                                   var listSize = Provider.of<AddPollModel>(
//                                       context,
//                                       listen: false)
//                                       .listSize;
//                                   if (pollOptionsCount < 20)
//                                     Provider.of<AddPollModel>(context,
//                                         listen: false)
//                                         .addNewPollOption(listSize, _pollModel);
//                                   else
//                                     showSnackBar("Cannot create more Options!");
//                                   print('Print: New Poll Added');
//                                 },
//                                 child: Container(
//                                   height: 40,
//                                   width: double.infinity,
//                                   decoration: BoxDecoration(
//                                       color: Colors.blue,
//                                       boxShadow: kContainerElevation),
//                                 ),
//                               ),
//                             ),
//                             Center(
//                               child: Container(
//                                 height: 55,
//                                 width: 55,
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: FloatingActionButton(
//                                   onPressed: () {
//                                     var pollOptionsCount =
//                                         Provider.of<AddPollModel>(context,
//                                             listen: false)
//                                             .pollOptionsCountValue;
//                                     var listSize = Provider.of<AddPollModel>(
//                                         context,
//                                         listen: false)
//                                         .listSize;
//                                     if (pollOptionsCount < 20)
//                                       Provider.of<AddPollModel>(context,
//                                           listen: false)
//                                           .addNewPollOption(
//                                           listSize, _pollModel);
//                                     else
//                                       showSnackBar(
//                                           "Cannot create more Options!");
//                                     print('Print: New Poll Added');
//                                   },
//                                   elevation: 0,
//                                   child: Icon(
//                                     Icons.add,
//                                     size: 30,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 20),
//
//                       //Accessibility Button
//                       Padding(
//                         padding:
//                         const EdgeInsets.only(left: 32, right: 8, top: 8),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.max,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Padding(
//                                   padding:
//                                   const EdgeInsets.symmetric(horizontal: 0),
//                                   child: Text(
//                                     'Accessibility',
//                                     style: kTextStyle,
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 0, vertical: 4),
//                                   child: Text(
//                                     Provider.of<AddPollModel>(context).privacy
//                                         ? 'This is only accessible with a PASSWORD'
//                                         : 'This is PUBLICLY accessible',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 14,
//                                       fontStyle: FontStyle.normal,
//                                       fontWeight: FontWeight.w100,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Switch(
//                               onChanged: (value) {
//                                 Provider.of<AddPollModel>(context,
//                                     listen: false)
//                                     .changePrivacy();
//                                 if (!value) _pollModel.password = null;
//                                 _pollModel.accessibility = value;
//                                 print(
//                                     'Switch changed: ${_pollModel.accessibility}');
//                               },
//                               value: Provider.of<AddPollModel>(context).privacy,
//                               activeColor: Colors.blue,
//                               activeTrackColor:
//                               Colors.lightGreenAccent.shade700,
//                               inactiveThumbColor: Colors.blue,
//                               inactiveTrackColor: Colors.greenAccent.shade100,
//                             )
//                           ],
//                         ),
//                       ),
//
//                       //Auto-Password Field
//                       Visibility(
//                         visible: Provider.of<AddPollModel>(context).privacy,
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 16),
//                           child: PollTextFormField(
//                             onSaved: (value) {
//                               _pollModel.password = value.toString();
//                             },
//                             radius: 10,
//                             maxLength: 5,
//                             readOnly: true,
//                             initialValue: document.get('password'),
//                             letterSpacing: 4.0,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.redAccent,
//                           ),
//                         ),
//                       ),
//
//                       /*  Response Limit Setter   */
//                       SizedBox(height: 20),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 32, right: 16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Maximum Responses Selectable',
//                               style: kTextStyle,
//                             ),
//                             SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Container(
//                                     height: 40,
//                                     width: 40,
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       shape: BoxShape.rectangle,
//                                       boxShadow: kContainerElevation,
//                                     ),
//                                     child: Center(
//                                       child: Text(
//                                         Provider.of<AddPollModel>(context)
//                                             .responseLimit
//                                             .toString(),
//                                         textAlign: TextAlign.center,
//                                         style: kTextStyle.copyWith(
//                                           color: Colors.black,
//                                           fontStyle: FontStyle.normal,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: 10),
//                                 Container(
//                                   width: 40,
//                                   height: 40,
//                                   decoration: BoxDecoration(
//                                     color: Colors.indigoAccent,
//                                     boxShadow: kContainerElevation,
//                                   ),
//                                   child: IconButton(
//                                     icon: Icon(
//                                       Icons.add_circle_outline,
//                                       color: Colors.white,
//                                       size: 24,
//                                     ),
//                                     onPressed: () {
//                                       print('Print: Increment');
//                                       var responseLimit =
//                                           Provider.of<AddPollModel>(context,
//                                               listen: false)
//                                               .responseLimit;
//                                       var pollOptionsCount =
//                                           Provider.of<AddPollModel>(context,
//                                               listen: false)
//                                               .pollOptionsCountValue;
//                                       if (responseLimit < pollOptionsCount - 1)
//                                         Provider.of<AddPollModel>(context,
//                                             listen: false)
//                                             .responseLimitIncrement(_pollModel);
//                                       else
//                                         showSnackBar(
//                                             'You have only $pollOptionsCount options!');
//                                     },
//                                   ),
//                                 ),
//                                 SizedBox(width: 10),
//                                 Container(
//                                   width: 40,
//                                   height: 40,
//                                   decoration: BoxDecoration(
//                                     color: Colors.redAccent,
//                                     boxShadow: kContainerElevation,
//                                   ),
//                                   child: IconButton(
//                                     icon: Icon(
//                                       Icons.remove_circle_outline,
//                                       color: Colors.white,
//                                       size: 24,
//                                     ),
//                                     onPressed: () {
//                                       print('Print: Decrement');
//                                       var responseLimit =
//                                           Provider.of<AddPollModel>(context,
//                                               listen: false)
//                                               .responseLimit;
//                                       if (responseLimit > 1)
//                                         Provider.of<AddPollModel>(context,
//                                             listen: false)
//                                             .responseLimitDecrement(_pollModel);
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       //Create, Update, Delete Button
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 32),
//                         child: Column(
//                           children: [
//                             /*  Update Poll Button  */
//                             RoundedButton(
//                               title: 'Update Poll',
//                               //Todo:
//                               onPressed: () {
//                                 print(document.get('password'));
//                               },
//                               color: Colors.blue,
//                             ),
//
//                             SizedBox(height: 20),
//
//                             //Delete Poll Button
//                             RoundedButton(
//                               title: 'Delete Poll',
//                               //Todo:
//                               onPressed: () {},
//                               color: Colors.redAccent,
//                             ),
//                             SizedBox(height: 16),
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//
//               /*  Header  */
//               Positioned(
//                 child: Container(
//                   height: MediaQuery.of(context).size.height * 0.18,
//                   width: MediaQuery.of(context).size.width,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [Color(0xFF479DFF), Color(0xFF38597E)],
//                     ),
//                     borderRadius: BorderRadius.only(
//                       bottomLeft: Radius.circular(50),
//                       bottomRight: Radius.circular(50),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Color(0xFF151627).withOpacity(0.8),
//                         blurRadius: 6,
//                         offset: Offset(10, 8), // changes position of shadow
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.only(top: 32),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Hero(
//                           tag: "vetometer logo",
//                           child: Image.asset(
//                             'images/vetometer-logo.png',
//                             height: 50.0,
//                             width: 50.0,
//                           ),
//                         ),
//                         SizedBox(width: 15),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'Vetometer',
//                               style: TextStyle(
//                                 fontFamily: "Merienda",
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.w700,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             SizedBox(height: 5),
//                             Row(
//                               children: [
//                                 Container(
//                                   height: 5.0,
//                                   width: 5.0,
//                                   decoration: BoxDecoration(
//                                     color: Colors.greenAccent,
//                                     shape: BoxShape.circle,
//                                   ),
//                                 ),
//                                 SizedBox(width: 5),
//                                 Text(
//                                   'Edit Poll',
//                                   style: TextStyle(
//                                     fontFamily: "Nunito",
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w700,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   //Todo: Call this only when it was a private poll originally.
//   String generatePassword() {
//     var _random = Random();
//     var _password = _random.nextInt(90000) + 10000;
//     return _password.toString();
//   }
//
//   final kTextStyle = TextStyle(
//     fontSize: 20.0,
//     fontWeight: FontWeight.bold,
//     fontStyle: FontStyle.italic,
//     color: Colors.white,
//   );
//
//   showSnackBar(String _snackText) {
//     final snackBar = SnackBar(
//       content: Text(
//         _snackText,
//         style: TextStyle(
//           fontSize: 22,
//           color: Colors.white,
//         ),
//         textAlign: TextAlign.center,
//       ),
//       duration: Duration(seconds: 2),
//       backgroundColor: Colors.red.shade700,
//     );
//     ScaffoldMessenger.of(context).removeCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }
// }
//
// class ThemeClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     var path = Path();
//     path.lineTo(0, size.height);
//     path.lineTo(size.width, size.height * 0.4);
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return true;
//   }
// }
//
// const int kCharacterCountLimit = 120;
//
// class PollTextFormField extends StatelessWidget {
//   final keyboardType;
//   final letterSpacing;
//   final Function onSaved;
//   final index;
//   final textCapitalization;
//   final int maxLength;
//   final int maxLines;
//   final int minLines;
//   final Function onChanged;
//   final deniedRegExp;
//   final allowedRegExp;
//   final Function validator;
//   final autoValidateMode;
//   final Color color;
//   final FontWeight fontWeight;
//   final double verticalPadding;
//   final double horizontalPadding;
//   final bool contentPadding;
//   final double radius;
//   final prefixIcon;
//   final suffixIcon;
//   final bool textAlign;
//   final bool readOnly;
//   final bool automaticNext;
//   final width;
//   final String initialValue;
//
//   PollTextFormField({
//     @required this.initialValue,
//     @required this.onSaved,
//     this.onChanged,
//     this.keyboardType = TextInputType.text,
//     this.suffixIcon,
//     this.minLines = 1,
//     this.width = double.infinity,
//     this.prefixIcon,
//     this.readOnly = false,
//     this.automaticNext = true,
//     this.contentPadding = true,
//     this.index,
//     this.verticalPadding = 0.0,
//     this.horizontalPadding = 16.0,
//     this.letterSpacing,
//     this.maxLength = kCharacterCountLimit,
//     this.maxLines = 3,
//     this.textCapitalization = TextCapitalization.sentences,
//     this.autoValidateMode = AutovalidateMode.onUserInteraction,
//     this.validator,
//     this.deniedRegExp = "[, ./!']",
//     this.allowedRegExp = false,
//     this.radius = 0.0,
//     this.color = Colors.black,
//     this.fontWeight = FontWeight.normal,
//     this.textAlign = true,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//           vertical: verticalPadding, horizontal: horizontalPadding),
//       child: Container(
//         width: width,
//         decoration: BoxDecoration(boxShadow: kContainerElevation),
//         child: TextFormField(
//           autocorrect: false,
//           textCapitalization: textCapitalization,
//           enabled: true,
//           maxLength: maxLength,
//           minLines: minLines,
//           maxLines: maxLines,
//           initialValue: initialValue,
//           readOnly: readOnly,
//           textAlign: textAlign ? TextAlign.center : TextAlign.start,
//           cursorHeight: 20,
//           style: TextStyle(
//               fontSize: 18,
//               color: color,
//               fontWeight: fontWeight,
//               letterSpacing: letterSpacing),
//           decoration: InputDecoration(
//             // focusColor: Colors.red,
//             hintMaxLines: 5,
//             counterText: '',
//             contentPadding: contentPadding ? const EdgeInsets.all(0) : null,
//             filled: true,
//             fillColor: Colors.white,
//             prefixIcon: prefixIcon,
//             suffixIcon: suffixIcon,
//             hintStyle:
//             TextStyle(color: Colors.black54, fontWeight: FontWeight.normal),
//             enabled: true,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(radius)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: Colors.white, width: 0),
//               borderRadius: BorderRadius.all(Radius.circular(radius)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: Colors.greenAccent, width: 2),
//               borderRadius: BorderRadius.all(Radius.circular(radius)),
//             ),
//           ),
//           keyboardType: TextInputType.multiline,
//           textInputAction:
//           automaticNext ? TextInputAction.next : TextInputAction.newline,
//           inputFormatters: [
//             // allowedRegExp
//             //     : FilteringTextInputFormatter.deny(RegExp(deniedRegExp)),
//           ],
//           onFieldSubmitted: onChanged,
//           onSaved: onSaved,
//           autovalidateMode: autoValidateMode,
//           validator: validator,
//         ),
//       ),
//     );
//   }
// }
//
// var kContainerElevation = [
//   BoxShadow(color: Colors.black38, offset: Offset(10, 10), blurRadius: 10)
// ];

import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var _firestore = FirebaseFirestore.instance;
  var data = await _firestore
      .collection("userPoll")
      .doc(FirebaseAuth.instance.currentUser.uid)
      .collection("pollId")
      .get();

  HashMap<String, List> arr = HashMap();
  var s = [];
  for (var d in data.docs) {
    arr[d.id] = d["selectedPolls"];
    print(arr);
  }
  if (arr.containsKey("FzydLYQ9uhboLvEYzTvz"))
    print(arr["FzydLYQ9uhboLvEYzTvz"]);
  else
    print(arr);
  // print('selectPoll $selectPoll');
  // print(selectPoll.data());
}
