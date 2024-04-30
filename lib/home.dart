import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devhive_friend_sanchez/classes/post.dart';
import 'package:devhive_friend_sanchez/classes/user.dart' as custom_user;
import 'package:devhive_friend_sanchez/create_post.dart';
import 'package:devhive_friend_sanchez/profile.dart';
import 'package:devhive_friend_sanchez/post_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:devhive_friend_sanchez/search.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
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
      QuerySnapshot querySnapshot = await firestore
          .collection('posts')
          .orderBy('dateCreated', descending: true)
          .get();
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        postData = documentSnapshot.data() as Map<String, dynamic>;
        user = await fetchPostUser(postData['user']);
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

  Future<List<Post>> _fetchPostsWithTopicsFromDB(List<dynamic> topics) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Post> posts = [];

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('posts')
          .where('topic', whereIn: topics)
          .orderBy('dateCreated', descending: true)
          .get();

      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> postData =
            documentSnapshot.data() as Map<String, dynamic>;
        custom_user.User user = await fetchPostUser(postData['user']);
        String postId = documentSnapshot.id;

        Post post = Post(
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

    postLoaded = true;
    return posts;
  }

  Future<List<Post>> _fetchPostsWithFollowingFromDB(
      List<dynamic> following) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Post> posts = [];

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('posts')
          .where('user', whereIn: following)
          .orderBy('dateCreated', descending: true)
          .get();

      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> postData =
            documentSnapshot.data() as Map<String, dynamic>;
        custom_user.User user = await fetchPostUser(postData['user']);
        String postId = documentSnapshot.id;

        Post post = Post(
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

    postLoaded = true;
    return posts;
  }

  Future<custom_user.User> fetchPostUser(id) async {
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

  Widget _buildContent() {
    if (!userLoaded || !postLoaded) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow.shade700),
          ),
          const SizedBox(height: 10.0),
          const Text(
            'DevHive',
            style: TextStyle(
                color: Colors.black,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none),
          ),
        ],
      )); // Show a loading indicator while fetching user data
    } else {
      return _buildHome(); // Navigate to the next page with currentUser data
    }
  }

  Widget _buildHome() {
    List<Post> originalPosts = List.from(currentPosts);
    bool isForYou = false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: currentPosts.length, // Number of posts in the list
                  itemBuilder: (BuildContext context, int index) {
                    return PostLoader(
                      post: currentPosts[index],
                      currentUser: currentUser,
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: 50.0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withOpacity(0.3), // Shadow color with opacity
                    spreadRadius: 45, // Spread radius
                    blurRadius: 10, // Blur radius
                    offset: const Offset(0,
                        -31), // Shadow position, negative value means shadow moves up
                  ),
                ],
              ),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      // Logic for "For You" button
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Center(
                            child: Container(
                              width: 100.0,
                              height: 100.0,
                              decoration: BoxDecoration(
                                // color: Colors.black87,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.yellow.shade700),
                                  ),
                                  const SizedBox(height: 10.0),
                                  const Text(
                                    'DevHive',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );

                      List<Post> post1 = await _fetchPostsFromDB();
                      setState(() {
                        currentPosts = post1;
                      });
                      Navigator.pop(context); // Dismiss the dialog
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade700,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        'Explore',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                isForYou ? 16.0 : 14.0), // Adjusted font size
                      ),
                    ),
                  ),
                  const SizedBox(width: 50.0),
                  GestureDetector(
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Center(
                            child: Container(
                              width: 100.0,
                              height: 100.0,
                              decoration: BoxDecoration(
                                // color: Colors.black87,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.yellow.shade700),
                                  ),
                                  const SizedBox(height: 10.0),
                                  const Text(
                                    'DevHive',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                      List<Post> post1 =
                          await _fetchPostsWithTopicsFromDB(currentUser.topics);
                      // Logic for "for you" button
                      setState(() {
                        currentPosts = post1;
                      });
                      Navigator.pop(context); // Dismiss the dialog
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade700,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: const Text(
                        'For you',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 50.0),
                  GestureDetector(
                    onTap: () async {
                      // Logic for "Following" button
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Center(
                            child: Container(
                              width: 100.0,
                              height: 100.0,
                              decoration: BoxDecoration(
                                // color: Colors.black87,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.yellow.shade700),
                                  ),
                                  const SizedBox(height: 10.0),
                                  const Text(
                                    'DevHive',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );

                      List<Post> post = await _fetchPostsWithFollowingFromDB(
                          currentUser.following);
                      // print(currentUser.following);
                      setState(() {
                        currentPosts = post;
                      });
                      Navigator.pop(context); // Dismiss the dialog
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade700,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: const Text(
                        'Following',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(),
      bottomNavigationBar: BottomAppBar(
        color: Colors.yellow.shade700,
        elevation: 8.0,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                // Navigate to home screen or perform action
              },
            ),

            // search screen
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Search(
                          currentUser: currentUser,
                        )));
              },
            ),

            // create post screen
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        CreatePost(currentUser: currentUser)));
              },
            ),

            // profile screen
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                // Navigate to account screen or perform action
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        Profile(currentUser: currentUser, user: currentUser),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PostLoader extends StatefulWidget {
  final Post post;
  final custom_user.User currentUser;

  const PostLoader({required this.post, required this.currentUser});

  @override
  State<PostLoader> createState() => PostLoaderState();
}

