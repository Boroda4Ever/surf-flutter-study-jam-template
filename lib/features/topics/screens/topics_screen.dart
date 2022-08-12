import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/topics/models/chat_topic_dto.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

import '../../chat/screens/chat_screen.dart';
import '../repository/chart_topics_repository.dart';
import 'create_topic_screen.dart';

/// Screen with different chat topics to go to.
class TopicsScreen extends StatefulWidget {
  /// Constructor for [TopicsScreen].
  final IChatTopicsRepository topicRepository;
  final storage = const FlutterSecureStorage();
  final String token;
  TopicsScreen({
    Key? key,
    required this.token,
  })  : topicRepository =
            ChatTopicsRepository(StudyJamClient().getAuthorizedClient(token)),
        super(key: key);

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  @override
  void initState() {
    super.initState();
  }

  final _nameEditingController = TextEditingController();
  Iterable<ChatTopicDto> _currentTopics = [];
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: _TopicAppBar(
          controller: _nameEditingController,
          onUpdatePressed: _onUpdatePressed,
          onAddPressed: _onAddPressed,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _currentTopics.length,
              itemBuilder: (context, index) => Column(
                children: [
                  TopicCard(
                      topic: _currentTopics.elementAt(index),
                      press: () {
                        Navigator.push<ChatScreen>(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              return ChatScreen(
                                chatId: _currentTopics.elementAt(index).id,
                                chatRepository: ChatRepository(
                                  StudyJamClient()
                                      .getAuthorizedClient(widget.token),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                  Divider(height: 10, thickness: 2, indent: 20, endIndent: 20)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onUpdatePressed() async {
    final topics = await widget.topicRepository
        .getTopics(topicsStartDate: DateTime.fromMillisecondsSinceEpoch(0));
    setState(() {
      _currentTopics = topics;
    });
  }

  Future<void> _onAddPressed() async {
    Navigator.push<CreateTopicScreen>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return CreateTopicScreen(
            topicRepository: widget.topicRepository,
          );
        },
      ),
    );
  }
}

class _TopicAppBar extends StatelessWidget {
  final VoidCallback onUpdatePressed;
  final VoidCallback onAddPressed;
  final TextEditingController controller;

  const _TopicAppBar({
    required this.onUpdatePressed,
    required this.onAddPressed,
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
            onPressed: onAddPressed,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: onUpdatePressed,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class TopicCard extends StatelessWidget {
  const TopicCard({
    Key? key,
    required this.topic,
    required this.press,
  }) : super(key: key);

  final ChatTopicDto topic;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 20 * 0.75),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.name.toString(),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    Opacity(
                      opacity: 0.64,
                      child: Text(
                        topic.description ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: 0.64,
              child: Column(
                children: [
                  Text(
                    'Создана',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    topic.created.day.toString() +
                        '.' +
                        topic.created.month.toString() +
                        '.' +
                        topic.created.year.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    (topic.created.hour + 3).toString() +
                        ':' +
                        (topic.created.minute.toString().length == 1
                            ? '0' + topic.created.minute.toString()
                            : topic.created.minute.toString()),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
