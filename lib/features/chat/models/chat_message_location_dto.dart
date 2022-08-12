import 'package:surf_practice_chat_flutter/features/chat/models/chat_geolocation_geolocation_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_dto.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

/// Data transfer object representing geolocation chat message.
class ChatMessageGeolocationDto extends ChatMessageDto {
  /// Location point.
  //final ChatGeolocationDto location;

  /// Constructor for [ChatMessageGeolocationDto].
  ChatMessageGeolocationDto({
    required ChatUserDto chatUserDto,
    required List<double> location,
    required String message,
    required DateTime createdDate,
    required List<String> images,
    required int chatId,
  }) : super(
            chatUserDto: chatUserDto,
            message: message,
            images: images,
            createdDateTime: createdDate,
            location: location,
            chatId: chatId);

  /// Named constructor for converting DTO from [StudyJamClient].
  ChatMessageGeolocationDto.fromSJClient({
    required SjMessageDto sjMessageDto,
    required SjUserDto sjUserDto,
  }) : super(
            createdDateTime: sjMessageDto.created,
            message: sjMessageDto.text,
            chatUserDto: ChatUserDto.fromSJClient(sjUserDto),
            images: sjMessageDto.images,
            location: sjMessageDto.geopoint,
            chatId: sjMessageDto.chatId);

  @override
  String toString() =>
      'ChatMessageGeolocationDto(location: $location) extends ${super.toString()}';
}