class PostLoaderState extends State<PostLoader> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PostView(
                      post: widget.post,
                      currentUser: widget.currentUser,
                    )),
          );
        },
        child: Card(
            surfaceTintColor: Colors.white,
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User profile, name, and organization
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  NetworkImage(widget.post.user.profilePicURL),
                            ),
                            const SizedBox(width: 10),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: widget.post.user.username,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  if (widget.post.user.organization !=
                                      null) ...[
                                    const TextSpan(text: ' - '),
                                    TextSpan(
                                      text: widget.post.user.organization!,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),

                        // title and topic of post
                        const SizedBox(height: 16.0),
                        Text(
                          widget.post.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        if (widget.post.topic != null)
                          Text(
                            '${widget.post.topic}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        const SizedBox(height: 8.0),
                        if (widget.post.imageUrl != "")
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.99, // Adjust the percentage as needed
                              height: 200, // Adjust the height as needed
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(widget.post.imageUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),

                        // caption of post with read more to lead to post view
                        Text.rich(
                          TextSpan(
                            text: widget.post.caption.length <= 180
                                ? widget.post.caption
                                : "${widget.post.caption.substring(0, 180)}...",
                            style:
                                const TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ),

                        // like and comment action buttons
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            // like icon and count
                            InkWell(
                              onTap: () {
                                setState(() {
                                  handleLikeButtonTap();
                                  if (widget.post.likes
                                      .contains(widget.currentUser.id)) {
                                    widget.post.likes
                                        .remove(widget.currentUser.id);
                                    handleLikeButtonTap();
                                  } else {
                                    widget.post.likes
                                        .add(widget.currentUser.id);
                                    handleLikeButtonTap();
                                  }
                                });
                              },
                              child: Icon(
                                !widget.post.likes.contains(widget.currentUser
                                        .id) // Check if the user has liked the post
                                    ? Icons
                                        .favorite_border_outlined // Use outlined heart icon if not liked
                                    : Icons
                                        .favorite, // Use filled heart icon if liked
                                color: widget.post.likes
                                        .contains(widget.currentUser.id)
                                    ? Colors.red
                                    : null, // Set color to red if liked
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text('${widget.post.likes.length}'),
                            const SizedBox(width: 30.0),

                            // comment icon and count
                            InkWell(
                              onTap: () {
                                // TODO: add functionality to see comments and add comments
                              },
                              child: const Icon(Icons.comment_outlined),
                            ),
                            const SizedBox(width: 8.0),
                            Text('${widget.post.comments?.length ?? 0}'),

                            // Spacer to push the next icon to the far right
                            const Spacer(),

                            // Saved posts
                            Align(
                              alignment: Alignment.centerRight,
                              child: // Saved posts section
                                  InkWell(
                                onTap: () {
                                  setState(() {
                                    if (widget.currentUser.savedPosts
                                        .contains(widget.post.id)) {
                                      widget.currentUser.savedPosts
                                          .remove(widget.post.id);
                                      handleSaveButtonTap();
                                      print(widget.currentUser.savedPosts);
                                    } else {
                                      widget.currentUser.savedPosts
                                          .add(widget.post.id);
                                      handleSaveButtonTap();
                                    }
                                  });
                                },
                                child: Icon(
                                  !widget.currentUser.savedPosts
                                          .contains(widget.post.id)
                                      ? Icons.bookmark_add_outlined
                                      : Icons.bookmark,
                                  color: widget.currentUser.savedPosts
                                          .contains(widget.post.id)
                                      ? Colors.black
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }

  void handleSaveButtonTap() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    Map<String, dynamic> userData = {};

    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(widget.currentUser.id).get();

      if (userDoc.exists) {
        userData = userDoc.data() as Map<String, dynamic>;
        userData['savedPosts'] = widget.currentUser.savedPosts;
        await firestore
            .collection('users')
            .doc(widget.currentUser.id)
            .update(userData);
      } else {
        print('user not found');
      }
    } catch (e) {
      print('Error fetching and updating post data: $e');
      // Handle any errors that occur during the process
    }
  }

  void handleLikeButtonTap() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    Map<String, dynamic> postData = {};

    try {
      DocumentSnapshot postDoc =
          await firestore.collection('posts').doc(widget.post.id).get();

      if (postDoc.exists) {
        postData = postDoc.data() as Map<String, dynamic>;
        postData['likes'] = widget.post.likes;
        await firestore
            .collection('posts')
            .doc(widget.post.id)
            .update(postData);
      } else {
        print('Post not found');
      }
    } catch (e) {
      print('Error fetching and updating post data: $e');

      // Handle any errors that occur during the process
    }
  }
}
