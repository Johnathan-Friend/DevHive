import 'package:devhive_friend_sanchez/classes/post.dart';

class User {
  final String id;
  String username;
  String profilePicURL;
  String bio;
  String? organization;
  List<dynamic> posts;
  List<dynamic> likes;
  List<dynamic> followers;
  List<dynamic> following;
  List<dynamic> topics;
  List<dynamic> savedPosts;
  
  User({
    required this.id,
    required this.username,
    required this.profilePicURL,
    required this.bio,
    required this.likes,
    required this.followers,
    required this.following,
    required this.savedPosts,
    required this.posts,
    required this.organization,
    required this.topics,
  });

  // Empty constructor
  User.empty()
      : id = '',
        username = '',
        profilePicURL = '',
        bio = '',
        likes = [],
        followers = [],
        following = [],
        savedPosts = [],
        posts = [],
        organization = null,
        topics = [];


// make a schema
  factory User.fake() {
    return User(
      id: '',
      username: 'Fake Username',
      profilePicURL:
          'https://static.desygner.com/wp-content/uploads/sites/13/2022/05/04141642/Free-Stock-Photos-01.jpg',
      bio: 'This is the users bio! It will contain information about the user that they want to share.',
      posts: ["this is a fake post id", "this is a fake post id", "this is a fake post id"],
      likes: [],
      followers: ["this is a fake userID", "This is a fake userId", "this is a fake userID", "This is a fake userId"],
      following: ["this is a fake userID", "This is a fake userId", "this is a fake userID", "This is a fake userId", "this is a fake userID", "This is a fake userId", "this is a fake userID", "This is a fake userId"],
      savedPosts: [],
      organization: 'Organization Alpha',
      topics: [],
    );
  }
  Map<String, Object?> toMap() {
  return {
    'id': id,
    'username': username,
    'profilePicURL': profilePicURL,
    'bio': bio,
    'likes': likes,
    'followers': followers,
    'following': following,
    'savedPosts': savedPosts.map((post) => post.toMap()).toList(),
    'posts': posts,
    'organization': organization,
    'topics': topics,
  };
}

 factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      username: data['username'],
      profilePicURL: data['profilePicURL'],
      bio: data['bio'],
      likes: List<String>.from(data['likes']),
      followers: List<String>.from(data['followers']),
      following: List<String>.from(data['following']),
      savedPosts: List<Post>.from(data['savedPosts'].map((x) => Post.fromMap(x))),
      posts: List<String>.from(data['posts']),
      organization: data['organization'],
      topics: List<String>.from(data['topics']),
    );
  }
}