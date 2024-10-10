// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extracted_text_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExtractedTextModelAdapter extends TypeAdapter<ExtractedTextModel> {
  @override
  final int typeId = 2;

  @override
  ExtractedTextModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExtractedTextModel(
      videoPath: fields[0] as String,
      text: (fields[1] as List)
          .map((dynamic e) => (e as Map).cast<int, String>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, ExtractedTextModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.videoPath)
      ..writeByte(1)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtractedTextModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
