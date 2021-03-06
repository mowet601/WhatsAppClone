import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:stacked/stacked.dart';
import 'private_chat_viewmodel.dart';

import '../../core/models/contact_entity.dart';
import '../../core/models/message.dart';
import '../../core/shared/constants.dart';

import '../../utils/datetime.dart';

import '../../core/widgets/ui_elements/spinkit_loading_indicator.dart';

class PrivateChatPage extends StatefulWidget {
  @override
  _PrivateChatPageState createState() => _PrivateChatPageState();

  final ContactEntity contactEntity;
  PrivateChatPage(this.contactEntity);
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  PrivateChatViewModel _model;
  TextEditingController _textEditingController;
  ScrollController _scrollController;
  Future<List<Message>> _msgs;

  @override
  initState() {
    // init controllers
    _textEditingController = TextEditingController();
    _scrollController = ScrollController();
    // scroll messsages to the bottom of the listview
    _scrollToBottom(500);
    super.initState();
  }

  // build appbar popup menu button
  Widget _buildPopUpMenuButton() {
    return PopupMenuButton(
      child: Icon(Icons.more_vert),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
              child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text('View contact'),
          )),
          PopupMenuItem(
              child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text('Search'),
          )),
          PopupMenuItem(
              child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text('Mute notifications'),
          )),
          PopupMenuItem(
              child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text('Wallpaper'),
          )),
          PopupMenuItem(
              child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text('Clear chat'),
          )),
          PopupMenuItem(
              child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text('Delete chat'),
          )),
        ];
      },
    );
  }

  // build messages list
  Widget _buildMsgList() {
    return FutureBuilder<List<Message>>(
      key: ValueKey('LongList'),
      future: _msgs,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.hasData) {
          return Flexible(
              child: Scrollbar(
                  child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(4.0),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return _buildMessage(snapshot.data[index]);
            },
          )));
        }
        return Center(child: SpinkitLoadingIndicator());
      },
    );
  }

  // build message listile widget
  Widget _buildMessage(Message message) {
    var timestamp = formatDateTime(message.timestamp);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment:
            message.fromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              child: message.messageType == MessageType.text
                  ? RichText(
                      text: TextSpan(children: [
                        TextSpan(text: message.text),
                        TextSpan(text: '  '),
                        TextSpan(
                            text: timestamp,
                            style: TextStyle(
                                color: Colors.grey[300],
                                fontStyle: FontStyle.italic,
                                fontSize: 12.0))
                      ]),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.file(
                        File(message.text),
                        fit: BoxFit.cover,
                      ),
                    ),
              padding: message.messageType == MessageType.text
                  ? const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0)
                  : const EdgeInsets.all(0.0),
              decoration: BoxDecoration(
                  color: message.fromUser ? kPrimaryColor : Colors.grey[800],
                  borderRadius: BorderRadius.circular(10.0)),
            ),
          ),
        ],
      ),
    );
  }

  // build compose message
  Widget _buildComposeMsg() {
    return Container(
      key: ValueKey('compose'),
      padding: EdgeInsets.only(left: 5.0, bottom: 4.0, right: 4.0),
      decoration: BoxDecoration(color: Theme.of(context).canvasColor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
              child: TextField(
            controller: _textEditingController,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration.collapsed(hintText: 'Send a message'),
            onSubmitted: _onTextMsgSubmitted,
          )),
          IconButton(
              key: ValueKey('sendMsg'),
              icon: Icon(Icons.send),
              onPressed: () => _onTextMsgSubmitted(_textEditingController.text))
        ],
      ),
    );
  }

  // submitted text message
  void _onTextMsgSubmitted(String msg, {bool fromUser = true}) async {
    // non null of empty validation
    if (msg == null || msg.isEmpty) return;
    // clear text field
    if (fromUser) {
      _textEditingController.clear();
    }
    // create new Message instacne
    var message = Message(
        foreignID: widget.contactEntity.id,
        text: msg.trim(),
        fromUser: fromUser,
        timestamp: DateTime.now(),
        messageType: MessageType.text);
    // insert message to local db
    await _model.insertMessage(message);
    if (mounted) {
      setState(() {
        // get messages from local db and rebuild msgs list
        //_msgs = _model.getMessages(widget.contactEntity);
        // scroll to bottom listview
        _scrollToBottom(0);
        // reponse from bot if message from user
        if (fromUser) {
          evokeMsgResponse(msg);
        }
      });
    }
  }

  // submit message response from DialogFlow API
  void evokeMsgResponse(String query) async {
    var msgResponse = await _model.msgResponse(query);
    if (msgResponse != null && msgResponse.isNotEmpty) {
      _onTextMsgSubmitted(msgResponse, fromUser: false);
    }
  }

  // animate to bottom of messages listview
  void _scrollToBottom(int milliseconds) {
    Timer(Duration(milliseconds: 500), () {
      if (mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PrivateChatViewModel>.nonReactive(
        viewModelBuilder: () => PrivateChatViewModel(),
        builder: (context, model, child) {
          _model = model;
          _msgs = model.getMessages(widget.contactEntity);
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.contactEntity.displayName),
              actions: [
                IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () =>
                      _model.launchCall(widget.contactEntity.phoneNumber),
                ),
                _buildPopUpMenuButton()
              ],
            ),
            body: Column(
              children: [
                _buildMsgList(),
                Divider(
                  height: 2.0,
                  thickness: 1.0,
                ),
                _buildComposeMsg()
              ],
            ),
          );
        });
  }
}
