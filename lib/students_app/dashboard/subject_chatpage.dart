import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:condition/condition.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:ivara_app/Controllers/FirebaseController.dart';
import 'package:ivara_app/students_app/dashboard/imageView.dart';
import 'package:ivara_app/students_app/notification.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:ivara_app/students_app/layout/sidebar.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class SubjectChatPage extends StatefulWidget {
  static String id = 'SubjectChatPage';
  int _class = 6;
  SubjectChatPage({Key key}) : super(key: key);

  @override
  _SubjectChatPageState createState() => _SubjectChatPageState();
}

class _SubjectChatPageState extends State<SubjectChatPage> {
  File _imageFile;
  String messageText;
  final messageTextController = TextEditingController();
  final _picker = ImagePicker();
  int index = 0;
  TextEditingController messageController = TextEditingController();
  Future<void> _pickImage(ImageSource source) async {
    PickedFile selected = await _picker.getImage(source: source);
    setState(() {
      if (selected != null) {
        _imageFile = File(selected.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final arguments = ModalRoute.of(context).settings.arguments as Map;
    print(arguments['subjectName']);
    CollectionReference chatRoomReference = FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(widget._class.toString())
        .collection(widget._class.toString())
        .doc(arguments['subjectName'].toString().toLowerCase())
        .collection(arguments['subjectName'].toString().toLowerCase());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0772a0),
        centerTitle: true,
        elevation: 1.0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        title: Text(
          'CHAT',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(LineAwesomeIcons.bell),
            color: Colors.white,
            highlightColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, NotificationPage.id);
            },
          )
        ],
      ),
      drawer: MyDrawer(
        onTap: (ctx, i) {
          setState(() {
            index = i;
            Navigator.pop(ctx);
          });
        },
      ),
      body: GetX<FirebaseController>(builder: (controller) {
        print(controller.firebaseUser.value.uid);
        return SafeArea(
          child: Conditioned.boolean(_imageFile == null,
              trueBuilder: () => Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      MessageStream(chatRoomReference, widget._class,
                          controller.firebaseUser.value.uid.toString()),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenHeight * 0.01,
                            vertical: screenWidth * 0.02),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              // Expanded(
                              //   child: TextField(
                              //     controller: messageTextController,
                              //     onChanged: (value) {
                              //       messageText = value;
                              //     },
                              //     decoration: InputDecoration(
                              //       contentPadding: EdgeInsets.symmetric(
                              //           vertical: 10.0, horizontal: 20.0),
                              //       hintText: 'Type your message here...',
                              //       border: InputBorder.none,
                              //     ),
                              //   ),
                              // ),
                              // FlatButton(
                              //   onPressed: () {},
                              //   child: Icon(LineAwesomeIcons.telegram_plane)
                              // ),

                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(35.0),
                                    boxShadow: [
                                      BoxShadow(
                                          offset: Offset(0, 3),
                                          blurRadius: 5,
                                          color: Colors.grey)
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: TextFormField(
                                            controller: messageController,
                                            focusNode: FocusNode(
                                              canRequestFocus: false,
                                            ),
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: null,
                                            decoration: InputDecoration(
                                              hintText: "Type Something...",
                                              hintStyle: TextStyle(
                                                color: Color(0xff0772a0),
                                              ),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.photo_camera,
                                            color: Color(0xff0772a0)),
                                        onPressed: () {
                                          sendImageMessage(
                                              chatRoomReference,
                                              controller.firebaseUser.value.uid
                                                  .toString(),
                                              controller
                                                  .firebaseUser.value.email
                                                  .toString());
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.attach_file,
                                            color: Color(0xff0772a0)),
                                        onPressed: () async {
                                          sendFiles(
                                              chatRoomReference,
                                              controller.firebaseUser.value.uid
                                                  .toString(),
                                              controller
                                                  .firebaseUser.value.email
                                                  .toString());
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Container(
                                padding: const EdgeInsets.all(15.0),
                                decoration: BoxDecoration(
                                    color: Color(0xff0772a0),
                                    shape: BoxShape.circle),
                                child: InkWell(
                                  child: Icon(
                                    LineAwesomeIcons.telegram,
                                    color: Colors.white,
                                  ),
                                  onTap: () {
                                    if (messageController.text
                                        .trim()
                                        .isNotEmpty) {
                                      sendTextMessage(
                                        chatRoomReference,
                                        controller.firebaseUser.value.uid
                                            .toString(),
                                        controller.firebaseUser.value.email,
                                      );
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              falseBuilder: () => Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: Container(
                          height: screenHeight - (screenHeight * 0.1763),
                          color: Colors.black,
                          child: Image.file(_imageFile),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: Container(
                            child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              child: Container(
                                  height: screenHeight * 0.07,
                                  width: screenWidth / 2,
                                  color: Colors.redAccent,
                                  child: IconButton(
                                      icon: Icon(LineAwesomeIcons.times),
                                      onPressed: () => {
                                            setState(() {
                                              _imageFile = null;
                                            })
                                          })),
                            ),
                            Container(
                                height: screenHeight * 0.07,
                                width: screenWidth / 2,
                                color: Colors.greenAccent,
                                child: IconButton(
                                    icon: Icon(LineAwesomeIcons.check),
                                    onPressed: null))
                          ],
                        )),
                      )
                    ],
                  )),
        );
      }),
    );
  }

  void sendTextMessage(CollectionReference chatRoomReference, String userId,
      String displayName) {
    String message = messageController.text;
    messageController.text = "";
    chatRoomReference.add(
      {
        'sender': userId,
        'message': message,
        'time': DateTime.now(),
        'type': "text",
        'senderName': displayName,
      },
    ).then((value) {});
  }

  void sendImageMessage(CollectionReference chatRoomReference, String userId,
      String displayName) async {
    PickedFile selected =
        await _picker.getImage(source: ImageSource.camera, imageQuality: 70);
    if (selected != null) {
      String docId = DateTime.now().toString();
      chatRoomReference.doc(docId).set(
        {
          'sender': userId,
          'time': DateTime.now(),
          'type': "image",
          'imageUrl': "",
          'message': "",
          'senderName': displayName,
        },
      );

      firebase_storage.TaskSnapshot taskSnapshot = await firebase_storage
          .FirebaseStorage.instance
          .ref('images/${DateTime.now()}')
          .putFile(new File(selected.path));
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print(downloadUrl);
      chatRoomReference.doc(docId).set(
        {
          'sender': userId,
          'time': DateTime.now(),
          'type': "image",
          'imageUrl': downloadUrl,
          'message': "",
          'senderName': displayName
        },
      ).then((value) {});
    }
  }

  void sendFiles(CollectionReference chatRoomReference, String userId,
      String displayName) async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'zip'],
      allowCompression: true,
    );
    String docId = DateTime.now().microsecondsSinceEpoch.toString();
    if (result != null) {
      File file = File(result.files.single.path);
      String fileName = result.files.single.name;
      String extensions = result.files.single.extension;
      chatRoomReference.doc(docId).set(
        {
          'sender': userId,
          'time': DateTime.now(),
          'type': 'file',
          'imageUrl': "",
          'message': "",
          'senderName': displayName,
          'fileName': fileName,
          'fileExtension': extensions
        },
      );

      firebase_storage.TaskSnapshot taskSnapshot = await firebase_storage
          .FirebaseStorage.instance
          .ref('images/${DateTime.now()}')
          .putFile(file);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print(downloadUrl);
      chatRoomReference.doc(docId).set(
        {
          'sender': userId,
          'time': DateTime.now(),
          'type': "file",
          'imageUrl': downloadUrl,
          'message': "",
          'senderName': displayName,
          'fileName': fileName,
          'fileExtension': extensions
        },
      ).then((value) {});
    } else {}
  }
}

