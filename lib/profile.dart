import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devhive_friend_sanchez/classes/post.dart';
import 'package:devhive_friend_sanchez/classes/user.dart';
import 'package:devhive_friend_sanchez/create_post.dart';
import 'package:devhive_friend_sanchez/home.dart';
import 'package:devhive_friend_sanchez/main.dart';
import 'package:devhive_friend_sanchez/post_view.dart';
import 'package:devhive_friend_sanchez/search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class Profile extends StatefulWidget {
  final User currentUser;
  final User user;

  const Profile({super.key, required this.currentUser, required this.user});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late List<Post> posts = [];
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _getPostFromDB();
    // String userId = firebase_auth.FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> _getPostFromDB() async {
    try {
      List<Post> loadingPosts = await _fetchUserPostsFromDB();
      isLoaded = true;
      setState(() {
        posts = loadingPosts;
      });
    } catch (e) {
      print('Error happened here: $e');
    }
  }

  Future<List<Post>> _fetchUserPostsFromDB() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Post> posts = [];

    try {
      for (String postId in widget.user.posts) {
        DocumentSnapshot postDoc =
            await firestore.collection('posts').doc(postId).get();
        if (postDoc.exists) {
          Map<String, dynamic> postData =
              postDoc.data() as Map<String, dynamic>;
          Post post = Post(
            id: postId,
            title: postData['title'],
            imageUrl: postData['imageUrl'],
            caption: postData['caption'],
            likes: postData['likes'] ?? [],
            user: widget.user,
            comments: postData['comments'] ?? [],
            externalLink: postData['externalLink'],
            topic: postData['topic'] ?? "",
          );
          posts.add(post);
        } else {
          print('Post with ID $postId not found');
        }
      }
    } catch (e) {
      print('Error fetching post data: $e');
    }
    return posts;
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
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
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none),
            ),
          ],
        ),
      );
    } else {
      if (widget.currentUser.id == widget.user.id) {
        return CurrentUserProfile(user: widget.currentUser, posts: posts);
      } else {
        return _UserProfile(
          user: widget.user,
          posts: posts,
          currentUser: widget.currentUser,
        );
      }
    }
  }
}

class _UserProfile extends StatelessWidget {
  final User user;
  final List<Post> posts;
  final User currentUser;

  const _UserProfile(
      {required this.user, required this.posts, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(user.username)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: _UserProfileLoader(
          user: user,
          posts: posts,
          currentUser: currentUser,
        ),
      ),
    );
  }
}

class _UserProfileLoader extends StatefulWidget {
  final User user;
  final List<Post> posts;
  final User currentUser;

  const _UserProfileLoader(
      {required this.user, required this.posts, required this.currentUser});

  @override
  State<_UserProfileLoader> createState() => __UserProfileLoaderState();
}

class __UserProfileLoaderState extends State<_UserProfileLoader> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(
        height: MediaQuery.of(context).padding.top + kToolbarHeight * 0.3,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile, bio, and organization
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(widget.user.profilePicURL),
                ),
                const SizedBox(width: 40),
                Column(children: [
                  Text('${widget.user.followers.length}'),
                  const Text("Followers")
                ]),
                const SizedBox(width: 30),
                Column(children: [
                  Text('${widget.user.following.length}'),
                  const Text("Following")
                ])
              ],
            ),
            const Padding(padding: EdgeInsets.only(bottom: 16.0)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.user.organization != null)
                  Text(
                    widget.user.organization!,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                Text(
                  widget.user.bio,
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.only(bottom: 12.0)),

            // button to follow and unfollow
            Row(children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      if (widget.user.followers
                          .contains(widget.currentUser.id)) {
                        _handleFollow();
                        widget.user.followers.remove(widget.currentUser.id);
                        widget.currentUser.following.add(widget.user.id);
                      } else {
                        _handleFollow();
                        widget.user.followers.add(widget.currentUser.id);
                        widget.currentUser.following.add(widget.user.id);
                      }
                    });
                  },
                  style: ButtonStyle(
                    side: MaterialStateProperty.all(BorderSide(
                      color:
                          !widget.user.followers.contains(widget.currentUser.id)
                              ? Colors.black
                              : Colors.black,
                    )),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    )),
                    textStyle: MaterialStateProperty.all(
                        const TextStyle(fontWeight: FontWeight.bold)),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                    fixedSize:
                        MaterialStateProperty.all(const Size(320.0, 40.0)),
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        return widget.user.followers
                                .contains(widget.currentUser.id)
                            ? Colors.yellow.shade700
                            : Colors.transparent;
                      },
                    ),
                  ),
                  child: widget.user.followers.contains(widget.currentUser.id)
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Following"),
                            SizedBox(width: 8),
                            Icon(Icons.check, color: Colors.black, size: 20),
                          ],
                        )
                      : const Text("Follow"),
                ),
              )
            ]),
            const SizedBox(height: 12),
            const Divider(color: Colors.grey),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.posts.length,
              itemBuilder: (BuildContext context, int index) {
                final post = widget.posts[index];
                return _UserPostLoader(
                  post: post,
                  currentUser: widget.user,
                );
              },
            ),
          ],
        ),
      ),
    ]));
  }

  _handleFollow() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      if (widget.user.followers.contains(widget.currentUser.id)) {
        // Remove the current user's ID from the following list of the user to unfollow
        await firestore.collection('users').doc(widget.user.id).update({
          'followers': FieldValue.arrayRemove([widget.currentUser.id])
        });

        // Remove the user to unfollow's ID from the followers list of the current user
        await firestore.collection('users').doc(widget.currentUser.id).update({
          'following': FieldValue.arrayRemove([widget.user.id])
        });
      } else {
        // Add the current user's ID to the following list of the user to follow
        await firestore.collection('users').doc(widget.user.id).update({
          'followers': FieldValue.arrayUnion([widget.currentUser.id])
        });

        // Add the user to follow's ID to the followers list of the current user
        await firestore.collection('users').doc(widget.currentUser.id).update({
          'following': FieldValue.arrayUnion([widget.user.id])
        });
      }
    } catch (e) {
      print('Error handling follow: $e');
    }
  }
}

