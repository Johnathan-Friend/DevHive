import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// import 'home.dart';
import 'login.dart';
import 'create_profile.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? error; // Declare error here

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 320,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 0.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Image(
                        image: AssetImage('./assets/WebHiveLogo.png'),
                        fit: BoxFit.contain,
                        width: 120,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 23.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text("Email"),
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
                          child: TextFormField(
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
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text("Create a password"),
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
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscureText,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Colors.black,
                                  ),
                                  hintText: 'must be 8 characters',
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
                                    color:
                                        _obscureText ? Colors.grey : Colors.blue,
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
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text("Confirm password"),
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
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureText,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Colors.black,
                                  ),
                                  hintText: 'repeat password',
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
                                    color:
                                        _obscureText ? Colors.grey : Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_confirmPasswordError != null)
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              _confirmPasswordError!,
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
                          await createAccount();
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.yellow[700]),
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
                      child: const Text("Create An Account"),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const Login()),
                          );
                        },
                        style: ButtonStyle(
                          overlayColor:
                              MaterialStateProperty.all(Colors.transparent),
                          foregroundColor: MaterialStateProperty.all(Colors.black),
                        ),
                        child: const Text(
                          "Log in",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> createAccount() async {
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
          .createUserWithEmailAndPassword(email: email, password: password);
      error = null;
      setState(() {});

      if (!mounted) return;

      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const CreateProfile(),
      ));
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          error = 'The email address is already in use.';
          break;
        case 'invalid-email':
          error = 'The email address is invalid.';
          break;
        case 'weak-password':
          error = 'The password provided is too weak.';
          break;
        case 'too-many-requests':
          error = 'Too many unsuccessful attempts. Try again later.';
          break;
        case 'operation-not-allowed':
          error = 'Email and password accounts are not enabled.';
          break;
        default:
          error = 'An unknown error occurred.';
          break;
      }

      setState(() {});
    } catch (e) {
      // Handle other exceptions here
    }
  }

  bool _validateInputs() {
    bool isValid = true;

    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
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

    if (_confirmPasswordController.text.isEmpty ||
        _confirmPasswordController.text != _passwordController.text) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
        isValid = false;
      });
    }

    return isValid;
  }
}
