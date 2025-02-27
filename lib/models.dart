import 'package:flutter/material.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:nfc_plinkd/l10n/app_localizations.dart';
import 'package:nfc_plinkd/utils/index.dart';

class LinkError extends CustomError {
  LinkError({required super.title, required super.content});

  // ignore: non_constant_identifier_names
  static LinkError DataNotFound(BuildContext context) {
    final l10n = S.of(context)!;
    return LinkError(
      title: l10n.linkError_dataNotFound_title,
      content: l10n.linkError_dataNotFound_content,
    );
  }
}

class LinkModel {
  final String id;
  final String? name;
  final int createTime;
  final int modifyTime;

  LinkModel({
    required this.id,
    required this.createTime,
    required this.modifyTime,
    this.name,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': (name?.isNotEmpty ?? false)
           ? name : null,
    'created_at': createTime,
    'modified_at': modifyTime,
  };

  LinkModel copyWith({
    String? id,
    String? name,
    int? createTime,
    int? modifyTime,
  }) => LinkModel(
    id: id ?? this.id,
    name: name ?? this.name,
    createTime: createTime ?? this.createTime,
    modifyTime: modifyTime ?? this.modifyTime,
  );

  factory LinkModel.fromMap(
    Map<String, dynamic> map,
  ) => LinkModel(
    id: map['id'] as String,
    name: map['name'] as String?,
    createTime: map['created_at'] as int,
    modifyTime: map['modified_at'] as int,
  );
}

class ResourceModel {
  final String linkId;
  final String path;
  final ResourceType type;
  final String? description;

  ResourceModel({
    required this.linkId,
    required this.type,
    required this.path,
    this.description,
  });

  Map<String, dynamic> toMap() => {
    'link_id': linkId,
    'type': type.index,
    'path': path,
    'description': (description?.isNotEmpty ?? false)
                  ? description : null,
  };

  ResourceModel copyWith({
    String? linkId,
    String? path,
    ResourceType? type,
    String? description,
  }) => ResourceModel(
    linkId: linkId ?? this.linkId,
    path: path ?? this.path,
    type: type ?? this.type,
    description: description ?? this.description,
  );

  factory ResourceModel.fromMap(
    Map<String, dynamic> map,
  ) => ResourceModel(
    linkId: map['link_id'] as String,
    type: ResourceType.fromInt(map['type'] as int),
    path: map['path'] as String,
    description: map['description'] as String?,
  );
}