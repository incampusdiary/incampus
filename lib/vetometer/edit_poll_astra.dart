import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incampusdiary/models/vetometer/edit_poll_model.dart';
import 'package:incampusdiary/models/vetometer/vetometer_background.dart';
import 'view_poll_astra.dart';
import 'package:provider/provider.dart';
import '../rounded_button.dart';
import 'package:validators/validators.dart';
import 'package:http/http.dart' as http;

class VetometerEditPoll extends StatefulWidget {
  static const id = "vetometer_edit_poll";

  @override
  _VetometerEditPollState createState() => _VetometerEditPollState();
}

class _VetometerEditPollState extends State<VetometerEditPoll> {
  final firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final bool originalAccessibility =
      pollModel.password != null || pollModel.password != '';
  var access;
  @override
  void initState() {
    super.initState();
    var providerFalse = Provider.of<EditPollModel>(context, listen: false);
    providerFalse.initializeEditPoll();
  }

  void exit() {
    pollModel.pollOptions.clear();
    print(pollModel.pollOptions);
    Provider.of<EditPollModel>(context, listen: false).dispose();
  }

  @override
  Widget build(BuildContext context) {
    var providerTrue = Provider.of<EditPollModel>(context);
    var providerFalse = Provider.of<EditPollModel>(context, listen: false);

    final Map documents = ModalRoute.of(context).settings.arguments as Map;
    final document = documents['first'];
    final documentId = documents['pollId'];
    pollModel.fromJson(document);
    print('Edit Poll Entered: ${pollModel.title}');

    return WillPopScope(
      //Todo: Check its working
      onWillPop: () async {
        dispose();
        return true;
      },
      child: VetometerBackground(
        lightColor: Colors.yellowAccent,
        darkColor: Colors.yellowAccent[700],
        glowColor: Colors.yellow,
        blinkingAnimation: true,
        headerTitle: "Edit Poll",
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 200.0),

              /*  Title of the Poll*/
              Padding(
                padding: EdgeInsets.only(left: 32.0, right: 32.0),
                child: Text(
                  'Title of the Poll',
                  style: kTextStyle,
                ),
              ),
              PollTextFormField(
                initialValue: pollModel.title,
                onSaved: (value) {
                  pollModel.title = value.trim();
                },
                radius: 10,
                onChanged: (value) {},
                validator: (String value) {
                  if (value.isEmpty)
                    return "Required";
                  else if (isNumeric(value))
                    return 'Invalid Title';
                  else if (value.toLowerCase().trim() == 'mass bunk')
                    return 'Mention Stream';
                  return null;
                },
                color: Color(0xFF0077FF),
                fontWeight: FontWeight.w900,
                verticalPadding: 8,
                contentPadding: false,
              ),

              /* Description of the Poll */
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Poll Description',
                  style: kTextStyle,
                ),
              ),
              PollTextFormField(
                initialValue: pollModel.pollDescription,
                onSaved: (value) {
                  pollModel.pollDescription = value.trim();
                },
                radius: 10.0,
                contentPadding: false,
                verticalPadding: 8,
                textAlign: false,
                automaticNext: false,
                maxLength: null,
                minLines: 4,
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Required";
                  else if (isNumeric(value)) return 'Invalid Description';
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 32, right: 32, top: 32),
                child: Text(
                  'Poll Options',
                  style: kTextStyle.copyWith(fontStyle: FontStyle.normal),
                ),
              ),
              SizedBox(height: 20),

              /* Accessibility Button */
              Padding(
                padding: const EdgeInsets.only(left: 32, right: 24, top: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Text(
                            'Accessibility',
                            style: kTextStyle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 4),
                          child: Text(
                            providerTrue.private
                                ? 'This is only accessible with a PASSWORD'
                                : 'This is PUBLICLY accessible',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      onChanged: (value) {
                        providerFalse.changeprivate();
                        if (!originalAccessibility && !value)
                          pollModel.password = null;
                        pollModel.accessibility = value;
                        access = value;
                        print('Switch changed: ${pollModel.accessibility}');
                      },
                      value: providerTrue.private,
                      activeColor: Colors.blue,
                      activeTrackColor: Colors.lightGreenAccent.shade700,
                      inactiveThumbColor: Colors.blue,
                      inactiveTrackColor: Colors.greenAccent.shade100,
                    ),
                  ],
                ),
              ),

              /* Auto-Password Field */
              Visibility(
                visible: providerTrue.private,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: PollTextFormField(
                    onSaved: (value) {
                      if (!originalAccessibility)
                        pollModel.password = value.toString();
                    },
                    radius: 10,
                    maxLength: 5,
                    readOnly: true,
                    initialValue: originalAccessibility
                        ? pollModel.password
                        : generatePassword(),
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),

              //  Response Limit Setter
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 32, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maximum Responses Selectable',
                      style: kTextStyle,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              boxShadow: kContainerElevation,
                            ),
                            child: Center(
                              child: Text(
                                providerTrue.responseLimit.toString(),
                                textAlign: TextAlign.center,
                                style: kTextStyle.copyWith(
                                  color: Colors.black,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        SizedBox(width: 10),
                        // Container(
                        //   width: 40,
                        //   height: 40,
                        //   decoration: BoxDecoration(
                        //     color: Colors.redAccent,
                        //     boxShadow: kContainerElevation,
                        //   ),
                        //   child: IconButton(
                        //     icon: Icon(
                        //       Icons.remove_circle_outline,
                        //       color: Colors.white,
                        //       size: 24,
                        //     ),
                        //     onPressed: () {
                        //       print('Print: Decrement');
                        //       var responseLimit =
                        //           providerFalse.responseLimit;
                        //       if (responseLimit > 1)
                        //         providerFalse.responseLimitDecrement();
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),

              /* Update & Delete Button */
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Column(
                  children: [
                    /*  Update Poll Button  */
                    RoundedButton(
                      title: 'Update Poll',
                      onPressed: () async {
                        print('Updated: $access  ${pollModel.accessibility}');
                        print(pollModel.toMap());
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          pollModel.accessibility = access;
                          updatePoll(documentId, pollModel.toMap());
                          isEdited = true;
                          print('PollModel updated: ${pollModel.toMap()}');
                          Navigator.pop(context, pollModel.toMap());
                        } else
                          showSnackBar('Invalid Fields Found!');
                      },
                      color: Colors.blue,
                    ),
                    SizedBox(height: 20),

                    /* Delete Poll Button */
                    RoundedButton(
                      title: 'Delete Poll',
                      onPressed: () async {
                        try {
                          deletePollFromPolls(documentId);
                          deleteUserResponseFromUserPoll(documentId);
                          deleteVotesFromPollCounters(documentId);
                        } catch (e) {
                          print('Exception occured during deletion: $e');
                        }
                        Navigator.pop(context);
                        Navigator.pop(context, documentId);
                      },
                      color: Colors.redAccent,
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        positionedWidget: SizedBox(height: 0, width: 0),
      ),
    );
  }

  /* Call this only when it was a private poll originally.  */
  String generatePassword() {
    var _random = Random();
    var _password = _random.nextInt(90000) + 10000;
    return _password.toString();
  }

  final kTextStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
    color: Colors.white,
  );

  showSnackBar(String _snackText) {
    final snackBar = SnackBar(
      content: Text(
        _snackText,
        style: TextStyle(
          fontSize: 22,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.red.shade700,
    );
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  updatePoll(pollId, data) async {
    /* UPDATE HTTP REQUEST */
    final url = '$headerUrl/polls/$pollId';
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          "X-Cassandra-Token": "$ASTRA_DB_APPLICATION_TOKEN",
          "Content-Type": "application/json"
        },
        body: json.encode(
          data,
        ),
      );
      print("JSON DATA");
      print(json.decode(response.body));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      print(error);
    }
  }

  Future deletePollFromPolls(pollId) async {
    final url = '$headerUrl/polls/$pollId';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "X-Cassandra-Token": "$ASTRA_DB_APPLICATION_TOKEN",
          "Content-Type": "application/json"
        },
      );
    } catch (error) {
      print(error);
    }
  }

  Future deleteUserResponseFromUserPoll(pollId) async {
    final url = '$headerUrl/userPoll/$currentUserId/$pollId';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "X-Cassandra-Token": "$ASTRA_DB_APPLICATION_TOKEN",
          "Content-Type": "application/json"
        },
      );
    } catch (error) {
      print(error);
    }
  }

  Future deleteVotesFromPollCounters(pollId) async {
    final url =
        'https://$ASTRA_DB_ID-$ASTRA_DB_REGION.apps.astra.datastax.com/api/rest/v2/keyspaces/$ASTRA_DB_KEYSPACE/pollCounters/$pollId';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "X-Cassandra-Token": "$ASTRA_DB_APPLICATION_TOKEN",
          "Content-Type": "application/json",
        },
      );
      print("Poll Counter of Poll ID: $pollId Deleted");
    } catch (error) {
      print(error);
    }
  }
}

