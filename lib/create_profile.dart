import 'dart:io';
import 'package:devhive_friend_sanchez/pick_topics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:devhive_friend_sanchez/classes/user.dart' as userclass;

class CreateProfile extends StatefulWidget {
  const CreateProfile({super.key});

  @override
  CreateProfileState createState() => CreateProfileState();
}

class CreateProfileState extends State<CreateProfile> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? error;
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 23.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Create Profile",
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: _imageFile == null
                            ? const CircleAvatar(
                                radius: 50,
                                child: Icon(Icons.add_a_photo),
                              )
                            : CircleAvatar(
                                radius: 50,
                                backgroundImage: FileImage(_imageFile!),
                              ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text(
                        "Tap to upload a profile picture",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildInputField(
                  controller: _usernameController,
                  icon: Icons.person,
                  hintText: 'Enter your username',
                  errorText: error != null && _usernameController.text.isEmpty
                      ? 'Username is required'
                      : null,
                ),
                _buildInputField(
                  controller: _bioController,
                  icon: Icons.info,
                  hintText: 'Enter your bio',
                  maxLines: 3,
                  errorText: error != null && _bioController.text.isEmpty
                      ? 'Bio is required'
                      : null,
                ),
                _buildInputField(
                  controller: _organizationController,
                  icon: Icons.work,
                  hintText: 'Enter your organization',
                  errorText: error != null && _organizationController.text.isEmpty
                      ? 'Organization is required'
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: OutlinedButton(
                    onPressed: () async {
                      if (_validateInputs()) {
                        await _saveProfileToFirestore();
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const PickTopics(),
                        ));

                        // Show success banner
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Profile created successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
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
                    child: const Text("Save Profile"),
                  ),
                ),
                // add extra errors as a pop-up message here
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    int? maxLines,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(hintText.split(' ').first), // Just for illustration
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
              controller: controller,
              maxLines: maxLines ?? 1,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  icon,
                  color: Colors.black,
                ),
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                errorText,
                style: const TextStyle(color: Colors.red, fontSize: 11.0),
              ),
            ),
        ],
      ),
    );
  }

  bool _validateInputs() {
    bool isValid = true;

    if (_usernameController.text.isEmpty) {
      setState(() {
        error = 'Username is required';
      });
      isValid = false;
    } else if (_bioController.text.isEmpty) {
      setState(() {
        error = 'Bio is required';
      });
      isValid = false;
    } else if (_organizationController.text.isEmpty) {
      setState(() {
        error = 'Organization is required';
      });
      isValid = false;
    } else {
      setState(() {
        error = null;
      });
    }

    return isValid;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        if (kDebugMode) {
          print('No image selected.');
        }
      }
    });
  }

  Future<String?> uploadImageToFirebase(File imageFile, String folderName, String fileName) async {
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('$folderName/$fileName');

      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot storageTaskSnapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image to firebase: $e');
      return null;
    }
  }

  Future<void> _saveProfileToFirestore() async {
    try {
      String? imageUrl;
      if (_imageFile != null) {
        String fileExtension = '';
        int period = _imageFile!.path.lastIndexOf('.');
        if (period > -1) {
          fileExtension = _imageFile!.path.substring(period);
        }
        imageUrl = await uploadImageToFirebase(
            _imageFile!, 'profile_images', '$userId$fileExtension');
      }

      userclass.User newUser = userclass.User(
        id: userId,
        username: _usernameController.text,
        profilePicURL: imageUrl ?? "https://firebasestorage.googleapis.com/v0/b/termproject24.appspot.com/o/profile_images%2Fimages.png?alt=media&token=8ecd2ddb-0475-4183-baf5-63c3481fd500",
        bio: _bioController.text,
        likes: [],
        followers: [],
        following: [],
        savedPosts: [],
        posts: [],
        organization: _organizationController.text,
        topics: [],
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(newUser.toMap());

      setState(() {
        error = null;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to save profile: $e';
      });
    }
  }
}
