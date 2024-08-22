import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/date_format.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = API.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      API.updateMessageRead(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.03
                : mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 170, 202, 228),
              border: Border.all(color: Colors.lightBlue),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.message.type == Type.text
                    ? Text(
                        widget.message.msg,
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          width: mq.height * 0.3,
                          height: mq.height * 0.35,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          imageUrl: widget.message.msg,
                          errorWidget: (context, url, error) => CircleAvatar(
                            child: Icon(
                              Icons.image,
                              size: 70,
                            ),
                          ),
                        ),
                      ),
                Text(
                  DateFormat.getFormatDate(
                      context: context, time: widget.message.sent),
                  style: TextStyle(color: Colors.black54, fontSize: 8),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.03
                : mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 170, 228, 183),
              border: Border.all(color: const Color.fromARGB(255, 3, 244, 123)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                widget.message.type == Type.text
                    ? Text(
                        widget.message.msg,
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          width: mq.height * 0.3,
                          height: mq.height * 0.35,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          imageUrl: widget.message.msg,
                          errorWidget: (context, url, error) => CircleAvatar(
                            child: Icon(
                              Icons.image,
                              size: 70,
                            ),
                          ),
                        ),
                      ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat.getFormatDate(
                          context: context, time: widget.message.sent),
                      style: TextStyle(color: Colors.black54, fontSize: 8),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.done_all_rounded,
                      color: widget.message.read.isNotEmpty
                          ? Colors.blue
                          : Colors.grey,
                      size: 20,
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  void showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(shrinkWrap: true, children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 120),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),
            widget.message.type == Type.image
                ? OptionItem(
                    icon: Icon(
                      Icons.download_rounded,
                      color: Colors.blue,
                    ),
                    name: "Save Image",
                    onTap: () async {
                      try {
                        await GallerySaver.saveImage(widget.message.msg,
                                albumName: "We Chat")
                            .then((success) {
                          Navigator.pop(context);
                          if (success != null && success) {
                            Dialogs.showSnackBar(
                                context, "Image Succesfully Saved");
                          }
                        });
                      } catch (e) {
                        print("Error in saving Picture");
                      }
                    })
                : OptionItem(
                    icon: Icon(
                      Icons.copy_all_rounded,
                      color: Colors.blue,
                    ),
                    name: "Copy Text",
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then((value) {
                        Navigator.pop(context);
                        Dialogs.showSnackBar(context, "Text Copied");
                      });
                    }),
            if (isMe)
              Divider(
                color: Colors.black54,
                endIndent: 10,
                indent: 10,
              ),
            if (widget.message.type == Type.text && isMe)
              OptionItem(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.blue,
                  ),
                  name: "Edit Message",
                  onTap: () {
                    Navigator.pop(context);
                    _showMessageUpdateDialog();
                  }),
            if (isMe)
              OptionItem(
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                  name: "Delete Message",
                  onTap: () async {
                    await API.deleteMessage(widget.message).then((value) {
                      Navigator.pop(context);
                    });
                  }),
            Divider(
              color: Colors.black54,
              endIndent: 10,
              indent: 10,
            ),
            OptionItem(
                icon: Icon(
                  Icons.remove_red_eye,
                  color: Colors.blue,
                ),
                name:
                    "Send At ${DateFormat.getMessageTime(context: context, time: widget.message.sent)}",
                onTap: () {}),
            OptionItem(
                icon: Icon(
                  Icons.remove_red_eye,
                  color: Colors.red,
                ),
                name: widget.message.read.isEmpty
                    ? "Read At: Not Seen yet "
                    : "Read At ${DateFormat.getMessageTime(context: context, time: widget.message.read)}",
                onTap: () {}),
          ]);
        });
  }

  void _showMessageUpdateDialog() {
    String updateMessage = widget.message.msg;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding:
                  EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 20,
                  ),
                  Text("Update Message"),
                ],
              ),
              content: TextFormField(
                initialValue: updateMessage,
                maxLines: null,
                onChanged: (value) => updateMessage = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                )),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    API.updateMessage(widget.message, updateMessage);
                  },
                  child: Text(
                    "Update",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                )
              ],
            ));
  }
}

class OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const OptionItem(
      {super.key, required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              "   $name",
              style: TextStyle(color: Colors.black54, letterSpacing: 0.5),
            ))
          ],
        ),
      ),
    );
  }
}