const int kCharacterCountLimit = 120;

class PollTextFormField extends StatelessWidget {
  final keyboardType;
  final letterSpacing;
  final Function onSaved;
  final index;
  final textCapitalization;
  final int maxLength;
  final int maxLines;
  final int minLines;
  final Function onChanged;
  final deniedRegExp;
  final allowedRegExp;
  final Function validator;
  final autoValidateMode;
  final Color color;
  final FontWeight fontWeight;
  final double verticalPadding;
  final double horizontalPadding;
  final bool contentPadding;
  final double radius;
  final prefixIcon;
  final suffixIcon;
  final bool textAlign;
  final bool readOnly;
  final bool automaticNext;
  final width;
  final String initialValue;

  PollTextFormField({
    @required this.initialValue,
    @required this.onSaved,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.minLines = 1,
    this.width = double.infinity,
    this.prefixIcon,
    this.readOnly = false,
    this.automaticNext = true,
    this.contentPadding = true,
    this.index,
    this.verticalPadding = 0.0,
    this.horizontalPadding = 16.0,
    this.letterSpacing,
    this.maxLength = kCharacterCountLimit,
    this.maxLines = 3,
    this.textCapitalization = TextCapitalization.sentences,
    this.autoValidateMode = AutovalidateMode.onUserInteraction,
    this.validator,
    this.deniedRegExp = "[, ./!']",
    this.allowedRegExp = false,
    this.radius = 0.0,
    this.color = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.textAlign = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: verticalPadding, horizontal: horizontalPadding),
      child: Container(
        width: width,
        decoration: BoxDecoration(boxShadow: kContainerElevation),
        child: TextFormField(
          autocorrect: false,
          textCapitalization: textCapitalization,
          enabled: true,
          maxLength: maxLength,
          minLines: minLines,
          maxLines: maxLines,
          initialValue: initialValue,
          readOnly: readOnly,
          textAlign: textAlign ? TextAlign.center : TextAlign.start,
          cursorHeight: 20,
          style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing),
          decoration: InputDecoration(
            // focusColor: Colors.red,
            hintMaxLines: 5,
            counterText: '',
            contentPadding: contentPadding ? const EdgeInsets.all(0) : null,
            filled: true,
            fillColor: Colors.white,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            hintStyle:
                TextStyle(color: Colors.black54, fontWeight: FontWeight.normal),
            enabled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(radius)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 0),
              borderRadius: BorderRadius.all(Radius.circular(radius)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.greenAccent, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(radius)),
            ),
          ),
          keyboardType: TextInputType.multiline,
          textInputAction:
              automaticNext ? TextInputAction.next : TextInputAction.newline,
          inputFormatters: [
            // allowedRegExp
            //     : FilteringTextInputFormatter.deny(RegExp(deniedRegExp)),
          ],
          onFieldSubmitted: onChanged,
          onSaved: onSaved,
          autovalidateMode: autoValidateMode,
          validator: validator,
        ),
      ),
    );
  }
}
