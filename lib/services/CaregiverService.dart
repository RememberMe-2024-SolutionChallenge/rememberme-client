import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:remember_me/etc/url.dart';
import 'package:remember_me/model/AuthModel.dart';
import 'package:remember_me/model/BadgeModel.dart';
import 'package:remember_me/model/GroupModel.dart';
import 'package:remember_me/model/UserModel.dart';
import 'package:remember_me/model/VrModel.dart';
import 'package:remember_me/services/TokenService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CaregiverService extends ChangeNotifier {
  UserInfo user = UserInfo();
  List<Queue> queue = [];
  bool isRecipientExist = false;
  BadgeBundle badgeBundle = BadgeBundle();
  List<VrResources> vrResources = [];
  Future<void> getUserInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? token = sharedPreferences.getString("access_token");

    try {
      Response response = await Dio().get(
        "${baseUrl}/user",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        user = UserInfo.fromJson(response.data);
        isRecipientExist = true;
      } else if (response.statusCode == 401) {
        print("ACCESS_TOKEN 만료");
        TokenService().refreshToken();
        getUserInfo();
      } else {
        print('GET 요청 실패');
        print('Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('GET 요청 에러');
      print(e.toString());
    }
  }

  Future<void> getBadgeList(int year, int month) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? token = sharedPreferences.getString("access_token");
    try {
      Response response = await Dio().get(
        "${baseUrl}/badge?year=${year}&month=${month}",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        print('GET 요청 성공');
        badgeBundle = BadgeBundle.fromJson(response.data);
      } else if (response.statusCode == 401) {
        print("ACCESS_TOKEN 만료");
        TokenService().refreshToken();
      } else {
        print('GET 요청 실패');
        print('Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('GET 요청 에러');
      print(e.toString());
    }
  }

  Future<void> getResources() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? token = sharedPreferences.getString("access_token");

    try {
      Response response = await Dio().get(
        "${baseUrl}/vr-resource",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.toString());

        vrResources = (jsonData['vrResources'] as List)
            .map((item) => VrResources.fromJson(item))
            .toList();
      } else if (response.statusCode == 401) {
        print("ACCESS_TOKEN 만료");
        TokenService().refreshToken();
        getUserInfo();
      } else {
        print('GET 요청 실패');
        print('Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('GET 요청 에러');
      print(e.toString());
    }
  }

  Future<void> getQueue() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? token = sharedPreferences.getString("access_token");

    try {
      Response response = await Dio().get(
        "${baseUrl}/vr-resource/queue",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> jsonList = json.decode(response.toString());

        queue = jsonList.map((json) => Queue.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        print("ACCESS_TOKEN 만료");
        TokenService().refreshToken();
        getUserInfo();
      } else {
        print('GET 요청 실패');
        print('Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('GET 요청 에러');
      print(e.toString());
    }
  }

  Future<void> uploadVideo(String videoPath, PostVideo video) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? token = sharedPreferences.getString("access_token");
    FormData formData = FormData.fromMap({
      'video':
          await MultipartFile.fromFile(videoPath, filename: '${video.title}'),
      'title': video.title,
      'location': video.location,
    });
    try {
      Response response = await Dio().post(
        '${baseUrl}/vr-resource/source/scene',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201) {
        print('POST 성공');
      } else {
        print('POST 실패');
        print('Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('POST 요청 에러');
      print(e.toString());
    }
  }

  Future<void> uploadAvatar(
      String videoPath, String imagePath, PostAvatar avatar) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    String? token = sharedPreferences.getString("access_token");
    FormData formData = FormData.fromMap({
      'video':
          await MultipartFile.fromFile(videoPath, filename: '${avatar.title}'),
      'image':
          await MultipartFile.fromFile(imagePath, filename: '${avatar.title}'),
      'title': avatar.title,
      'gender': avatar.gender,
    });
    try {
      Response response = await Dio().post(
        '${baseUrl}/vr-resource/source/avatar',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201) {
        print('POST 성공');
      } else {
        print('POST 실패');
        print('Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('POST 요청 에러');
      print(e.toString());
    }
  }
}
