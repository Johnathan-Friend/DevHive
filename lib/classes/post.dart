import "package:devhive_friend_sanchez/classes/user.dart";

class Post {
  String id;
  String? imageUrl;
  String title;
  String caption;
  String? topic;
  List<dynamic> likes;
  List<dynamic>? comments;
  User user;
  String? externalLink;

  Post({
    required this.id,
    required this.title,
    required this.caption,
    required this.likes,
    required this.user,
    required this.comments,
    this.externalLink,
    this.imageUrl,
    this.topic, required ,
  });

  // Generate a fake post with random data
  factory Post.fake() {
    var testUser = User.fake();
    return Post(
      id: 'fake_post_id',
      title: "This is a Fake Title",
      imageUrl:
          'https://static.desygner.com/wp-content/uploads/sites/13/2022/05/04141642/Free-Stock-Photos-01.jpg',
      caption:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.',
      likes: ["12312",'12321312321'],
      user: testUser,
      comments: [
        {'this is bob', 'hello'},
      ],
      externalLink: 'https://www.bloomberg.com/news/articles/2024-03-12/cognition-ai-is-a-peter-thiel-backed-coding-assistant',
      topic: "Python",
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'caption': caption,
      'likes': likes,
      'user': user,
      'comments': comments,
      'externalLink': externalLink,
      'imageUrl': imageUrl,
      'topic': topic,
    };
  }

  static fromMap(x) {}


}