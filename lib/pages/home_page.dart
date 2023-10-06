import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:posty/core/constant/custom_colors.dart';
import 'package:posty/models/shared_class.dart';
import 'package:posty/core/network/data_loader.dart';
import 'package:posty/models/api_respone_model.dart';
import 'package:posty/models/posts_model.dart';
import 'package:posty/pages/add_new_post_page.dart';
import 'package:posty/widgets/error_page.dart';
import 'package:posty/widgets/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _code = '';
  String _message = '';
  int currentPage = 1;
  final _scrollController = ScrollController();
  AllPostData allPostData = AllPostData(total: '0', posts: []);
  List<PostModel> posts = [];
  @override
  void initState() {
    super.initState();
    _getPosts();
    _scrollController.addListener(() {
      if (_scrollController.offset ==
          _scrollController.position.maxScrollExtent) {
        _loadMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isLoading = true;
        });
        posts.isEmpty ? await _getPosts() : await _loadMorePosts();
        setState(() {
          _isLoading = false;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home'),
          centerTitle: true,
        ),
        body: SharedClass.internetStatus
            ? buildBody(context)
            : ErrorPage(
                errorMessage: _message,
                callBack: () async {
                  posts.isEmpty ? await _getPosts() : await _loadMorePosts();
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNewPostPage(),
                ));
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Container(
          height: MediaQuery.of(context).size.height,
          child: ListView.separated(
            controller: _scrollController,
            itemCount: posts.length + 1,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              if (index < posts.length) {
                final post = posts[index];
                if (post.hasMedia) {
                  log(post.media.first.src_url);
                }
                return PostCard(
                  username:
                      '${post.model['first_name']} ${post.model['last_name']}',
                  timeAgo: post.createdAt,
                  postTextContent: post.content,
                  imageUrl:
                      post.media.isNotEmpty ? post.media.first.src_url : '',
                  hasMedia: post.hasMedia,
                );
              } else {
                log('milllll');
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 35),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ));
    }
  }

  Future<void> _getPosts() async {
    setState(() {
      _isLoading = true;
    });

    final response = await getPosts(currentPage + 1);
    if (response.data != null) {
      allPostData = AllPostData.fromJson(response.data!['data']);
      posts.addAll(allPostData.posts);

      currentPage++;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadMorePosts() async {
    if (currentPage * 12 < int.parse(allPostData.total)) {
      final response = await getPosts(currentPage + 1);
      if (response.data != null) {
        allPostData = AllPostData.fromJson(response.data!['data']);
        setState(() {
          currentPage++;
          posts.addAll(allPostData.posts);
        });
      }
    }
  }

  Future<ApiResponse> getPosts(int page) async {
    final response = await DataLoader.getRequest(
        url: '${DataLoader.getPostsURL}?page=$page');

    setState(() {
      _code = response.code;
      _message = response.message;
    });
    if (response.code == '1') {
      return ApiResponse(code: '1', message: 'success', data: response.data);
    } else {
      return ApiResponse(
          code: GENERAL_ERROR_CODE, message: 'Error', data: response.data);
    }
  }
}