class CurrentUserProfile extends StatelessWidget {
  final User user;
  final List<Post> posts;

  const CurrentUserProfile(
      {super.key, required this.user, required this.posts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(user.username),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) async {
              if (result == 'Sign Out') {
                _handleSignOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Sign Out',
                child: Text('Sign Out'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: _CurrentUserProfileLoader(user: user, posts: posts),
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
                    builder: (context) => Search(currentUser: user)));
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CreatePost(currentUser: user)));
              },
            ),
            IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              onPressed: () {
                // Navigate to account screen or perform action
              },
            ),
          ],
        ),
      ),
    );
  }

  _handleSignOut() async {
    try {
      await firebase_auth.FirebaseAuth.instance.signOut();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}

class _CurrentUserProfileLoader extends StatefulWidget {
  final User user;
  final List<Post> posts;

  const _CurrentUserProfileLoader(
      {super.key, required this.user, required this.posts});

  @override
  State<_CurrentUserProfileLoader> createState() =>
      __CurrentUserProfileLoaderState();
}

class __CurrentUserProfileLoaderState extends State<_CurrentUserProfileLoader> {
  bool savedPostLoaded = false;
  late List<Post> savedPosts = [];
  bool viewSavedPosts = false;

  @override
  void initState() {
    super.initState();
    _getPostFromDB();
  }

  Future<void> _getPostFromDB() async {
    try {
      List<Post> loadingPosts = await _fetchUserPostsFromDB();
      savedPostLoaded = true;
      setState(() {
        savedPosts = loadingPosts;
      });
    } catch (e) {
      print('Error happened here: $e');
    }
  }

  Future<List<Post>> _fetchUserPostsFromDB() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Post> posts = [];
    User user;

    try {
      for (String postId in widget.user.savedPosts) {
        DocumentSnapshot postDoc =
            await firestore.collection('posts').doc(postId).get();
        if (postDoc.exists) {
          Map<String, dynamic> postData =
              postDoc.data() as Map<String, dynamic>;
          user = await _fetchPostUser(postData['user']);
          Post post = Post(
            id: postId,
            title: postData['title'],
            imageUrl: postData['imageUrl'],
            caption: postData['caption'],
            likes: postData['likes'] ?? [],
            user: user,
            comments: postData['comments'] ?? [],
            externalLink: postData['externalLink'],
            topic: postData['topic'] ?? "",
          );
          posts.add(post);
        } else {
          print('Post with ID $postId not found');
        }
      }
    } catch (e) {
      print('Error fetching post data: $e');
    }
    return posts;
  }

  Future<User> _fetchPostUser(id) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    Map<String, dynamic> userData = {};
    User loadedUser;

    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(id).get();

      if (userDoc.exists) {
        userData = userDoc.data() as Map<String, dynamic>;

        loadedUser = User(
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
        return loadedUser;
      } else {
        print('User not found');
        return User.fake();
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      // Throw the error to be caught by the calling function
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!savedPostLoaded) {
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
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none),
            ),
          ],
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top + kToolbarHeight * 0.3,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User profile, bio, and organization
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            NetworkImage(widget.user.profilePicURL),
                      ),
                      const SizedBox(width: 40),
                      Column(children: [
                        Text('${widget.user.followers.length}'),
                        const Text("Followers")
                      ]),
                      const SizedBox(width: 30),
                      Column(children: [
                        Text('${widget.user.following.length}'),
                        const Text("Following")
                      ])
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 16.0)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.user.organization != null)
                        Text(
                          widget.user.organization!,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      const Padding(padding: EdgeInsets.only(bottom: 8.0)),
                      Text(
                        widget.user.bio,
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 12.0)),

                  // buttons for edit account and view saved posts
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Add functionality to edit account
                          },
                          style: ButtonStyle(
                            side: MaterialStateProperty.all(
                                BorderSide(color: Colors.yellow.shade700)),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            textStyle: MaterialStateProperty.all(
                                const TextStyle(fontWeight: FontWeight.bold)),
                            fixedSize: MaterialStateProperty.all(
                                const Size(320.0, 40.0)),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.black),
                          ),
                          child: const Text("Edit Account"),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              // toggles on and off the saved posts
                              viewSavedPosts = !viewSavedPosts;
                            });
                          },
                          style: ButtonStyle(
                            side: MaterialStateProperty.all(
                              BorderSide(
                                  color: Colors
                                      .yellow.shade700), // Adjust border color
                            ),
                            backgroundColor: MaterialStateProperty.all(
                              viewSavedPosts
                                  ? Colors.yellow.shade700
                                  : Colors
                                      .transparent, // Set background color to yellow when viewSavedPosts is true
                            ),
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
                            foregroundColor:
                                MaterialStateProperty.all(Colors.black),
                          ),
                          child: const Text("Saved Posts"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.grey),
                ],
              ),
            ),
            // Determine which list view to display
            viewSavedPosts
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: savedPosts.length,
                    itemBuilder: (BuildContext context, int index) {
                      final post = savedPosts[index];
                      return _UserPostLoader(
                        post: post,
                        currentUser: widget.user,
                      );
                    },
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.posts.length,
                    itemBuilder: (BuildContext context, int index) {
                      final post = widget.posts[index];
                      return _CurrentUserPostLoader(
                        post: post,
                        currentUser: widget.user,
                      );
                    },
                  ),
          ],
        ),
      );
    }
  }
}

