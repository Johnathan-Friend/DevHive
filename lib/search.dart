import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:devhive_friend_sanchez/classes/user.dart' as custom_user;
import 'package:devhive_friend_sanchez/create_post.dart';
import 'package:devhive_friend_sanchez/home.dart';
import 'package:devhive_friend_sanchez/profile.dart';
import 'package:devhive_friend_sanchez/classes/post.dart';

class Search extends StatefulWidget {
  final custom_user.User currentUser;

  const Search({super.key, required this.currentUser});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late final String userId;
  final Post fakePost = Post.fake();
  late custom_user.User currentUser;
  late List<Post> currentPosts;
  bool postLoaded = false;
  bool userLoaded = false;
  @override
  void initState() {
    super.initState();
    // currentUser = _getCurrentUser();
    _getCurrentUser();
    _getPostFromDB();
  }

  Future<void> _getPostFromDB() async {
    try {
      List<Post> posts = await _fetchPostsFromDB();
      setState(() {
        currentPosts = posts;
      });
    } catch (e) {
      print('Error happened here: $e');
    }
  }

  Future<List<Post>> _fetchPostsFromDB() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    Map<String, dynamic> postData;
    List<Post> posts = [];
    Post post;
    custom_user.User user;

    try {
      QuerySnapshot querySnapshot = await firestore.collection('posts').get();
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        postData = documentSnapshot.data() as Map<String, dynamic>;
        user = await _fetchPostUser(postData['user']);
        String postId = documentSnapshot.id;

        // user = currentUser;
        post = Post(
          id: postId,
          title: postData['title'],
          imageUrl: postData['imageUrl'],
          caption: postData['caption'],
          likes: postData['likes'],
          user: user,
          comments: postData['comments'],
          externalLink: postData['externalLink'],
          topic: postData['topic'],
        );
        posts.add(post);
      }
    } catch (e) {
      print('Error fetching post data: $e');
    }
    //posts = [Post.fake(), Post.fake()];
    postLoaded = true;
    return posts;
  }

  Future<custom_user.User> _fetchPostUser(id) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    Map<String, dynamic> userData = {};
    custom_user.User loadedUser;

    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(id).get();

      if (userDoc.exists) {
        userData = userDoc.data() as Map<String, dynamic>;

        loadedUser = custom_user.User(
          id: userData['id'],
          username: userData['username'],

          // TODO: add the photo to the bucket and pull the URL
          profilePicURL: userData['profilePicURL'],
          bio: userData['bio'],
          posts: userData['posts'],
          likes: userData['likes'],
          followers: userData['followers'],
          following: userData['following'],
          savedPosts: userData['savedPosts'],
          organization: userData['organization'],
          topics: userData['topics'],
        );
        userLoaded = true;
        return loadedUser;
      } else {
        print('User not found');
        return custom_user.User.fake();
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      // Throw the error to be caught by the calling function
      throw e;
    }
  }

  Future<void> _getCurrentUser() async {
    try {
      custom_user.User user = await _fetchUserFromDatabase();
      setState(() {
        currentUser = user;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<custom_user.User> _fetchUserFromDatabase() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    Map<String, dynamic> userData = {};
    custom_user.User loadedUser;

    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        userData = userDoc.data() as Map<String, dynamic>;

        loadedUser = custom_user.User(
          id: userData['id'],
          username: userData['username'],
          profilePicURL: userData['profilePicURL'],
          bio: userData['bio'],
          posts: userData['posts'],
          likes: userData['likes'],
          followers: userData['followers'],
          following: userData['following'],
          savedPosts: userData['savedPosts'],
          organization: userData['organization'],
          topics: userData['topics'],
        );
        userLoaded = true;
        return loadedUser;
      } else {
        print('User not found');
        return custom_user.User.fake();
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      // Throw the error to be caught by the calling function
      throw e;
    }
  }

Future<List<Post>> _searchPosts(
  String searchText, String? selectedTopic) async {
  List<Post> searchResults = [];

  try {
    // Fetch posts from the database
    List<Post> allPosts = await _fetchPostsFromDB();

    // If search text is empty and no topic is selected, return all posts
    if (searchText.isEmpty && selectedTopic == null) {
      return allPosts;
    }

    // If search text is not empty, filter posts by matching title or caption
    if (searchText.isNotEmpty) {
      searchResults.addAll(allPosts.where((post) =>
          post.title.toLowerCase().contains(searchText.toLowerCase()) ||
          post.caption.toLowerCase().contains(searchText.toLowerCase())));
    }

    // If a topic is selected, filter posts by matching topic
    if (selectedTopic != null) {
      searchResults.addAll(allPosts.where((post) => post.topic == selectedTopic));
    }

    // Remove duplicate posts in case both search text and topic are provided
    searchResults = searchResults.toSet().toList();
  } catch (e) {
    print('Error searching posts: $e');
  }

  return searchResults;
}

  final List<String> topics = [
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
    'Software Engineering'
  ];
  String? selectedTopic;
  String searchBarText = 'Search...';

@override
Widget build(BuildContext context) {
  return Scaffold(
    bottomNavigationBar: BottomAppBar(
      color: Colors.yellow.shade700,
      elevation: 8.0,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home Page link
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Home()));
            },
          ),

          // search screen link
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              // left blank as to not allow navigating to the same page over and
              // over again
            },
          ),

          // create post screen link
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CreatePost(currentUser: widget.currentUser)));
            },
          ),

          // profile screen link
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Profile(
                    currentUser: widget.currentUser,
                    user: widget.currentUser,
                  )));
            },
          ),
        ],
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 30.0), // Add padding to the top and left/right sides
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 20.0), // Add padding to the top of the search bar
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: searchBarText,
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Center(
                                  child: Container(
                                    width: 100.0,
                                    height: 100.0,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.yellow.shade700),
                                        ),
                                        const SizedBox(height: 10.0),
                                        const Text(
                                          'Searching...',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                              TextDecoration.none),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                            List<Post> searchResults = await _searchPosts(
                                searchBarText, selectedTopic);
                            setState(() {
                              currentPosts = searchResults;
                              print(currentPosts);
                            });

                            Navigator.pop(context); // Dismiss the dialog
                          },
                          child: const Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100.0),
            const Padding(
              padding: EdgeInsets.only(bottom: 23.0),
              child: Align(
                child: Text(
                  "Search Topics",
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children:
              topics.map((topic) => _buildTopicChip(topic)).toList(),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18.0),
            ),
            // Display posts using _PostLoader
            FutureBuilder<List<Post>>(
              future: _searchPosts(searchBarText, selectedTopic),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // If waiting for data, show a circular progress indicator
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // If an error occurs, show an error message
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  // If data is available, display the posts using ListView.builder
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data?.length,
                    itemBuilder: (BuildContext context, int index) {
                      return PostLoader(
                        post: snapshot.data![index],
                        currentUser: widget.currentUser,
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildTopicChip(String topic) {
    return FilterChip(
      label: Text(topic),
      selected: selectedTopic == topic,
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            selectedTopic = topic;
            searchBarText = selectedTopic!;
          } else {
            selectedTopic = null;
            searchBarText = "Search...";
          }
        });
      },
      selectedColor: Colors.yellow[700],
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selectedTopic == topic ? Colors.white : Colors.black,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
          color: Color.fromARGB(255, 244, 191, 57),
        ),
      ),
    );
  }
}
