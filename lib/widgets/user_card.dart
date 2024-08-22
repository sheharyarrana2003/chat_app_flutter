import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/date_format.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/widgets/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.02, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      child: InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => ChatPage(user: widget.user)));
          },
          child: StreamBuilder(
            stream: API.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final _list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (_list.isNotEmpty) {
                _message = _list[0];
              }
              return ListTile(
                  leading: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) => ProfileDialog(
                                user: widget.user,
                              ));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * 0.3),
                      child: CachedNetworkImage(
                        width: mq.height * 0.055,
                        height: mq.height * 0.055,
                        imageUrl: widget.user.image,
                        errorWidget: (context, url, error) => CircleAvatar(
                          child: Icon(CupertinoIcons.person),
                        ),
                      ),
                    ),
                  ),
                  title: Text(widget.user.name),
                  subtitle: Text(_message != null
                      ? _message!.type == Type.image
                          ? 'Image'
                          : _message!.msg
                      : widget.user.about),
                  trailing: _message == null
                      ? null
                      : _message!.read.isEmpty &&
                              _message!.fromId != API.user.uid
                          ? Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.shade400,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            )
                          : Text(
                              DateFormat.getLastMessageDate(
                                  context: context, time: _message!.sent),
                              style: TextStyle(color: Colors.black),
                            ));
            },
          )),
    );
  }
}
