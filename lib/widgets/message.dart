import 'package:flutter/material.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';

class Message extends StatelessWidget {
  Message({this.text, this.isMe, this.time, this.msgphoto});

  final String text;
  final bool isMe;
  final String time;
  final bool msgphoto;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Material(
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0))
                  : BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
              color: msgphoto
                  ? Colors.transparent
                  : isMe
                      ? Theme.of(context).accentColor
                      : Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: msgphoto
                    ? PinchZoomImage(
                        hideStatusBarWhileZooming: true,
                        image: Image.network(
                          text,
                          fit: BoxFit.fill,
                          height: 300,
                          width: 300,
                        ),
                      )
                    : Text(
                        text,
                        style: TextStyle(
                            color: isMe ? Colors.white : Colors.black54,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                time,
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