class _CurrentUserPostLoader extends StatefulWidget {
  final Post post;
  final User currentUser;

  const _CurrentUserPostLoader({required this.post, required this.currentUser});

  @override
  _CurrentUserPostLoaderState createState() => _CurrentUserPostLoaderState();
}

class _CurrentUserPostLoaderState extends State<_CurrentUserPostLoader> {
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

                        // caption of post with read more to lead to post view
                        Text(widget.post.caption),

                        // like and comment action buttons
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            // like icon and count
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _handleLikeButtonTap();
                                  if (widget.post.likes
                                      .contains(widget.currentUser.id)) {
                                    widget.post.likes
                                        .remove(widget.currentUser.id);
                                    _handleLikeButtonTap();
                                  } else {
                                    widget.post.likes
                                        .add(widget.currentUser.id);
                                    _handleLikeButtonTap();
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
                            const SizedBox(width: 25.0),

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

                            // Additional icon
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () {
                                  // Show a confirmation dialog before deleting the post
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Delete Post"),
                                        content: Text(
                                            "Are you sure you want to delete this post?"),
                                        actions: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 80.0),
                                            child: TextButton(
                                              child: Text("Cancel"),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: TextButton(
                                              child: Text("Delete"),
                                              onPressed: () {
                                                // Call function to delete the post
                                                _handleDeletePost(widget.post.id);
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
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
            )
          )
        );
  }

  void _handleDeletePost(postId) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print("Error deleting post: $e");
    }
  }

  void _handleLikeButtonTap() async {
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

class _UserPostLoader extends StatefulWidget {
  final Post post;
  final User currentUser;

  const _UserPostLoader({required this.post, required this.currentUser});

  @override
  State<_UserPostLoader> createState() => __UserPostLoaderState();
}

class __UserPostLoaderState extends State<_UserPostLoader> {
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

                        // caption of post with read more to lead to post view
                        Text(widget.post.caption),

                        // like and comment action buttons
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            // like icon and count
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _handleLikeButtonTap();
                                  if (widget.post.likes
                                      .contains(widget.currentUser.id)) {
                                    widget.post.likes
                                        .remove(widget.currentUser.id);
                                    _handleLikeButtonTap();
                                  } else {
                                    widget.post.likes
                                        .add(widget.currentUser.id);
                                    _handleLikeButtonTap();
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
                            const SizedBox(width: 25.0),

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

  void _handleLikeButtonTap() async {
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
