class Comment {
  // String id;
  String username;
  String text;

  Comment({
    // required this.id,
    required this.text,
    required this.username,
  });

  factory Comment.fake() {
    return Comment(
      // id: 'fakeID',
      text: 'This post was awesome I really enjoyed the test content. I really enjoyed looking at the funny stacked rocks!!!',
      username: 'User.fake()',
    );
  }
}
