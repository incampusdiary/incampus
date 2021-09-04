import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

String name;
String email;
String imageUrl;

Future<String> signInWithGoogle() async {

  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  if (googleSignInAccount == null) {
    Fluttertoast.showToast(
      msg: 'Signed in Failed',
      gravity: ToastGravity.BOTTOM,
    );
    return null;
  } else {
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    name = user.displayName;
    email = (user.email).toString();
    imageUrl = user.photoURL;

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);

    print('signInWithGoogle succeeded: $user');

    Fluttertoast.showToast(
      msg: 'Signed in Successful',
      gravity: ToastGravity.BOTTOM,
    );

    print('Before Check');
    var documentRef = await FirebaseFirestore.instance
        .collection('google users')
        .doc(FirebaseAuth.instance.currentUser.uid).get();

    print(documentRef.data());

    if (documentRef.data() == null) {
      print('User Created in Database');
      await FirebaseFirestore.instance
          .collection('google users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .set({
        'email': email,
        'image': imageUrl,
        'name': name,
        'user': FirebaseAuth.instance.currentUser.uid,
      });
    }

    return '$user';
  }
}
// Future signInWithGoogle() async {
//   print("'Sign In started'");
//   final user = await _googleSignIn.signIn();
//   print("'user email'");
//   print(user.toString());
//   if (user == null)
//     print("PRINTED: No user Found");
//   else {
//     final googleAuth = await user.authentication;
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );
//     await _firebaseAuth.signInWithCredential(credential);
//     // _googleSignIn.disconnect(); // This gives an option to choose a new google account every time.
//     showSnackBar("Signed In");
//     print(credential.toString());
//     name = user.displayName;
//     email = user.email;
//     photoUrl = user.photoUrl;
//     Navigator.pushNamed(context, WelcomeScreen.id);
//   }
// }

Future<void> signOutGoogle() async {
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();

  print("User Signed Out: ${FirebaseAuth.instance.currentUser}");
}
