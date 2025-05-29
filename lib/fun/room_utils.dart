import 'package:astral/k/models/room.dart';
import 'package:astral/fun/random_name.dart';
import 'package:uuid/uuid.dart';
import 'package:astral/k/app_s/aps.dart';
export 'room_utils.dart';

void addEncryptedRoom(
  bool isEncrypted,
  String? name,
  String? roomname,
  String? password,
) {
  var room = Room(
    name: name ?? RandomName(),
    encrypted: isEncrypted,
    roomName: isEncrypted ? Uuid().v4() : (roomname ?? ""),
    password: isEncrypted ? Uuid().v4() : (password ?? ""),
    tags: [],
  );
  Aps().addRoom(room);
}