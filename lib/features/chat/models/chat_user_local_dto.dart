import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_dto.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

/// Model representing local user.
///
/// As rule as user with the same nickname was entered when sending a message
/// from this device.
class ChatUserLocalDto extends ChatUserDto {
  /// Constructor for [ChatUserLocalDto].
  ChatUserLocalDto({
    required String name,
    required int userId,
  }) : super(name: name, userId: userId);

  /// Factory-like constructor for converting DTO from [StudyJamClient].
  ChatUserLocalDto.fromSJClient(SjUserDto sjUserDto)
      : super(name: sjUserDto.username, userId: sjUserDto.id);

  @override
  String toString() => 'ChatUserLocalDto(name: $name)';
}
