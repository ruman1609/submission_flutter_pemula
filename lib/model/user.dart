import 'dart:convert';

class User {
  final int _id;
  final String _username;
  final String _picUrl;
  bool isLoading = false;
  String? _link;
  String? _name;
  String? _location;
  int? _followers;
  int? _following;
  int? _publicRepos;

  User({required int id, required String username, required String picUrl})
      : _id = id,
        _username = username,
        _picUrl = picUrl;

  User.detail(
      {required int id,
      required String username,
      required String picUrl,
      String? link,
      String? name,
      String? location,
      int? followers,
      int? following,
      int? publicRepos})
      : _id = id,
        _username = username,
        _picUrl = picUrl,
        _link = link,
        _name = name,
        _location = location,
        _followers = followers,
        _following = following,
        _publicRepos = publicRepos;

  factory User.searchFromJson(Map<String, dynamic> map) =>
      User(id: map["id"], username: map["login"], picUrl: map["avatar_url"]);

  factory User.detailFromJson(Map<String, dynamic> map) => User.detail(
      id: map["id"],
      username: map["login"],
      picUrl: map["avatar_url"],
      link: map["html_url"],
      name: map["name"],
      location: map["location"],
      followers: map["followers"],
      following: map["following"],
      publicRepos: map["public_repos"]);

  Map<String, dynamic> searchToJson() =>
      {"id": _id, "login": _username, "avatar_url": _picUrl};

  Map<String, dynamic> detailToJson() => {
        "id": _id,
        "login": _username,
        "avatar_url": _picUrl,
        "html_url": _link,
        "name": _name,
        "location": _location,
        "followers": _followers,
        "following": _following,
        "public_repos": _publicRepos
      };

  @override
  String toString() => "User{id: $_id, username: $_username, picUrl: $_picUrl}";

  int get id => _id;

  String get username => _username;

  String get picUrl => _picUrl;

  int get publicRepos => _publicRepos ?? 0;

  int get following => _following ?? 0;

  int get followers => _followers ?? 0;

  String get location => _location ?? "";

  String get name => _name ?? "";

  String get link => _link ?? "";
}

List<User> usersFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return List<User>.from(data.map((user) => User.searchFromJson(user)));
}

User userFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return User.detailFromJson(data);
}

String userSearchToJson(User data) {
  final jsonData = data.searchToJson();
  return json.encode(jsonData);
}
