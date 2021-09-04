import 'dart:async';
import 'dart:io';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:incampusdiary/activity_feed/article_editor.dart';
import 'package:flutter_svg/svg.dart';
import 'package:incampusdiary/activity_feed/news_feed.dart';
import 'package:incampusdiary/models/news_feed/post_model.dart';
import 'package:incampusdiary/rounded_button.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/news_feed/select_categoriesBloc.dart';

import '../constants.dart';

final Reference storageRef = FirebaseStorage.instance.ref();

class Upload extends StatefulWidget {
  static final id = 'upload';

  @override
  _UploadState createState() => _UploadState();
}

bool firstVisitInUpload = true;

class _UploadState extends State<Upload> {

  File file;
  String postId;
  String tag;
  User currentUser = FirebaseAuth.instance.currentUser;
  double percent = 0;
  bool isUploading = false;

  TextEditingController descriptionController = TextEditingController();
  SelectCategoryBloc selectCategoryBloc = SelectCategoryBloc();

  PercentIndicatorBloc percentIndicatorBloc = PercentIndicatorBloc();

  @override
  void dispose() {
    selectCategoryBloc.closeStream();
    percentIndicatorBloc.closeStream();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (firstVisitInUpload == true) {
      initialize();
      firstVisitInUpload = false;
    }
    print('Upload Image');
    return file == null ? uploadScreen() : postScreen();
  }

  initialize() {
    file = null;
    descriptionController.clear();
    postId = Uuid().v4();
    percent = 0;
  }

