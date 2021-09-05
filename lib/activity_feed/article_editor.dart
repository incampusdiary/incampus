import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incampusdiary/constants.dart';
import 'package:incampusdiary/main.dart';
import 'package:incampusdiary/models/news_feed/post_model.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'article_viewer.dart';
import 'comments.dart';
import 'news_feed_astra.dart';

class ArticleEditor extends StatefulWidget {
  static final id = 'article-editor';
  final bool isEditing;

  ArticleEditor({
    this.isEditing = false,
  });

  @override
  _ArticleEditorState createState() => _ArticleEditorState();
}

final Reference storageRef = FirebaseStorage.instance.ref();

class _ArticleEditorState extends State<ArticleEditor>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  TextEditingController _textController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  ScrollController _scrollbarController = ScrollController();

  /// Stores the image that is (last) uploaded in the article
  File file;
  String mediaUrl;
  String imageUrl;

  List<String> imageLinks = [];

  int lastTextFieldFocusPosition = 0;
  bool isListBulletsActive = false, isBulletShown = false;

  RegExp exp = RegExp(r'(?:!\[(.*?)\]\((.*?)\))');

  final Color white = darkModeOn ? Color(0xFF141820) : Colors.white;
  final Color black = darkModeOn ? Colors.white : Colors.black;
  final Color blue = Color(0xFF096EFA);
  final Color greenBG = Colors.green[50];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(handleTabSelection);

    if (widget.isEditing) {
      String str = post.description;
      Iterable matches = exp.allMatches(str);
      matches.forEach((match) {
        String matchedImageMarkDown = str.substring(match.start, match.end);
        for (int i = 0; i < matchedImageMarkDown.length; i++) {
          if (matchedImageMarkDown[i] == '(') {
            String matchedUrl = matchedImageMarkDown.substring(
                i + 1, matchedImageMarkDown.length - 1);
            imageLinks.add(matchedUrl);
            break;
          }
        }
      });
    }

    print('Editable Post: ${widget.isEditing}');

    _textController.text = widget.isEditing ? post.description : '';
    _titleController.text = widget.isEditing ? post.title : '';

  }

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    print('Article Editor Called');
    print('Article Editor: ${post.description}');

    final currentUser = FirebaseAuth.instance.currentUser;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return WillPopScope(
        onWillPop: () async {
          return await showDialog(
            context: context,
            builder: (_) => showDialogue(
              context,
              titleColor: Color(0xFF16CA8D),
              content:
                  "All changes made to this article will be lost, if you don't save it.\n\n Are you sure?",
              contentColor: Color(0xFF16CA8D),
            ),
          );
        },
        child: Scaffold(
          backgroundColor: greenBG,
          resizeToAvoidBottomInset: false,
          floatingActionButton: publishButton(),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0.0,
            backgroundColor: greenBG,
            elevation: 0,
            title: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Text(
                    "Editing",
                    style: TextStyle(color: black),
                  ),
                ),
                Tab(
                  child: Text(
                    "Preview",
                    style: TextStyle(color: black),
                  ),
                ),
              ],
            ),
          ),
          body: Container(
            height: height,
            width: width,
            color: Colors.green[50],
            child: TabBarView(
              controller: _tabController,
              children: [

                /// Editing Page
                Container(
                  color: greenBG,
                  child: Stack(
                    children: [
                      /// Editor's TextField
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              Container(
                                color: greenBG,
                                margin: EdgeInsets.only(
                                    left: 6, right: 6, bottom: 24, top: 140),
                                child: TextFormField(
                                  autofocus: true,
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  controller: _textController,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "Nunito",
                                    color: black,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Write your mind..",
                                    hintStyle: TextStyle(
                                      fontSize: 18,
                                      color: black.withOpacity(0.6),
                                      fontFamily: "Nunito",
                                    ),
                                  ),
                                  onChanged: (val) {
                                    final cursorPosition =
                                        _textController.selection.extentOffset;

                                    if (cursorPosition > 0 &&
                                        val[cursorPosition - 1] == '\n') {
                                      var len = val.length;
                                      var left =
                                          val.substring(0, cursorPosition - 1);

                                      if (left.length + 1 == val.length) {
                                        left += "  \n";
                                        val = left;

                                        _textController.text = val;
                                        _textController.selection =
                                            TextSelection.fromPosition(
                                          TextPosition(offset: val.length),
                                        );
                                      } else {
                                        var right =
                                            val.substring(cursorPosition, len);
                                        left += "  \n";

                                        val = left + right;

                                        _textController.text = val;
                                        _textController.selection =
                                            TextSelection.fromPosition(
                                          TextPosition(offset: left.length),
                                        );
                                      }
                                      print(val);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// Editor's Features for Styling text & Title TextField
                      Positioned(
                        top: 0,
                        left: 20,
                        right: 20,
                        child: Column(
                          children: [
                            /// Editor's Features for Styling text
                            Container(
                              color: greenBG,
                              height: 65,
                              width: width,
                              child: Scrollbar(
                                controller: _scrollbarController,
                                isAlwaysShown: true,
                                showTrackOnHover: false,

                                /// List of icons
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  controller: _scrollbarController,
                                  shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 22),
                                      child: InkWell(
                                        child: Text(
                                          'H1',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: black,
                                          ),
                                        ),
                                        onTap: () =>
                                            _surroundTextSelection('# ', ''),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 22),
                                      child: InkWell(
                                        child: Text(
                                          'H2',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: black,
                                          ),
                                        ),
                                        onTap: () =>
                                            _surroundTextSelection('## ', ''),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 22),
                                      child: InkWell(
                                        child: Text(
                                          'H3',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: black,
                                          ),
                                        ),
                                        onTap: () =>
                                            _surroundTextSelection('### ', ''),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Bold',
                                      icon: Icon(Icons.format_bold),
                                      color: black,
                                      onPressed: () => _surroundTextSelection(
                                        '**',
                                        '**',
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Indent',
                                      icon: Icon(Icons.format_italic),
                                      color: black,
                                      onPressed: () => _surroundTextSelection(
                                        '*',
                                        '*',
                                      ),
                                    ),
                                    IconButton(
                                        tooltip: 'List',
                                        icon: Icon(Icons.list),
                                        color: black,
                                        onPressed: () {
                                          print('List called');
                                          _surroundTextSelection(
                                            '* ',
                                            '\n',
                                          );
                                        }),
                                    IconButton(
                                      tooltip: 'Code',
                                      icon: Icon(Icons.code),
                                      color: black,
                                      onPressed: () => _surroundTextSelection(
                                        '```\n',
                                        '\n```',
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Image Link',
                                      icon: Icon(Icons.image),
                                      color: black,
                                      onPressed: () async {
                                        imageUrl = Uuid().v4();
                                        file = null;
                                        mediaUrl = '';
                                        if (_textController
                                                .selection.extentOffset !=
                                            -1) {
                                          lastTextFieldFocusPosition =
                                              _textController
                                                  .selection.extentOffset;
                                        }
                                        await selectImage(context);
                                      },
                                    ),
                                    IconButton(
                                      tooltip: 'Link',
                                      icon: Icon(Icons.link_sharp),
                                      color: black,
                                      onPressed: () => _surroundTextSelection(
                                        '[title](https://',
                                        ')',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            /// Title TextField
                            Container(
                              width: width,
                              color: greenBG,
                              padding: EdgeInsets.only(left: 6, top: 10),
                              child: TextFormField(
                                maxLines: 1,
                                keyboardType: TextInputType.text,
                                controller: _titleController,
                                style: TextStyle(
                                  fontSize: 40,
                                  fontFamily: "Nunito",
                                  color: black,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Title",
                                  hintStyle: TextStyle(
                                    fontSize: 28,
                                    color: black.withOpacity(0.6),
                                    fontFamily: "Nunito",
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onChanged: (val) {
                                  print(val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                ///Preview Page
                SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 48.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 35,
                                      width: 90,
                                      color: blue,
                                      child: Center(
                                        child: Text(
                                          'Article',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: white,
                                            fontFamily: "Nunito",
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    SvgPicture.asset(
                                      'images/calendar.svg',
                                      height: 25,
                                      width: 25,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      currentDateTime(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: black.withOpacity(0.7),
                                        fontFamily: "Nunito",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 25),
                                Text(
                                  _titleController.text,
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: black,
                                    fontFamily: "Nunito",
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 25),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(currentUser.photoURL),
                                        radius: 25,
                                      ),
                                      SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              currentUser.displayName,
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: black,
                                                fontFamily: "Nunito",
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'CSE, Heritage Institute of Technology',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: black.withOpacity(0.8),
                                                fontFamily: "Nunito",
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          Stack(
                            children: [
                              Center(
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 2),
                                  color: black.withOpacity(0.85),
                                  width: width * 0.8,
                                  height: 1,
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: blue,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    width: width * 0.3,
                                    height: 5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 25),
                          Markdown(
                            shrinkWrap: true,
                            selectable: true,
                            physics: NeverScrollableScrollPhysics(),
                            data: _textController.text,
                            onTapLink: (text, url, title) {
                              print(url);
                              _launchURL(url);
                            },
                            styleSheet: MarkdownStyleSheet(
                              h1: TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                color: darkModeOn ? blue : Colors.indigo,
                              ),
                              h2: TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 27,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                              h3: TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: black,
                              ),
                              em: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                              p: TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: black,
                              ),
                              strong: TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: black,
                              ),
                              code: TextStyle(
                                fontSize: 15,
                                backgroundColor: Colors.transparent,
                              ),
                              codeblockPadding: EdgeInsets.all(16),
                              blockquoteDecoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              blockquotePadding:
                                  EdgeInsets.symmetric(vertical: 20),
                              codeblockDecoration: BoxDecoration(
                                color: Colors.grey[100],
                              ),
                              codeblockAlign: WrapAlignment.start,
                              listBullet: TextStyle(fontFamily: "Nunito"),
                              tableHead: TextStyle(fontFamily: "Nunito"),
                              tableBody: TextStyle(fontFamily: "Nunito"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ));
  }

  publishButton() {
    return (_tabController.index == 1)
        ? FloatingActionButton(
            onPressed: () {
              if ((_titleController?.text?.isNotEmpty ?? false) &&
                  _textController.text.isNotEmpty) {
                if (!widget.isEditing) {
                  PostModel uploadArticle = PostModel();

                  uploadArticle.postId = Uuid().v4();
                  uploadArticle.userId = FirebaseAuth.instance.currentUser.uid;
                  uploadArticle.mediaUrl = '';
                  uploadArticle.description = _textController.text;
                  uploadArticle.tag = 'article';
                  uploadArticle.userPhotoUrl =
                      FirebaseAuth.instance.currentUser.photoURL;
                  uploadArticle.title = _titleController.text;
                  uploadArticle.isFullScreen = true;
                  uploadArticle.timestamp = Timestamp.now();

                  /// Store in Firestore
                  FirebaseFirestore.instance
                      .collection('posts')
                      .doc(uploadArticle.postId)
                      .set(uploadArticle.toMap());

                  FirebaseFirestore.instance
                      .collection('userInfo')
                      .doc(currentUser.uid)
                      .collection('myPosts')
                      .doc(uploadArticle.postId)
                      .set(uploadArticle.toMap());

                  postModelList.add(uploadArticle);

                  Navigator.of(context)
                      .popUntil(ModalRoute.withName(NewsFeed.id));
                } else {
                  post.description = _textController.text.trim();
                  post.title = _titleController.text.trim();
                  post.editedTimestamp = Timestamp.now();

                  FirebaseFirestore.instance
                      .collection('posts')
                      .doc(post.postId)
                      .update({
                    'title': post.title,
                    'description': post.description,
                    'editedTimestamp': post.editedTimestamp,
                  });

                  print('In Article Editor');
                  print(post.description);

                  Navigator.of(context)
                      .popUntil(ModalRoute.withName(NewsFeed.id));
                }
                deleteUnwantedImages();
              }
            },
            backgroundColor: Color(0xFF16CA8D),
            child: Icon(
              Icons.check_sharp,
              color: Colors.white,
            ))
        : SizedBox();
  }

  void deleteUnwantedImages() async {
    String description = _textController.text;

    for (int i = 0; i < imageLinks.length; i++) {
      if (!description.contains(imageLinks[i])) {
        print('Found Unwanted Image');
        print(imageLinks[i]);
        await deleteImage(imageLinks[i]);
      }
    }
  }

  Future<void> deleteImage(String imageLink) async {
    print('Delete Image Started');

    try {
      var photo = FirebaseStorage.instance.refFromURL(imageLink);
      await photo.delete();

      print('Delete Success');
    } catch (e) {
      debugPrint('Error : $e');
      print('Delete Failed');
    }
  }

  void handleTabSelection() {
    int tabIndex = _tabController.index;
    if (tabIndex == 1) {
      if (_textController.selection.extentOffset != -1) {
        lastTextFieldFocusPosition = _textController.selection.extentOffset;
      }
      FocusScope.of(context).unfocus();
    } else {
      _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: lastTextFieldFocusPosition));
    }
    setState(() {});
  }

  void _surroundTextSelection(String left, String right) {
    final currentTextValue = _textController.value.text;
    final selection = _textController.selection;

    final middle = selection.textInside(currentTextValue);
    final newTextValue = selection.textBefore(currentTextValue) +
        '$left$middle$right' +
        selection.textAfter(currentTextValue);

    _textController.value = _textController.value.copyWith(
      text: newTextValue,
      selection: TextSelection.collapsed(
        offset: selection.baseOffset + left.length + middle.length,
      ),
    );
  }

  selectImage(BuildContext context) {
    print('Select Image');
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24, 36, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SimpleDialogOption(
                      child: Image.asset(
                        'images/camera_icon.png',
                        height: 50,
                        width: 55,
                      ),
                      onPressed: () async {
                        await handleTakePhoto();
                      }),
                  SimpleDialogOption(
                      child: Image.asset(
                        'images/folder.png',
                        height: 50,
                        width: 55,
                      ),
                      onPressed: () async {
                        await handleChooseFromGallery();
                      }),
                ],
              ),
            ),
            Center(
              child: SimpleDialogOption(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.red.withOpacity(0.8),
                  ),
                  child: MaterialButton(
                    height: 0,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  handleTakePhoto() async {
    print('Handle Take Photo');
    Navigator.pop(context);
    PickedFile selectedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
    );
    setState(() {
      this.file = File(selectedFile.path);
    });
    await cropImage();
  }

  handleChooseFromGallery() async {
    print('Handle Choose From Gallery');
    Navigator.pop(context);

    PickedFile selectedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      this.file = File(selectedFile.path);
    });

    await cropImage();
  }

  Future<void> cropImage() async {
    print('Crop Image');

    File cropped;

    cropped = await ImageCropper.cropImage(
      sourcePath: file.path,
      compressQuality: 100,
      // aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: 900,
      maxHeight: 900,
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Resize your Image',
        toolbarColor: Colors.blue,
        toolbarWidgetColor: white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
    );

    if (cropped == null) {
      showToast(message: 'Upload Failed');
    } else {
      file = cropped;
      print('Image Cropped');
      await handleSubmit();
    }
  }

  handleSubmit() async {
    print('Handle Submit Started');

    /* Firebase Storage */
    mediaUrl = await uploadImage(file);

    print('Await Select Image End : $mediaUrl');
    if (mediaUrl != '') {
      _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: lastTextFieldFocusPosition));

      _surroundTextSelection(
        '> \n![]($mediaUrl',
        ') \n>',
      );
      imageLinks.add(mediaUrl);
      print('Image Link Added: $mediaUrl');
    }
  }

  Future<String> uploadImage(File imageFile) async {
    print('Uploading');

    UploadTask uploadTask =
        storageRef.child("post_$imageUrl.jpg").putFile(imageFile);

    TaskSnapshot storageSnap = await uploadTask;

    String downloadURL = await storageSnap.ref.getDownloadURL();
    print('Download URL: $downloadURL');

    return downloadURL;
  }

  void _launchURL(url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  currentDateTime() {
    var day = DateTime.now().day.toString();
    var month = DateTime.now().month;
    var year = DateTime.now().year.toString();

    var monthName = monthList[month];
    String date = '$monthName $day, $year';

    return date;
  }
}

/* TODOS */

/// Implementation of List
/// Edit Article Option
