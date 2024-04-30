import 'package:devhive_friend_sanchez/home.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  runApp(const MaterialApp(title: "DevHive", home: MyApp()));
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool firebaseReady = false;
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((value) => setState(() => firebaseReady = true));
  }

  @override
  Widget build(BuildContext context) {
    if (!firebaseReady) return const Center(child: CircularProgressIndicator());

    // currentUser will be null if no one is signed in.
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) return Home();
    return const LoginScreen();
  }
}

// LoginScreen
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(title: const Text("Home")),
        body: Center(
      child: (Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.all(0),
                child: const Padding(
                  padding: EdgeInsets.all(0),
                  child: Image(
                    image: AssetImage('./assets/WebHiveLogo.png'),
                    fit: BoxFit.contain,
                    width: 120,
                  ),
                ),
              ),
              Container(
                // margin: const EdgeInsets.all(10.0),

                padding:
                    const EdgeInsets.only(top: 10.0), // Specific padding values
                // width: 300.0, // Set a fixed width for RichText
                child: RichText(
                  // textAlign: TextAlign.center, // Set text alignment
                  text: const TextSpan(
                      style: TextStyle(
                          fontSize: 69.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Dev', style: TextStyle(color: Colors.black)),
                        TextSpan(
                            text: 'Hive',
                            style: TextStyle(color: Color(0xFFFFCC00))),
                      ]),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                // margin: const EdgeInsets.all(5.0),
                padding: const EdgeInsets.all(1.0),
                width: 300.0,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 20.0, color: Colors.black),
                    text: 'Connect, Collaborate, Code, Together ',
                  ),
                ),
              ),
            ],
          ),

          // Sign in button
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Login()));
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.yellow[700]),
                side: MaterialStateProperty.all(BorderSide.none),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0))),
                textStyle: MaterialStateProperty.all(
                    const TextStyle(fontWeight: FontWeight.bold)),
                fixedSize: MaterialStateProperty.all(const Size(300.0, 40.0)),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                shadowColor: MaterialStateProperty.all(Colors.grey[300]),
                elevation: MaterialStateProperty.all(5),
              ),
              child: const Text("Sign In"),
            ),
          ),

          // Create an account button
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Register()));
            },
            style: ButtonStyle(
              side: MaterialStateProperty.all(
                  BorderSide(color: Colors.yellow.shade700)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0))),
              textStyle: MaterialStateProperty.all(
                  const TextStyle(fontWeight: FontWeight.bold)),
              fixedSize: MaterialStateProperty.all(const Size(300.0, 40.0)),
              foregroundColor: MaterialStateProperty.all(Colors.black),
            ),
            child: const Text("Create an Account"),
          ),
        ],
      )),
    ));
  }
}

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("About")),
        body: const Center(
          child: Text(
              "Welcome to DevHive, by Johnathan Friend and Alvaro Sanchez",
              style: TextStyle(
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
        ));
  }
}
