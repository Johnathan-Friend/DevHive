import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devhive_friend_sanchez/classes/user.dart' as customUser;
import 'package:devhive_friend_sanchez/home.dart';
import 'package:devhive_friend_sanchez/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:devhive_friend_sanchez/search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<String?> uploadImageToFirebase(
    File imageFile, String folderName, String fileName) async {
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

class CreatePost extends StatelessWidget {
  final customUser.User currentUser;

  const CreatePost({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Create Post"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _CreatePostLoader(
            currentUser: currentUser,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.yellow.shade700,
        elevation: 8.0,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Home()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Search(currentUser: currentUser)));
              },
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                // Navigate to add screen or perform action
              },
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        Profile(currentUser: currentUser, user: currentUser)));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatePostLoader extends StatefulWidget {
  final customUser.User currentUser;

  const _CreatePostLoader({required this.currentUser});

  @override
  State<_CreatePostLoader> createState() => __CreatePostLoaderState();
}

class __CreatePostLoaderState extends State<_CreatePostLoader> {
  bool _isPosting = false; // Initialize _isPosting to false
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    // print("got in pick create post");
    // print(userId);
  }

  final List<String> _topics = [
    "What topic best describes this post", // Placeholder text
    "Software Engineering",
    'Flutter',
    'React',
    'Python',
    'Java',
    'JavaScript',
    'Machine Learning',
    'Blockchain',
    'Cloud Computing',
    'Cybersecurity',
    'Artificial Intelligence',
  ];
  String _selectedTopic =
      "What topic best describes this post"; // initial topic text
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String title = "";
  String caption = "";
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: Column(
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_imageFile != null)
                    GestureDetector(
                      onTap: () async {
                        final pickedFile = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            _imageFile = File(pickedFile.path);
                          });
                        } else {
                          if (kDebugMode) {
                            print('No image selected.');
                          }
                        }
                      },
                      child: Image.file(
                        _imageFile!,
                        height: 160,
                        width: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (_imageFile == null)
                    IconButton(
                      onPressed: () async {
                        final pickedFile = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            _imageFile = File(pickedFile.path);
                          });
                        } else {
                          if (kDebugMode) {
                            print('No image selected.');
                          }
                        }
                      },
                      icon: const Icon(Icons.add_a_photo),
                      color: Colors.black,
                      iconSize: 120,
                    ),
                ],
              ),
            ),
            if (_imageFile != null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                // child: Text(
                //   'Selected image: ${_imageFile!.path.split('/').last}',
                //   style: TextStyle(fontSize: 16),
                // ),
              ),
            const SizedBox(height: 16),
            const Text(
              "Optional: Upload a photo",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTopic,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedTopic = newValue!;
                        });
                      },
                      icon: const Icon(Icons.arrow_forward_ios),
                      iconSize: 15,
                      items: _topics.map((topic) {
                        return DropdownMenuItem(
                          value: topic,
                          child: Text(topic),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _titleController,
              icon: Icons.person,
              hintText: 'Enter a Title',
              errorText: error != null && _titleController.text.isEmpty
                  ? 'Username is required'
                  : null,
            ),
            _buildInputField(
              controller: _captionController,
              icon: Icons.info,
              hintText: 'Enter a Caption',
              maxLines: 5,
              errorText: error != null && _captionController.text.isEmpty
                  ? 'Bio is required'
                  : null,
            ),
            _buildInputField(
              controller: _linkController,
              icon: Icons.work,
              hintText: 'Enter a Link',
              errorText: error != null && _linkController.text.isEmpty
                  ? 'Organization is required'
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      if (_validateInputs()) {
                        setState(() {
                          _isPosting =
                              true; // Set flag to true when posting starts
                        });

                        await _savePostToFirestore();

                        setState(() {
                          _isPosting =
                              false; // Set flag to false when posting completes
                        });

                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Home(),
                        ));

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post created successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.yellow[700]),
                      side: MaterialStateProperty.all(BorderSide.none),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                      textStyle: MaterialStateProperty.all(
                          const TextStyle(fontWeight: FontWeight.bold)),
                      fixedSize:
                          MaterialStateProperty.all(const Size(320.0, 40.0)),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                      shadowColor: MaterialStateProperty.all(Colors.grey[300]),
                      elevation: MaterialStateProperty.all(5),
                    ),
                    child: Text(_isPosting
                        ? "Posting..."
                        : "Create Post"), // Change button text based on posting status
                  ),
                  // Show spinner if posting is in progress
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
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

    if (_titleController.text.isEmpty) {
      setState(() {
        error = 'Title is required';
      });
      isValid = false;
    } else if (_captionController.text.isEmpty) {
      setState(() {
        error = 'Caption is required';
      });
      isValid = false;
    } else {
      setState(() {
        error = null;
      });
    }

    return isValid;
  }

  Future<void> _savePostToFirestore() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      String? imageUrl;
      if (_imageFile != null) {
        String fileExtension = '';
        int period = _imageFile!.path.lastIndexOf('.');
        if (period > -1) {
          fileExtension = _imageFile!.path.substring(period);
        }
        imageUrl = await uploadImageToFirebase(
            _imageFile!, 'post_images', '$userId$fileExtension');
      }

      CollectionReference postsCollection =
          FirebaseFirestore.instance.collection('posts');

      DocumentReference newPostRef = await postsCollection.add({
        'title': _titleController.text,
        'caption': _captionController.text,
        'likes': [],
        'user': userId,
        'comments': [],
        'externalLink': _linkController.text,
        'imageUrl': imageUrl ?? "",
        'topic': _selectedTopic == "What topic best describes this post"
            ? ""
            : _selectedTopic,
        'dateCreated': FieldValue
            .serverTimestamp(), // Recommended for automatic timestamps
      });

      String postId = newPostRef.id;
      widget.currentUser.posts.add(postId);
      _handleAddPostToUser();
    } catch (e) {
      setState(() {
        error = 'Failed to create post: $e';
        print(error);
      });
    }
  }

  void _handleAddPostToUser() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    Map<String, dynamic> userData = {};

    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(widget.currentUser.id).get();

      if (userDoc.exists) {
        userData = userDoc.data() as Map<String, dynamic>;
        userData['posts'] = widget.currentUser.posts;
        await firestore
            .collection('users')
            .doc(widget.currentUser.id)
            .update(userData);
      } else {
        print('Post not found');
      }
    } catch (e) {
      print("$e");
    }
  }
}
