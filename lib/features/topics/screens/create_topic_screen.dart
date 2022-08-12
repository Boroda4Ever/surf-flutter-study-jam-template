import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:surf_practice_chat_flutter/features/topics/models/chat_topic_send_dto.dart';

import '../../chat/repository/chat_repository.dart';
import '../repository/chart_topics_repository.dart';

/// Screen, that is used for creating new chat topics.
class CreateTopicScreen extends StatefulWidget {
  /// Constructor for [CreateTopicScreen].
  final IChatTopicsRepository topicRepository;
  const CreateTopicScreen({
    Key? key,
    required this.topicRepository,
  }) : super(key: key);

  @override
  State<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  static const Color primaryColor = Color(0xFF13B5A2);
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onSendTopic() async {
    final topic = await widget.topicRepository.createTopic(ChatTopicSendDto(
        name: _titleController.text, description: _descriptionController.text));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: _TopicAppBar(),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              onChanged: ((value) => setState(() {})),
              decoration: InputDecoration(
                labelText: "Название",
                border: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF000000),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(9.0),
                  ),
                ),
                labelStyle: TextStyle(
                    color: _titleController.text.isNotEmpty
                        ? primaryColor
                        : Color(0xff747881)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: primaryColor,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(9.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              onChanged: ((value) => setState(() {})),
              controller: _descriptionController,
              decoration: InputDecoration(
                  labelText: 'Описание',
                  labelStyle: TextStyle(
                      color: _descriptionController.text.isNotEmpty
                          ? primaryColor
                          : Color(0xff747881)),
                  hintText: 'опишите вашу тему',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 2.0,
                    ),
                  )),
              maxLines: 3,
              inputFormatters: [
                LengthLimitingTextInputFormatter(100),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onSendTopic,
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  textStyle: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              child: const Text("Создать тему"),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicAppBar extends StatelessWidget {
  const _TopicAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFF13B5A2),
    );
  }
}
