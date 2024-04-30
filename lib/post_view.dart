import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devhive_friend_sanchez/classes/post.dart';
import 'package:devhive_friend_sanchez/classes/user.dart';
import 'package:devhive_friend_sanchez/profile.dart';
import 'package:flutter/material.dart';
// Button for continuing reading from external link and
// button to comment on the post
import 'package:url_launcher/url_launcher.dart';

class PostView extends StatefulWidget {
  final Post post;
  final User currentUser;

  const PostView({super.key, required this.post, required this.currentUser});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  bool isLiked = false;
  bool _showCommentField = false;
  final FocusNode _commentFocus = FocusNode();
  final TextEditingController _commentController = TextEditingController();

  // @override
  // void dispose() {
  //   // Clean up the TextEditingController when the widget is disposed
  //   _commentController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User profile, name, and organization
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Profile(
                              currentUser: widget.currentUser,
                              user: widget.post.user)));
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          NetworkImage(widget.post.user.profilePicURL),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.user.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (widget.post.user.organization != null)
                        Text(
                          widget.post.user.organization!,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16.0),

              // Image (if URL is not null)
              if (widget.post.imageUrl != "") ...[
                Image.network(
                  widget.post.imageUrl!,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16.0),
              ],

              Row(
                children: [
                  // like icon and count
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (widget.post.likes.contains(widget.currentUser.id)) {
                          widget.post.likes.remove(widget.currentUser.id);
                          _handleLikeButtonTap();
                        } else {
                          widget.post.likes.add(widget.currentUser.id);
                          _handleLikeButtonTap();
                        }
                      });
                    },
                    child: Icon(
                      !widget.post.likes.contains(widget.currentUser.id)
                          ? Icons.favorite_border_outlined
                          : Icons.favorite,
                      color: widget.post.likes.contains(widget.currentUser.id)
                          ? Colors.red
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text('${widget.post.likes.length}'),
                  const SizedBox(width: 25.0),

                  // Spacer to push the next icon to the far right
                  const Spacer(),

                  // Additional icon
                  Align(
                    alignment: Alignment.centerRight,
                    child: 
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
              const SizedBox(height: 16.0),

              // Title
              Text(
                widget.post.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8.0),

              // Caption
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  widget.post.caption,
                ),
              ),

              Row(
                children: [
                  if (widget.post.externalLink != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          String url = widget.post.externalLink!;
                          if (!url.startsWith("https://")) {
                            url = "https://"+url;
                          }
                          final urlLink = Uri.parse(url);
                          launchUrl(
                            urlLink,
                            mode: LaunchMode.inAppBrowserView,
                          );
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
                        child: const Text("Follow Link"),
                      ),
                    ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _showCommentField = true;
                          FocusScope.of(context).requestFocus(_commentFocus);
                        });
                      },
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(
                            BorderSide(color: Colors.yellow.shade700)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                        textStyle: MaterialStateProperty.all(
                            const TextStyle(fontWeight: FontWeight.bold)),
                        fixedSize:
                            MaterialStateProperty.all(const Size(320.0, 40.0)),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.black),
                      ),
                      child: const Text("Add Comment"),
                    ),
                  ),
                ],
              ),

              // Text widget for "Comments:"
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Comments:",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),

              if (_showCommentField)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        focusNode: _commentFocus,
                        decoration: const InputDecoration(
                          hintText: 'Type your comment here...',
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        String commentText = _commentController.text;
                        String username = widget.currentUser.username;

                        // Create a map for the new comment
                        Map<String, String> newComment = {
                          'username': username,
                          'text': commentText,
                        };

                        // Add the new comment map to the comments list
                        widget.post.comments!.add(newComment);
                        _handleCommentAddToDB();
                        setState(() {
                          _showCommentField = false;
                        });
                      },
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.post.comments?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  final commentData = widget.post.comments?[index];
                  if (commentData is Map<String, dynamic>) {
                    // Convert comment data to the expected format
                    final comment = {
                      'username': commentData['username'].toString(),
                      'text': commentData['text'].toString(),
                    };
                    return _CommentLoader(comment: comment);
                  } else {
                    // Handle the case where the comment data is in an unexpected format
                    return const SizedBox();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
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

  void _handleCommentAddToDB() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    Map<String, dynamic> postData = {};

    try {
      DocumentSnapshot postDoc =
          await firestore.collection('posts').doc(widget.post.id).get();

      if (postDoc.exists) {
        postData = postDoc.data() as Map<String, dynamic>;
        postData['comments'] = widget.post.comments;
        await firestore
            .collection('posts')
            .doc(widget.post.id)
            .update(postData);
      } else {
        print('Post not found');
      }
    } catch (e) {
      print("$e");
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

class _CommentLoader extends StatelessWidget {
  const _CommentLoader({required this.comment});

  final Map<String, String> comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
            bottom: 16.0), // Add padding only at the bottom
        child: Text.rich(
          TextSpan(children: [
            TextSpan(
              text: comment['username'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold, // Make username bold
              ),
            ),
            const TextSpan(text: ' - '),
            TextSpan(text: comment['text'] ?? '')
          ]),
        ),
      ),
    );
  }
}
