import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_local_dto.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

import 'chat_geolocation_geolocation_dto.dart';

/// Data transfer object representing simple chat message.
class ChatMessageDto {
  /// Author of message.
  final ChatUserDto chatUserDto;

  /// Chat message string.
  final String? message;

  final List<String>? images;

  final List<double>? location;

  /// Creation date and time.
  final DateTime createdDateTime;

  final int chatId;

  /// Constructor for [ChatMessageDto].
  const ChatMessageDto({
    required this.chatUserDto,
    required this.location,
    required this.chatId,
    required this.message,
    required this.createdDateTime,
    required this.images,
  });

  /// Named constructor for converting DTO from [StudyJamClient].
  ChatMessageDto.fromSJClient({
    required SjMessageDto sjMessageDto,
    required SjUserDto sjUserDto,
    required bool isUserLocal,
  })  : chatUserDto = isUserLocal
            ? ChatUserLocalDto.fromSJClient(sjUserDto)
            : ChatUserDto.fromSJClient(sjUserDto),
        message = sjMessageDto.text,
        createdDateTime = sjMessageDto.created,
        images = sjMessageDto.images,
        location = sjMessageDto.geopoint,
        chatId = sjMessageDto.chatId;

  @override
  String toString() =>
      'ChatMessageDto(chatUserDto: $chatUserDto, message: $message, createdDate: $createdDateTime)';
}
