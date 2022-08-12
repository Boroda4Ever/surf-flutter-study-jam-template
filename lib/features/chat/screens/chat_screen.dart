import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_local_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/image_page.dart';

import '../models/chat_message_location_dto.dart';

/// Main screen of chat app, containing messages.
class ChatScreen extends StatefulWidget {
  /// Repository for chat functionality.
  final IChatRepository chatRepository;
  final int chatId;

  /// Constructor for [ChatScreen].
  const ChatScreen({
    required this.chatRepository,
    required this.chatId,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _nameEditingController = TextEditingController();

  Iterable<ChatMessageDto> _currentMessages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: _ChatAppBar(
          controller: _nameEditingController,
          onUpdatePressed: _onUpdatePressed,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _ChatBody(
              messages: _currentMessages,
            ),
          ),
          _ChatTextField(onSendPressed: _onSendPressed),
        ],
      ),
    );
  }

  Future<void> _onUpdatePressed() async {
    final messages = await widget.chatRepository.getMessages();
    setState(() {
      _currentMessages = messages;
    });
  }

  Future<void> _onSendPressed(String messageText) async {
    final messages = await widget.chatRepository.sendMessage(messageText);
    setState(() {
      _currentMessages = messages;
    });
  }
}

class _ChatBody extends StatelessWidget {
  final Iterable<ChatMessageDto> messages;

  const _ChatBody({
    required this.messages,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ChatItem(
            chatData: messages.elementAt(index),
          ),
        ),
      ),
    );
  }
}

class _ChatTextField extends StatefulWidget {
  final ValueChanged<String> onSendPressed;

  _ChatTextField({
    required this.onSendPressed,
    Key? key,
  }) : super(key: key);

  @override
  State<_ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<_ChatTextField> {
  final _textEditingController = TextEditingController();

  List<double>? location;
  bool isAddingState = false;
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 12,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: mediaQuery.padding.bottom + 8,
          left: 16,
        ),
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.map)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.browse_gallery))
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.attach_file),
                  color: colorScheme.onSurface,
                ),
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: const InputDecoration(
                      hintText: 'Сообщение',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      widget.onSendPressed(_textEditingController.text),
                  icon: const Icon(Icons.send),
                  color: colorScheme.onSurface,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget {
  final VoidCallback onUpdatePressed;
  final TextEditingController controller;

  const _ChatAppBar({
    required this.onUpdatePressed,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFF13B5A2),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: onUpdatePressed,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final ChatMessageDto chatData;

  const _ChatMessage({
    required this.chatData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: chatData.chatUserDto is ChatUserLocalDto
          ? colorScheme.primary.withOpacity(.1)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Color(
                      (Random(chatData.chatUserDto.userId).nextDouble() *
                              0xFFFFFF)
                          .toInt())
                  .withOpacity(1.0),
              child: Center(
                child: Text(
                  chatData.chatUserDto.name != null
                      ? '${chatData.chatUserDto.name!.split(' ').first[0]}${chatData.chatUserDto.name!.split(' ').last[0]}'
                      : '',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    chatData.chatUserDto.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(chatData.message ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatItem extends StatelessWidget {
  final ChatMessageDto chatData;

  const ChatItem({
    required this.chatData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    LatLng? latLang;
    latLang = LatLng(51.509364, -0.12892);
    return Container(
      child: Row(
        mainAxisAlignment: chatData.chatUserDto is ChatUserLocalDto
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            //color: Colors.red,
            child: _ChatAvatar(userData: chatData.chatUserDto),
          ),
          SizedBox(
            width: 10,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
              //maxHeight: MediaQuery.of(context).size.width * 1,
            ),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 100, 240, 224),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chatData.chatUserDto.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  chatData.location != null
                      ? Container(
                          width: 300,
                          height: 100,
                          child: FlutterMap(
                            options: MapOptions(
                              center: LatLng(chatData.location!.first,
                                  chatData.location!.last),
                              zoom: 5,
                            ),
                            layers: [
                              TileLayerOptions(
                                urlTemplate:
                                    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                userAgentPackageName: 'com.example.app',
                              ),
                              MarkerLayerOptions(markers: [
                                Marker(
                                  point: LatLng(chatData.location!.first,
                                      chatData.location!.last),
                                  width: 279.0,
                                  height: 256.0,
                                  builder: (context) => Stack(
                                    children: <Widget>[
                                      Icon(
                                        Icons.add,
                                        size: 100,
                                      )
                                    ],
                                  ),
                                )
                              ])
                            ],
                          ),
                        )
                      : SizedBox(),
                  SizedBox(),
                  chatData.images?.length != null
                      ? Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: MediaQuery.of(context).size.width * 0.6,
                          child: ListView.builder(
                            itemCount: chatData.images!.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                ImagePage(
                                                    imageUrl: chatData
                                                        .images![index]))),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            fit: BoxFit.fitHeight,
                                            image: NetworkImage(
                                                chatData.images![index]),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    height: 20,
                                    thickness: 2,
                                  )
                                ],
                              );
                            },
                          ),
                        )
                      : SizedBox(),
                  Container(
                    child: Text(chatData.message ?? ''),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (chatData.createdDateTime.hour + 3).toString() +
                            ':' +
                            (chatData.createdDateTime.minute
                                        .toString()
                                        .length ==
                                    1
                                ? '0' +
                                    chatData.createdDateTime.minute.toString()
                                : chatData.createdDateTime.minute.toString()),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  static const double _size = 42;

  final ChatUserDto userData;

  const _ChatAvatar({
    required this.userData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: _size,
      height: _size,
      child: Material(
        shape: const CircleBorder(),
        child: Center(
          child: Text(
            userData.name != null
                ? '${userData.name!.split(' ').first[0]}${userData.name!.split(' ').last[0]}'
                : '',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}

// Widget popup() {
//   return Container(
//     alignment: Alignment.bottomCenter,
//     width: 279.0,
//     height: 256.0,
//     decoration: BoxDecoration(
//         image: DecorationImage(
//             image: AssetImage("assets/images/ic_info_window.png"),
//             fit: BoxFit.cover)),
//     child: CustomPopup(key: key),
//   );
// }
Widget marker() {
  return Container(
      alignment: Alignment.bottomCenter,
      child: Icon(
        Icons.mark_as_unread,
        size: 20,
      ));
}