class MessageStream extends StatelessWidget {
  CollectionReference chatRoomReference;
  int _class;
  String userId;
  MessageStream(this.chatRoomReference, this._class, this.userId);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: chatRoomReference.orderBy('time', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Expanded(
                child: Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ));
          }
          if (!snapshot.hasData) {
            return Expanded(
                child: Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ));
          }
          print(snapshot.data.docs.length);

          List<Map<String, dynamic>> messages = [];
          snapshot.data.docs.forEach((doc) {
            messages.add({
              'text': doc['message'],
              'sender': doc['sender'],
              'senderName': doc['senderName'],
              'time': doc['time'].toDate(),
              'type': doc['type'],
              'imageUrl': doc['type'] == "text" ? "" : doc['imageUrl'],
              'fileName': doc['type'] == 'file' ? doc['fileName'] : "",
              'fileExtension':
                  doc['type'] == 'file' ? doc['fileExtension'] : "",
            });
          });
          List<MessageBubble> messageBubbles = [];
          for (var message in messages) {
            final messageText = message['text'];
            final messageSender = message['sender'];
            DateTime messageTime = message['time'];
            String currentUser = userId;
            String imageUrl = message['imageUrl'];
            String type = message['type'];
            String messageSenderName = message['senderName'];
            String fileName = message['fileName'];
            String fileExtension = message['fileExtension'];
            final messageBubble = MessageBubble(
              text: messageText,
              sender: messageSender,
              time: "${messageTime.hour}:${messageTime.minute}",
              isMe: messageSender == currentUser,
              imageUrl: imageUrl,
              type: type,
              senderName: messageSenderName,
              fileName: fileName,
              fileExtension: fileExtension,
            );
            messageBubbles.add(messageBubble);
          }
          return Expanded(
              child: ListView(reverse: true, children: messageBubbles));
        });
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final String time;
  final bool isMe;
  final String imageUrl;
  final String type;
  final String senderName;
  final String fileName;
  final String fileExtension;
  MessageBubble({
    this.text,
    this.sender,
    this.isMe,
    this.time,
    this.imageUrl,
    this.type,
    this.senderName,
    this.fileName,
    this.fileExtension,
  });
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(1),
            child: Row(
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: screenHeight * 0.02),
                  child: Text(
                    senderName,
                    style: TextStyle(fontSize: 10, color: Color(0xff0772a0)),
                  ),
                )
              ],
            ),
          ),
          Material(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(13),
              bottomRight: Radius.circular(13),
              topLeft: isMe ? Radius.circular(13) : Radius.circular(0),
              topRight: isMe ? Radius.circular(0) : Radius.circular(13),
            ),
            elevation: 5,
            color: isMe ? Colors.white : Color(0xff0772a0),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  type == "text"
                      ? Text(
                          text,
                          style: TextStyle(
                              color: isMe ? Color(0xff0772a0) : Colors.white),
                        )
                      : type == "image"
                          ? Container(
                              width: screenWidth * 0.6,
                              height: 100,
                              child: imageUrl == ""
                                  ? Center(
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) =>
                                                ImageView(imageUrl, senderName),
                                          ));
                                        },
                                        child: Hero(
                                          tag: imageUrl,
                                          child: CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.fitWidth,
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                Center(
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        value: downloadProgress
                                                            .progress),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    ),
                            )
                          : Container(
                              width: screenWidth * 0.6,
                              height: 40,
                              child: imageUrl == ""
                                  ? Center(
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () async {
                                        print('dfdsfds');

                                        final status =
                                            await Permission.storage.request();
                                        if (status.isGranted) {
                                          final externalDir =
                                              await getExternalStorageDirectory();

                                          final taskId =
                                              await FlutterDownloader.enqueue(
                                            url: imageUrl,
                                            showNotification: true,
                                            fileName: fileName,
                                            savedDir: externalDir.path,
                                            openFileFromNotification: true,
                                          );
                                        } else {
                                          print("Permission Denied");
                                        }
                                      },
                                      child: Container(
                                          child: Row(
                                        children: [
                                          Image.asset(
                                            fileExtension == 'pdf'
                                                ? 'assets/pdf.png'
                                                : fileExtension == 'txt'
                                                    ? 'assets/txt.png'
                                                    : fileExtension == 'zip'
                                                        ? 'assets/zip.png'
                                                        : '',
                                          ),
                                          SizedBox(width: 5),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4,
                                            child: Text(
                                              "$fileName",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: isMe
                                                    ? Colors.black
                                                    : Colors.white,
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                    ),
                            ),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      time,
                      style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Color(0xAD0772A0) : Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
