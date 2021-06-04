import 'dart:convert';
import 'dart:io';
import 'package:Postly/lastUser.dart';
import 'package:Postly/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class UserAPI extends ChangeNotifier {
  List<UserModel> _users = [];
  List<UserModel> get users => _users;
  UserModel _randomUser;
  UserModel get randomUser => _randomUser;

  LastUserModel laastUser;

  // ignore: unused_field
  LastUserModel _lastuser;
  LastUserModel get lastUser => _lastuser;

  Future getUsers({
    http.Client client,
    String type,
  }) async {
    final String url =
        'https://jsonplaceholder.typicode.com/${type == 'post' ? 'post' : 'users'}';
    final _client = client ?? http.Client();

    try {
      print(url);

      Postly.isUserAvail = false;
      final response = await _client?.get(
        url,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      var data = response.body;
      Iterable items = json.decode(data);
      List<UserModel> dataSets =
          items.map((item) => UserModel.fromJson(item)).toList();
      _users = dataSets;
      _randomUser = (_users.toList()..shuffle()).first;

      final savedUser = json.encode(_randomUser);
      Postly.storage.write(key: 'savedUser', value: savedUser);
      notifyListeners();

      if (randomUser.email.isNotEmpty) {
        print('got random');
        Postly.isUserAvail = true;
        notifyListeners();
        return randomUser;
      }

      if (_users.length >= 1) {
        notifyListeners();
        return users;
      }
    } catch (error) {
      throw error;
    }
  }

  Future getSavedUser() async {
    var savedUser = await Postly.storage.read(key: 'savedUser');
    var data = json.decode(savedUser);
    _lastuser = LastUserModel.fromJson(data);
    Postly.isUserAvail = true;
    notifyListeners();
    return lastUser;
  }
}

class PostsAPI {
  static Future getPosts({
    http.Client client,
    String type,
  }) async {
    final String url =
        'https://jsonplaceholder.typicode.com/${type == 'post' ? 'post' : 'users'}';
    final _client = client ?? http.Client();

    try {
      print(url);
      // List<UserModel> users = [];
      Postly.isUserAvail = false;

      final response = await _client?.get(
        url,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );
      var data = response.body;
      List<dynamic> posts = json.decode(data);
      return posts;
    } catch (error) {
      throw error;
    }
  }
}
