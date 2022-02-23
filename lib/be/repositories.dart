import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' show Client;
import 'package:submission_dasar_github/constants/constants.dart' show baseUrl;
import 'package:submission_dasar_github/constants/secret.dart' show apiKey;
import 'package:submission_dasar_github/model/user.dart';

abstract class IRepositories {
  Future<List<User>> getSearchUser(String search);

  Future<User> getDetailUser(String username);
}

class NetworkRepositories implements IRepositories {
  final Client _client = Client();
  final Map<String, String> _requestHeaders = {
    'Authorization': "token $apiKey"
  };

  static final NetworkRepositories _instances =
      NetworkRepositories._internal(); // singleton caranya gini di Dart

  factory NetworkRepositories() => _instances;

  NetworkRepositories._internal();

  @override
  Future<List<User>> getSearchUser(String search) async {
    final response = await _client.get(
        Uri.parse("${baseUrl}search/users?q=$search&per_page=100"),
        headers: _requestHeaders);
    if (response.statusCode == 200) {
      String editedResponse = json.encode(json.decode(response.body)["items"]);
      return usersFromJson(editedResponse);
    } else {
      throw "Error ${response.statusCode}";
    }
  }

  @override
  Future<User> getDetailUser(String username) async {
    final response = await _client.get(Uri.parse("${baseUrl}users/$username"),
        headers: _requestHeaders);
    if (response.statusCode == 200) {
      return userFromJson(response.body);
    } else {
      throw "Error ${response.statusCode}";
    }
  }
}
