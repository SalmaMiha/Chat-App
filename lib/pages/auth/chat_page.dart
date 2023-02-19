import 'package:chat_app/pages/auth/group_info.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/widgets/message_tile.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage({Key? key,
    required this.groupId,
    required this.groupName,
    required this.userName}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>?  chats;
  TextEditingController messageController=TextEditingController();
  String admin="";
  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin(){
    DatabaseService().getChats(widget.groupId).then((val){
      setState(() {
        chats=val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val){
      admin=val;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.groupName,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(onPressed: (){
            nextScreen(context, GroupInfo(
              groupId: widget.groupId,
              groupName: widget.groupName,
              adminName: admin,
            ));
          }, icon: const Icon(Icons.info)
          ),
        ],
      ),
      body: Stack(
        children: <Widget> [
          chatMessage(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[700],
              child: Row(
                children: [
                  Expanded(child: TextFormField(
                    controller: messageController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Send a message....",
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  )),
                  const SizedBox(width: 12,),
                  GestureDetector(
                    onTap: (){
                      sendMessage();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
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
  chatMessage() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshaot) {
        return snapshaot.hasData ? ListView.builder(
          itemCount: snapshaot.data.docs.length,
          itemBuilder: (context, index){
            return MessageTile(
                message: snapshaot.data.docs[index]['message'],
                sender: snapshaot.data.docs[index]['sender'],
                sentByMe: widget.userName==snapshaot.data.docs[index]['sender']);
          },
        )
            : Container();
      },
    );
  }
  sendMessage() {
    if(messageController.text.isNotEmpty){
      Map<String, dynamic> chatMessageMap={
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().microsecondsSinceEpoch,
      };
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