  Widget uploadScreen() {
    print('UploadScreen');
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFF6295CE),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/upload_background.png',
              height: size.height * 0.6,
              width: size.width * 0.8,
            ),
            RoundedButton(
              title: 'Upload Image',
              onPressed: () => selectImage(context),
              color: Colors.indigoAccent,
              minWidth: size.width * 0.8,
              borderRadius: 10,
              elevation: 5.0,
            ),
            SizedBox(height: 15),
            RoundedButton(
              title: 'Open your mind',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ArticleEditor(),
                  ),
                );
              },
              color: Color(0xFF16CA8D),
              minWidth: size.width * 0.8,
              borderRadius: 10,
              elevation: 5.0,
            ),
          ],
        ),
      ),
    );
  }

  selectImage(BuildContext context) {
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
                    onPressed: handleTakePhoto,
                  ),
                  SimpleDialogOption(
                    child: Image.asset(
                      'images/folder.png',
                      height: 50,
                      width: 55,
                    ),
                    onPressed: handleChooseFromGallery,
                  ),
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
                          color: Colors.white,
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
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
    );

    if (cropped == null) {
      firstVisitInUpload = true;
      Navigator.pushNamedAndRemoveUntil(context, Upload.id, (route) => false);
    }

    setState(() {
      file = cropped;
    });
  }

  List<bool> isFullScreenSelected = [false, true];

  postScreen() {
    print('Post Screen');
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: size.height,
              width: size.width,
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  fit: (isFullScreenSelected[1] == true)? BoxFit.fill: BoxFit.contain,
                  image: FileImage(file),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 16, 16),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    onPressed: () {},
                    child: postIcon(),
                  ),
                ),
              ),
            ),
          ),
          Align(
              alignment: Alignment.topRight,
              child: Container(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 50),
                child: ToggleButtons(
                  constraints: BoxConstraints(
                    maxHeight: 40,
                  ),
                  borderWidth: 0,
                  borderRadius: BorderRadius.zero,
                  onPressed: (int index) {
                    setState(() {
                      for (int buttonIndex = 0;
                          buttonIndex < isFullScreenSelected.length;
                          buttonIndex++) {
                        if (buttonIndex == index) {
                          isFullScreenSelected[buttonIndex] = true;
                        } else {
                          isFullScreenSelected[buttonIndex] = false;
                        }
                      }
                    });
                  },
                  isSelected: isFullScreenSelected,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      color:
                      (isFullScreenSelected[0] == true) ? Colors.blue : Colors.white,
                      child: Center(
                        child: Icon(
                          Icons.fullscreen_exit,
                          color: (isFullScreenSelected[0] == true)
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      color:
                      (isFullScreenSelected[1] == true) ? Colors.blue : Colors.white,
                      child: Center(
                        child: Icon(
                          Icons.fullscreen,
                          color: (isFullScreenSelected[1] == true)
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget postDescription() {
    selectCategoryBloc = SelectCategoryBloc();
    percentIndicatorBloc = PercentIndicatorBloc();
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        selectCategoryBloc.closeStream();
        percentIndicatorBloc.closeStream();
        tag = null;
        return true;
      },
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            fit: BoxFit.contain,
            image: FileImage(file),
          ),
        ),
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: size.width,
              color: Color(0xFF38597E).withOpacity(0.95),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 75),
                  Text(
                    'Add Description',
                    style: TextStyle(
                      fontFamily: "nunito",
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Container(
                      child: TextField(
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        controller: descriptionController,
                        autofocus: false,
                        enabled: true,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: "Write a caption..",
                          fillColor: Colors.white.withOpacity(0.8),
                          filled: true,
                          contentPadding: EdgeInsets.all(25),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  Text(
                    'Select one Category',
                    style: TextStyle(
                      fontFamily: "nunito",
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Text(
                      "NOTE: Don't choose options randomly, otherwise this post will be ineligible for all contests on this platform!",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontFamily: "Nunito",
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  tagTiles(),
                  SizedBox(height: 60),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: StreamBuilder(
                      stream: percentIndicatorBloc.percentIndicatorStream,
                      builder: (context, snapshot) {
                        return isUploading
                              ? Container(
                                  height: 50,
                                  width: double.infinity,
                                  child: LiquidLinearProgressIndicator(
                                    borderRadius: 15.0,
                                    value: percent / 100,
                                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                                    center: Text(
                                      '${percent.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    direction: Axis.horizontal,
                                    backgroundColor: Colors.grey.shade300,
                                  ),
                                )
                              : RoundedButton(
                                  title: 'Post',
                                  color: Colors.blue.withOpacity(0.8),
                                  onPressed: () {
                                    print('Tag: $tag');
                                    print(descriptionController.text);
                                    if (tag != null &&
                                        descriptionController.text != null &&
                                        descriptionController.text.isNotEmpty) {
                                      isUploading = true;
                                      startPercentUntil90();
                                      handleSubmit();
                                    } else if (descriptionController.text == null ||
                                        descriptionController.text.isEmpty) {
                                      showToast(
                                          message: 'Description cannot be empty');
                                    } else
                                      showToast(message: 'Select a Tag first!');
                                  },
                                );
                      }
                    )
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: RoundedButton(
                      title: 'Cancel',
                      color: Colors.red.withOpacity(0.8),
                      onPressed: () {
                        descriptionController.clear();
                        initialize();
                        Navigator.pushNamedAndRemoveUntil(
                            context, NewsFeed.id, (route) => false);
                      },
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget postIcon() {
    return OpenContainer(
      transitionDuration: Duration(seconds: 2),
      openColor: Colors.transparent,
      closedColor: Colors.transparent,
      openElevation: 0,
      closedElevation: 0,
      openBuilder: (context, _) => postDescription(),
      closedBuilder: (context, openContainer) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
        height: 50,
        width: 50,
        child: Icon(Icons.double_arrow_sharp, color: Colors.white),
      ),
    );
  }

  handleSubmit() async {
    print('Handle Submit Started');

    /* Compress Image */
    await compressImage();

    /* Firebase Storage */
    String mediaUrl = await uploadImage(file);
    PostModel uploadPost = PostModel();

    uploadPost.postId = postId;
    uploadPost.userId = currentUser.uid;
    uploadPost.mediaUrl = mediaUrl;
    uploadPost.description = descriptionController.text;
    uploadPost.tag = tag;
    uploadPost.userPhotoUrl = currentUser.photoURL;
    uploadPost.isFullScreen = isFullScreenSelected[0];
    uploadPost.timestamp = Timestamp.now();

    /* Store in Firestore */
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .set(uploadPost.toMap());

    FirebaseFirestore.instance
        .collection('userInfo')
        .doc(currentUser.uid)
        .collection('myPosts')
        .doc(postId)
        .set(uploadPost.toMap());


    print('Handle Submit End');

    await Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 10));
      if (percent >= 90) {
        return false;
      }
      return true;
    });

    startPercentAfter90();

    await Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 10));
      if (percent == 100) {
        return false;
      }
      return true;
    });

    isUploading = false;
    print('isUploading: false');

    selectCategoryBloc.closeStream();
    percentIndicatorBloc.closeStream();

    postModelList.add(uploadPost);

    Navigator.pushNamedAndRemoveUntil(context, NewsFeed.id, (route) => false);
  }

  compressImage() async {
    var imageSize = await file.length();
    print('Image Size Before Compress : $imageSize');

    // Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    // final compressImageFile = File('$path/img_$postId.jpg')
    //   ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 100));
    //
    // var compressImageSize = await file.length();
    // print('Image Size After Compress : $compressImageSize');
    //
    // setState(() {
    //   file = compressImageFile;
    // });
  }

  Future<String> uploadImage(File imageFile) async {
    UploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask;

    String downloadURL = await storageSnap.ref.getDownloadURL();
    return downloadURL;
  }

  Widget tagTiles() {
    return StreamBuilder(
        stream: selectCategoryBloc.selectCategoryStream,
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: tag == 'articles'
                                ? Colors.green
                                : Colors.transparent,
                            width: 2,
                          ),
                          color: (tag == 'articles')
                              ? Colors.red
                              : Colors.red[400],
                        ),
                        height: (tag == 'articles') ? 90 : 80,
                        child: Center(
                          child: ListTile(
                            onTap: () {
                              tag = 'articles';
                              selectCategoryBloc.selectCategorySink.add(tag);
                            },
                            title: Text(
                              'Articles',
                              style: kTitleTextStyle,
                            ),
                            trailing: SvgPicture.asset(
                              'images/article.svg',
                              width: 24,
                              height: 30,
                              color: Colors.white,
                            ),
                            tileColor: Colors.red[400],
                            subtitle: Text(
                              'Education, technology',
                              style: kSubtitleTextStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: tag == 'art'
                                ? Colors.green
                                : Colors.transparent,
                            width: 2,
                          ),
                          color:
                              (tag == 'art') ? Colors.blue : Colors.blueAccent,
                        ),
                        height: (tag == 'art') ? 100 : 80,
                        child: Center(
                          child: ListTile(
                            onTap: () {
                              tag = 'art';
                              selectCategoryBloc.selectCategorySink.add(tag);
                            },
                            title: Text(
                              'Art',
                              style: kTitleTextStyle,
                            ),
                            trailing: SvgPicture.asset(
                              'images/art.svg',
                              width: 24,
                              height: 30,
                              color: Colors.white,
                            ),
                            tileColor: Colors.blueAccent,
                            subtitle: Text(
                              'Poetry, story and so on.',
                              style: kSubtitleTextStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: tag == 'selfie'
                                ? Colors.green
                                : Colors.transparent,
                            width: 2,
                          ),
                          color: tag == 'selfie'
                              ? Colors.pink
                              : Colors.pinkAccent.withOpacity(0.8),
                        ),
                        height: tag == 'selfie' ? 100 : 80,
                        child: Center(
                          child: ListTile(
                            onTap: () {
                              tag = 'selfie';
                              selectCategoryBloc.selectCategorySink.add(tag);
                            },
                            title: Text(
                              'Selfie',
                              style: kTitleTextStyle,
                            ),
                            trailing: SvgPicture.asset(
                              'images/selfie.svg',
                              width: 24,
                              height: 24,
                              color: Colors.white,
                            ),
                            tileColor: Colors.pinkAccent.withOpacity(0.8),
                            subtitle: Text(
                              'Solo pic. Eligible for Hot Or Not!',
                              style: kSubtitleTextStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: tag == 'memes'
                                ? Colors.green
                                : Colors.transparent,
                            width: 2,
                          ),
                          color: Colors.yellow[800],
                        ),
                        height: tag == 'memes' ? 100 : 80,
                        child: Center(
                          child: ListTile(
                            onTap: () {
                              tag = 'memes';
                              selectCategoryBloc.selectCategorySink.add(tag);
                            },
                            title: Text(
                              'Memes',
                              style: kTitleTextStyle,
                            ),
                            tileColor: Colors.yellow[800],
                            trailing: SvgPicture.asset(
                              'images/meme.svg',
                              width: 50,
                              height: 50,
                              color: Colors.black,
                            ),
                            subtitle: Text(
                              'Anything Funny!',
                              style: kSubtitleTextStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: tag == 'none' ? Colors.green : Colors.transparent,
                      width: 2,
                    ),
                    color: Colors.grey,
                  ),
                  height: tag == 'none' ? 100 : 80,
                  child: Center(
                    child: ListTile(
                      onTap: () {
                        tag = 'none';
                        selectCategoryBloc.selectCategorySink.add(tag);
                      },
                      title: Text(
                        'None of the above',
                        style: kTitleTextStyle,
                      ),
                      subtitle: Text(
                        "Pics, texts, messages or announcements",
                        style: kSubtitleTextStyle,
                      ),
                      tileColor: Colors.green.withOpacity(0.75),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void startPercentUntil90() {
    Timer timer;
    timer = Timer.periodic(Duration(milliseconds: 100), (_) {
      percent += 5;
      percentIndicatorBloc.percentIndicatorSink.add(percent);
      if (percent >= 90) {
        timer.cancel();
      }
    });
  }

  void startPercentAfter90() {
    Timer timer;
    timer = Timer.periodic(Duration(milliseconds: 100), (_) {
      percent += 1;
      percentIndicatorBloc.percentIndicatorSink.add(percent);
      if (percent >= 100) {
        timer.cancel();
      }
    });
  }
}

var kSubtitleTextStyle = TextStyle(
    fontSize: 12,
    color: Colors.white.withOpacity(0.9),
    fontStyle: FontStyle.italic);

var kTitleTextStyle = TextStyle(
    color: Colors.indigo,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontFamily: 'nunito');

class PercentIndicatorBloc {
  final stateStreamController = StreamController<double>();

  StreamSink<double> get percentIndicatorSink =>
      stateStreamController.sink;

  Stream<double> get percentIndicatorStream =>
      stateStreamController.stream;

  void closeStream() {
    stateStreamController.close();
  }
}
