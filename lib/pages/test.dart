import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:posty/core/network/data_loader.dart';
import 'package:posty/models/api_respone_model.dart';
import 'package:posty/models/posts_model.dart';

class MyWidget extends StatelessWidget {
  String _code = '';
  String _message = '';
  int currentPage = 1;
  final _scrollController = ScrollController();
  AllPostData allPostData = AllPostData(total: '0', posts: []);
  List<PostModel> posts = [];
  Future<String> fetchData() async {
    final response = await http.get(Uri.parse('uri'));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: posts.isEmpty ? _getPosts() : _loadMorePosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle the error state
          return Column(
            children: [
              Text('Error: ${snapshot.error}'),
              ElevatedButton(
                onPressed: () {
                  // Retry the operation
                  // You can call fetchData() again or any other error recovery logic.
                },
                child: Text('Retry'),
              ),
            ],
          );
        } else {
          // Display the data
          return Text('Data: ');
        }
      },
    );
  }

  Future<ApiResponse> getPosts(int page) async {
    final response = await DataLoader.getRequest(
        url: '${DataLoader.getPostsURL}?page=$page');

    if (response.code == '1') {
      return ApiResponse(code: '1', message: 'success', data: response.data);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _getPosts() async {
    final response = await getPosts(currentPage + 1);
    if (response.data != null) {
      allPostData = AllPostData.fromJson(response.data!['data']);
      posts.addAll(allPostData.posts);

      currentPage++;
    }
  }

  Future<void> _loadMorePosts() async {
    if (currentPage * 12 < int.parse(allPostData.total)) {
      final response = await getPosts(currentPage + 1);
      if (response.data != null) {
        allPostData = AllPostData.fromJson(response.data!['data']);
      }
    }
  }
}
