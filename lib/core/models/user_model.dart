import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final double internetUsage;

  const UserModel({
    required this.id,
    required this.name,
    required this.internetUsage,
  });

  UserModel copyWith({String? id, String? name, double? internetUsage}) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      internetUsage: internetUsage ?? this.internetUsage,
    );
  }

  @override
  List<Object?> get props => [id, name, internetUsage];
}

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    return UserModel(
      id: reader.readString(),
      name: reader.readString(),
      internetUsage: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeDouble(obj.internetUsage);
  }
}
