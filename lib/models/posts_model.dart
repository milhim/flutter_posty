import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AllPostData {
  final String total;
  final List<PostModel> posts;
  AllPostData({
    required this.total,
    required this.posts,
  });

  factory AllPostData.fromJson(Map<String, dynamic> map) {
    return AllPostData(
      total: map['total'].toString(),
      posts: map['items']
          .map<PostModel>((jsonUserModel) => PostModel.fromJson(jsonUserModel))
          .toList(),
    );
  }
}

class PostModel {
  final String id;
  final String userId;
  final String parentId;
  final String modelType;
  final String modelId;
  final String content;
  final String index;
  final String status;
  final String type;
  final String createdAt;
  final String updatedAt;
  final String interactionsCount;
  final Map<String, dynamic> interactionsCountTypes;
  final String commentsCount;
  final String sharesCount;
  final String tagsCount;
  final bool sharingPost;
  final bool hasMedia;
  final bool saved;
  final bool tagged;
  final List<MediaModel> media;
  final Map<String, dynamic> model;

  PostModel(
      {required this.id,
      required this.userId,
      required this.parentId,
      required this.modelType,
      required this.modelId,
      required this.content,
      required this.index,
      required this.status,
      required this.type,
      required this.createdAt,
      required this.updatedAt,
      required this.interactionsCount,
      required this.interactionsCountTypes,
      required this.commentsCount,
      required this.sharesCount,
      required this.tagsCount,
      required this.sharingPost,
      required this.hasMedia,
      required this.saved,
      required this.tagged,
      required this.media,
      required this.model});

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
        id: json['id'].toString(),
        userId: json['user_id'].toString(),
        parentId: json['parent_id'].toString(),
        modelType: json['model_type'].toString(),
        modelId: json['model_id'].toString(),
        content: json['content'] ?? '',
        index: json['index'].toString(),
        status: json['status'].toString(),
        type: json['type'].toString(),
        createdAt: json['created_at'].toString(),
        updatedAt: json['updated_at'].toString(),
        interactionsCount: json['interactions_count'].toString(),
        interactionsCountTypes:
            Map<String, int>.from(json['interactions_count_types'] as Map),
        commentsCount: json['comments_count'].toString(),
        sharesCount: json['shares_count'].toString(),
        tagsCount: json['tags_count'].toString(),
        sharingPost: json['sharing_post'] ?? false,
        hasMedia: json['has_media'] ?? false,
        saved: json['saved'] ?? false,
        tagged: json['taged'] ?? false,
        media: json['media']
            .map<MediaModel>(
                (jsonUserModel) => MediaModel.fromJson(jsonUserModel))
            .toList(),
        model: Map<String, dynamic>.from(json['model'] as Map));
  }
}

class MediaModel {
  final String id;
  final String src_url;
  MediaModel({
    required this.id,
    required this.src_url,
  });

  factory MediaModel.fromJson(Map<String, dynamic> map) {
    return MediaModel(
      id: map['id'].toString(),
      src_url: map['src_url'].toString(),
    );
  }
}
