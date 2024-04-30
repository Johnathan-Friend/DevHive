import 'package:flutter/material.dart';
import 'home.dart';
import 'register.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  String? error; // Declare error here

  String? _emailError;
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                _buildSignInText(),
                _buildEmailPasswordAndLogin(),
                _buildSignUpText(),
                if (error != null)
                  Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ), // Display error message if it exists
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 0.0),
      child: Align(
        alignment: Alignment.topRight,
        child: Image(
          image: AssetImage('./assets/WebHiveLogo.png'),
          fit: BoxFit.contain,
          width: 120,
        ),
      ),
    );
  }

  Widget _buildSignInText() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 23.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          "Sign In",
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailPasswordAndLogin() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Text("Email address"),
              ),
              const SizedBox(width: 10.0),
              Container(
                width: 320,
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: const Color.fromARGB(255, 244, 191, 57),
                  ),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.mail,
                      color: Colors.black,
                    ),
                    hintText: 'example@gmail.com',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_emailError != null)
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    _emailError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize:
                          11.0, // Modify this value to change the text size
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Text("Password"),
              ),
              const SizedBox(width: 10.0),
              Container(
                width: 320,
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: const Color.fromARGB(255, 244, 191, 57),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextField(
                      obscureText: _obscureText,
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.black,
                        ),
                        hintText: 'password',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        child: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: _obscureText ? Colors.grey : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_passwordError != null)
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    _passwordError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize:
                          11.0, // Modify this value to change the text size
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: OutlinedButton(
            onPressed: () async {
              if (_validateInputs()) {
                await signIn();
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.yellow[700]),
              side: MaterialStateProperty.all(BorderSide.none),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              textStyle: MaterialStateProperty.all(
                const TextStyle(fontWeight: FontWeight.bold),
              ),
              fixedSize: MaterialStateProperty.all(
                const Size(320.0, 40.0),
              ),
              foregroundColor: MaterialStateProperty.all(Colors.black),
              shadowColor: MaterialStateProperty.all(Colors.grey[300]),
              elevation: MaterialStateProperty.all(5),
            ),
            child: const Text("Log in"),
          ),
        ),
      ],
    );
  }

  Future<void> signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        if (email.isEmpty) {
          error = "Email cannot be empty.";
        } else {
          error = "Password cannot be empty.";
        }
      });
      return;
    }

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      error = null;
      setState(() {});

      if (!mounted) return;

      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Home(),
      ));

      // Show success banner
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        error = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        error = 'Wrong password provided for that user.';
      } else {
        error = 'Incorrect Email or Password';
      }

      setState(() {});
    } catch (e) {
      // Handle other exceptions here
    }
  }

  Widget _buildSignUpText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.grey),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const Register(),
              ),
            );
          },
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            foregroundColor: MaterialStateProperty.all(Colors.black),
          ),
          child: const Text(
            "Sign up",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  bool _validateInputs() {
    bool isValid = true;

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Please enter an email';
        isValid = false;
      });
    } else if (!_emailController.text.contains('@') ||
        !_emailController.text.contains('.')) {
      setState(() {
        _emailError = 'Invalid email format';
        isValid = false;
      });
    }

    if (_passwordController.text.isEmpty ||
        _passwordController.text.length < 8) {
      setState(() {
        _passwordError = 'Password must be at least 8 characters';
        isValid = false;
      });
    }

    return isValid;
  }
}
