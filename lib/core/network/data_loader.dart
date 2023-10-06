import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/io_client.dart';
import 'package:posty/core/constant/custom_colors.dart';
import 'package:posty/models/shared_class.dart';
import 'package:posty/models/api_respone_model.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:http/http.dart' as http;

class DataLoader {
  static String baseUrl = 'http://api.media-nas.net/api';

  static String getPostsURL = '$baseUrl/posts/v1/all';
  static String addNewPostURL = '$baseUrl/posts/v1/add';

  static Future<ApiResponse> getRequest(
      {String? url,
      int? timeout = 20,
      Map<String, String> headers = const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization':
            'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vYXBpLm1lZGlhLW5hcy5uZXQvYXBpL3VzZXJzL3YxL2xvZ2luIiwiaWF0IjoxNjk1MTAzMjc1LCJleHAiOjE2OTc1MTUyNzUsIm5iZiI6MTY5NTEwMzI3NSwianRpIjoiMEFlUHJYbHdhYzVldFRucCIsInN1YiI6Ijg2MCIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.3MArC7a18eeOQ0IRXjpXjD8DvCiYTtI7CmRa0CzmM08',
      }}) async {
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    Uri parsedUrl = Uri.parse(url!);
    bool result = await InternetConnectionChecker().hasConnection;
    SharedClass.internetStatus = result;
    if (result) {
      log(result.toString());
      try {
        print('************ body request ***********');
        print(url);
        print(headers);
        final response = await http
            .get(parsedUrl, headers: headers)
            .timeout(Duration(seconds: timeout!));
        print('respone:  ${response.body.toString()}');
        log(name: 'POST_REQUEST_RESPONSE', response.body.toString());

        if (response.statusCode == 200 || response.statusCode == 201) {
          var json = jsonDecode(response.body);
          log(name: 'POST_REQUEST_JSON_RESPONSE', json.toString());
          return ApiResponse.fromJson({
            "code": "1",
            "message": "success",
            "data": json as Map<String, dynamic>
          });
        } else {
          print(response);
          return ApiResponse.fromJson({
            "code": GENERAL_ERROR_CODE,
            "message": "Server Error",
            "data": null,
          });
        }
      } on TimeoutException catch (e) {
        log(name: 'TimeoutException', e.toString());

        return ApiResponse.fromJson({
          "code": TIME_OUT_ERROR_CODE,
          "message": 'Timeout Error',
          "data": null,
        });
      } catch (e) {
        print('error : + ${e.toString()}');

        log(name: 'POST_REQUEST_ERROR', e.toString());
        return ApiResponse.fromJson({
          "code": GENERAL_ERROR_CODE,
          "message": 'General Error Ocurred',
          "data": null,
        });
      }
    } else {
      log(result.toString() + ' 2');

      return ApiResponse.fromJson({
        "code": NO_INTERNET_CONNECTION,
        "message": 'No Internet Connection',
        "data": null,
      });
    }
  }

  static Future<ApiResponse> postRequest({
    String? url,
    Map<String, dynamic>? body,
    int? timeout = 20,
    Map<String, String> headers = const {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vYXBpLm1lZGlhLW5hcy5uZXQvYXBpL3VzZXJzL3YxL2xvZ2luIiwiaWF0IjoxNjk1MTAzMjc1LCJleHAiOjE2OTc1MTUyNzUsIm5iZiI6MTY5NTEwMzI3NSwianRpIjoiMEFlUHJYbHdhYzVldFRucCIsInN1YiI6Ijg2MCIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.3MArC7a18eeOQ0IRXjpXjD8DvCiYTtI7CmRa0CzmM08',
    },
  }) async {
    bool result = await InternetConnectionChecker().hasConnection;
    SharedClass.internetStatus = result;
    Uri parsedUrl = Uri.parse(url!);
    if (result) {
      try {
        print('************ body request ***********');
        print('URL  $url');
        print('HEADERS : $headers');
        log('BODY: ${jsonEncode(body)}');

        final response = await http
            .post(parsedUrl, headers: headers, body: json.encode(body))
            .timeout(Duration(seconds: timeout!));
        log(name: 'POST_REQUEST_RESPONSE', response.body.toString());

        if (response.statusCode >= 200 && response.statusCode < 300) {
          var json = jsonDecode(response.body);
          log(name: 'POST_REQUEST_JSON_RESPONSE', json.toString());
          return ApiResponse.fromJson({
            "code": "1",
            "message": json['message'],
            "data": json as Map<String, dynamic>
          });
        } else {
          print(response);

          return ApiResponse.fromJson({
            "code": GENERAL_ERROR_CODE,
            "message": "Server Error",
            "data": null,
          });
        }
      } on TimeoutException catch (e) {
        log(name: 'TimeoutException', e.toString());
        return ApiResponse.fromJson({
          "code": TIME_OUT_ERROR_CODE,
          "message": "Timeout Error",
          "data": null,
        });
      } catch (e) {
        log(name: 'POST_REQUEST_ERROR', e.toString());
        return ApiResponse.fromJson({
          "code": TIME_OUT_ERROR_CODE,
          "message": 'General Error Ocurred',
          "data": null,
        });
      }
    } else {
      log(result.toString() + ' 2');

      return ApiResponse.fromJson({
        "code": NO_INTERNET_CONNECTION,
        "message": 'No Internet Connection',
        "data": null,
      });
    }
  }
}
