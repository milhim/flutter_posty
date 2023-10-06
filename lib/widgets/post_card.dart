import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostCard extends StatefulWidget {
  final String username;
  final String timeAgo;
  final String postTextContent;
  final String imageUrl;
  final bool hasMedia;

  PostCard(
      {required this.username,
      required this.timeAgo,
      required this.postTextContent,
      required this.imageUrl,
      required this.hasMedia});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String reaction = 'Like';
  Icon icon = Icon(
    Icons.thumb_up,
    // color: Colors.blueAccent,
  );
  // Default reaction
  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.parse(widget.timeAgo);
    Duration difference = DateTime.now().difference(dateTime);
    String timeAgo = formatTimeAgo(difference);

    return Card(
      elevation: 2.0,
      margin: EdgeInsets.all(4.0),
      child: Column(
        children: <Widget>[
          ListTile(
            // leading: CircleAvatar(
            //   backgroundImage: NetworkImage(
            //     'https://example.com/your_profile_image_url.jpg',
            //   ),
            // ),
            title: Text(widget.username),
            subtitle: Text(timeAgo),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              widget.postTextContent,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          widget.hasMedia
              ? CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  onLongPress: _showReactionMenu,
                  onTap: () {
                    setState(() {
                      icon = Icon(
                        Icons.thumb_up,
                        color: Colors.blueAccent,
                      );
                    });
                  },
                  onDoubleTap: () {
                    setState(() {
                      icon = Icon(
                        Icons.thumb_up,
                        color: Colors.white,
                      );
                    });
                  },
                  child: Row(
                    children: [
                      icon,
                      SizedBox(
                        width: 10,
                      ),
                      Text(reaction),
                    ],
                  ),
                ),
                Icon(Icons.comment),
                Icon(Icons.share),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReactionMenu() async {
    final selectedReaction = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Choose a reaction'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Like');
                setState(() {
                  icon = Icon(
                    Icons.thumb_up,
                    color: Colors.blueAccent,
                  );
                });
              },
              child: Row(
                children: [
                  Icon(
                    Icons.thumb_up,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(width: 8),
                  Text('Like'),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Love');
                setState(() {
                  icon = Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                  );
                });
              },
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                  ),
                  SizedBox(width: 8),
                  Text('Love'),
                ],
              ),
            ),
            // Add more reaction options here
          ],
        );
      },
    );

    if (selectedReaction != null) {
      setState(() {
        reaction = selectedReaction;
      });
    }
  }

  String formatTimeAgo(Duration difference) {
    if (difference.inDays > 365) {
      int years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays >= 30) {
      int months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }
}
