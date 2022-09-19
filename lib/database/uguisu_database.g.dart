// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uguisu_database.dart';

// **************************************************************************
// DriftDatabaseGenerator
// **************************************************************************

// ignore_for_file: type=lint
class UguisuNicoliveUser extends DataClass
    implements Insertable<UguisuNicoliveUser> {
  final int id;
  final String serviceId;
  final int userId;
  final String nickname;
  final String iconUrl;
  final DateTime fetchedAt;
  const UguisuNicoliveUser(
      {required this.id,
      required this.serviceId,
      required this.userId,
      required this.nickname,
      required this.iconUrl,
      required this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['service_id'] = Variable<String>(serviceId);
    map['user_id'] = Variable<int>(userId);
    map['nickname'] = Variable<String>(nickname);
    map['icon_url'] = Variable<String>(iconUrl);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  UguisuNicoliveUsersCompanion toCompanion(bool nullToAbsent) {
    return UguisuNicoliveUsersCompanion(
      id: Value(id),
      serviceId: Value(serviceId),
      userId: Value(userId),
      nickname: Value(nickname),
      iconUrl: Value(iconUrl),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory UguisuNicoliveUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UguisuNicoliveUser(
      id: serializer.fromJson<int>(json['id']),
      serviceId: serializer.fromJson<String>(json['serviceId']),
      userId: serializer.fromJson<int>(json['userId']),
      nickname: serializer.fromJson<String>(json['nickname']),
      iconUrl: serializer.fromJson<String>(json['iconUrl']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serviceId': serializer.toJson<String>(serviceId),
      'userId': serializer.toJson<int>(userId),
      'nickname': serializer.toJson<String>(nickname),
      'iconUrl': serializer.toJson<String>(iconUrl),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  UguisuNicoliveUser copyWith(
          {int? id,
          String? serviceId,
          int? userId,
          String? nickname,
          String? iconUrl,
          DateTime? fetchedAt}) =>
      UguisuNicoliveUser(
        id: id ?? this.id,
        serviceId: serviceId ?? this.serviceId,
        userId: userId ?? this.userId,
        nickname: nickname ?? this.nickname,
        iconUrl: iconUrl ?? this.iconUrl,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  @override
  String toString() {
    return (StringBuffer('UguisuNicoliveUser(')
          ..write('id: $id, ')
          ..write('serviceId: $serviceId, ')
          ..write('userId: $userId, ')
          ..write('nickname: $nickname, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, serviceId, userId, nickname, iconUrl, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UguisuNicoliveUser &&
          other.id == this.id &&
          other.serviceId == this.serviceId &&
          other.userId == this.userId &&
          other.nickname == this.nickname &&
          other.iconUrl == this.iconUrl &&
          other.fetchedAt == this.fetchedAt);
}

class UguisuNicoliveUsersCompanion extends UpdateCompanion<UguisuNicoliveUser> {
  final Value<int> id;
  final Value<String> serviceId;
  final Value<int> userId;
  final Value<String> nickname;
  final Value<String> iconUrl;
  final Value<DateTime> fetchedAt;
  const UguisuNicoliveUsersCompanion({
    this.id = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.nickname = const Value.absent(),
    this.iconUrl = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  UguisuNicoliveUsersCompanion.insert({
    this.id = const Value.absent(),
    required String serviceId,
    required int userId,
    required String nickname,
    required String iconUrl,
    required DateTime fetchedAt,
  })  : serviceId = Value(serviceId),
        userId = Value(userId),
        nickname = Value(nickname),
        iconUrl = Value(iconUrl),
        fetchedAt = Value(fetchedAt);
  static Insertable<UguisuNicoliveUser> custom({
    Expression<int>? id,
    Expression<String>? serviceId,
    Expression<int>? userId,
    Expression<String>? nickname,
    Expression<String>? iconUrl,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceId != null) 'service_id': serviceId,
      if (userId != null) 'user_id': userId,
      if (nickname != null) 'nickname': nickname,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  UguisuNicoliveUsersCompanion copyWith(
      {Value<int>? id,
      Value<String>? serviceId,
      Value<int>? userId,
      Value<String>? nickname,
      Value<String>? iconUrl,
      Value<DateTime>? fetchedAt}) {
    return UguisuNicoliveUsersCompanion(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      iconUrl: iconUrl ?? this.iconUrl,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serviceId.present) {
      map['service_id'] = Variable<String>(serviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (iconUrl.present) {
      map['icon_url'] = Variable<String>(iconUrl.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UguisuNicoliveUsersCompanion(')
          ..write('id: $id, ')
          ..write('serviceId: $serviceId, ')
          ..write('userId: $userId, ')
          ..write('nickname: $nickname, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $UguisuNicoliveUsersTable extends UguisuNicoliveUsers
    with TableInfo<$UguisuNicoliveUsersTable, UguisuNicoliveUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UguisuNicoliveUsersTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _serviceIdMeta = const VerificationMeta('serviceId');
  @override
  late final GeneratedColumn<String> serviceId = GeneratedColumn<String>(
      'service_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  final VerificationMeta _nicknameMeta = const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _iconUrlMeta = const VerificationMeta('iconUrl');
  @override
  late final GeneratedColumn<String> iconUrl = GeneratedColumn<String>(
      'icon_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _fetchedAtMeta = const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, serviceId, userId, nickname, iconUrl, fetchedAt];
  @override
  String get aliasedName => _alias ?? 'uguisu_nicolive_users';
  @override
  String get actualTableName => 'uguisu_nicolive_users';
  @override
  VerificationContext validateIntegrity(Insertable<UguisuNicoliveUser> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('service_id')) {
      context.handle(_serviceIdMeta,
          serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta));
    } else if (isInserting) {
      context.missing(_serviceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('icon_url')) {
      context.handle(_iconUrlMeta,
          iconUrl.isAcceptableOrUnknown(data['icon_url']!, _iconUrlMeta));
    } else if (isInserting) {
      context.missing(_iconUrlMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {serviceId, userId},
      ];
  @override
  UguisuNicoliveUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UguisuNicoliveUser(
      id: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serviceId: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}service_id'])!,
      userId: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      nickname: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}nickname'])!,
      iconUrl: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}icon_url'])!,
      fetchedAt: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
    );
  }

  @override
  $UguisuNicoliveUsersTable createAlias(String alias) {
    return $UguisuNicoliveUsersTable(attachedDatabase, alias);
  }
}

class UguisuNicoliveUserIconCache extends DataClass
    implements Insertable<UguisuNicoliveUserIconCache> {
  final int id;
  final int user;
  final String contentType;
  final String path;
  final DateTime? uploadedAt;
  final DateTime fetchedAt;
  const UguisuNicoliveUserIconCache(
      {required this.id,
      required this.user,
      required this.contentType,
      required this.path,
      this.uploadedAt,
      required this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user'] = Variable<int>(user);
    map['content_type'] = Variable<String>(contentType);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || uploadedAt != null) {
      map['uploaded_at'] = Variable<DateTime>(uploadedAt);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  UguisuNicoliveUserIconCachesCompanion toCompanion(bool nullToAbsent) {
    return UguisuNicoliveUserIconCachesCompanion(
      id: Value(id),
      user: Value(user),
      contentType: Value(contentType),
      path: Value(path),
      uploadedAt: uploadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(uploadedAt),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory UguisuNicoliveUserIconCache.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UguisuNicoliveUserIconCache(
      id: serializer.fromJson<int>(json['id']),
      user: serializer.fromJson<int>(json['user']),
      contentType: serializer.fromJson<String>(json['contentType']),
      path: serializer.fromJson<String>(json['path']),
      uploadedAt: serializer.fromJson<DateTime?>(json['uploadedAt']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'user': serializer.toJson<int>(user),
      'contentType': serializer.toJson<String>(contentType),
      'path': serializer.toJson<String>(path),
      'uploadedAt': serializer.toJson<DateTime?>(uploadedAt),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  UguisuNicoliveUserIconCache copyWith(
          {int? id,
          int? user,
          String? contentType,
          String? path,
          Value<DateTime?> uploadedAt = const Value.absent(),
          DateTime? fetchedAt}) =>
      UguisuNicoliveUserIconCache(
        id: id ?? this.id,
        user: user ?? this.user,
        contentType: contentType ?? this.contentType,
        path: path ?? this.path,
        uploadedAt: uploadedAt.present ? uploadedAt.value : this.uploadedAt,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  @override
  String toString() {
    return (StringBuffer('UguisuNicoliveUserIconCache(')
          ..write('id: $id, ')
          ..write('user: $user, ')
          ..write('contentType: $contentType, ')
          ..write('path: $path, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, user, contentType, path, uploadedAt, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UguisuNicoliveUserIconCache &&
          other.id == this.id &&
          other.user == this.user &&
          other.contentType == this.contentType &&
          other.path == this.path &&
          other.uploadedAt == this.uploadedAt &&
          other.fetchedAt == this.fetchedAt);
}

class UguisuNicoliveUserIconCachesCompanion
    extends UpdateCompanion<UguisuNicoliveUserIconCache> {
  final Value<int> id;
  final Value<int> user;
  final Value<String> contentType;
  final Value<String> path;
  final Value<DateTime?> uploadedAt;
  final Value<DateTime> fetchedAt;
  const UguisuNicoliveUserIconCachesCompanion({
    this.id = const Value.absent(),
    this.user = const Value.absent(),
    this.contentType = const Value.absent(),
    this.path = const Value.absent(),
    this.uploadedAt = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  UguisuNicoliveUserIconCachesCompanion.insert({
    this.id = const Value.absent(),
    required int user,
    required String contentType,
    required String path,
    this.uploadedAt = const Value.absent(),
    required DateTime fetchedAt,
  })  : user = Value(user),
        contentType = Value(contentType),
        path = Value(path),
        fetchedAt = Value(fetchedAt);
  static Insertable<UguisuNicoliveUserIconCache> custom({
    Expression<int>? id,
    Expression<int>? user,
    Expression<String>? contentType,
    Expression<String>? path,
    Expression<DateTime>? uploadedAt,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (user != null) 'user': user,
      if (contentType != null) 'content_type': contentType,
      if (path != null) 'path': path,
      if (uploadedAt != null) 'uploaded_at': uploadedAt,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  UguisuNicoliveUserIconCachesCompanion copyWith(
      {Value<int>? id,
      Value<int>? user,
      Value<String>? contentType,
      Value<String>? path,
      Value<DateTime?>? uploadedAt,
      Value<DateTime>? fetchedAt}) {
    return UguisuNicoliveUserIconCachesCompanion(
      id: id ?? this.id,
      user: user ?? this.user,
      contentType: contentType ?? this.contentType,
      path: path ?? this.path,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (user.present) {
      map['user'] = Variable<int>(user.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (uploadedAt.present) {
      map['uploaded_at'] = Variable<DateTime>(uploadedAt.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UguisuNicoliveUserIconCachesCompanion(')
          ..write('id: $id, ')
          ..write('user: $user, ')
          ..write('contentType: $contentType, ')
          ..write('path: $path, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $UguisuNicoliveUserIconCachesTable extends UguisuNicoliveUserIconCaches
    with
        TableInfo<$UguisuNicoliveUserIconCachesTable,
            UguisuNicoliveUserIconCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UguisuNicoliveUserIconCachesTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _userMeta = const VerificationMeta('user');
  @override
  late final GeneratedColumn<int> user = GeneratedColumn<int>(
      'user', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: 'REFERENCES uguisu_nicolive_users (id)');
  final VerificationMeta _contentTypeMeta =
      const VerificationMeta('contentType');
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
      'content_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _uploadedAtMeta = const VerificationMeta('uploadedAt');
  @override
  late final GeneratedColumn<DateTime> uploadedAt = GeneratedColumn<DateTime>(
      'uploaded_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  final VerificationMeta _fetchedAtMeta = const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, user, contentType, path, uploadedAt, fetchedAt];
  @override
  String get aliasedName => _alias ?? 'uguisu_nicolive_user_icon_caches';
  @override
  String get actualTableName => 'uguisu_nicolive_user_icon_caches';
  @override
  VerificationContext validateIntegrity(
      Insertable<UguisuNicoliveUserIconCache> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user')) {
      context.handle(
          _userMeta, user.isAcceptableOrUnknown(data['user']!, _userMeta));
    } else if (isInserting) {
      context.missing(_userMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
          _contentTypeMeta,
          contentType.isAcceptableOrUnknown(
              data['content_type']!, _contentTypeMeta));
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('uploaded_at')) {
      context.handle(
          _uploadedAtMeta,
          uploadedAt.isAcceptableOrUnknown(
              data['uploaded_at']!, _uploadedAtMeta));
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {user},
      ];
  @override
  UguisuNicoliveUserIconCache map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UguisuNicoliveUserIconCache(
      id: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      user: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}user'])!,
      contentType: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}content_type'])!,
      path: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      uploadedAt: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}uploaded_at']),
      fetchedAt: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
    );
  }

  @override
  $UguisuNicoliveUserIconCachesTable createAlias(String alias) {
    return $UguisuNicoliveUserIconCachesTable(attachedDatabase, alias);
  }
}

class UguisuNicoliveCommunitie extends DataClass
    implements Insertable<UguisuNicoliveCommunitie> {
  final int id;
  final String serviceId;
  final String communityId;
  final String name;
  final String iconUrl;
  final DateTime fetchedAt;
  const UguisuNicoliveCommunitie(
      {required this.id,
      required this.serviceId,
      required this.communityId,
      required this.name,
      required this.iconUrl,
      required this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['service_id'] = Variable<String>(serviceId);
    map['community_id'] = Variable<String>(communityId);
    map['name'] = Variable<String>(name);
    map['icon_url'] = Variable<String>(iconUrl);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  UguisuNicoliveCommunitiesCompanion toCompanion(bool nullToAbsent) {
    return UguisuNicoliveCommunitiesCompanion(
      id: Value(id),
      serviceId: Value(serviceId),
      communityId: Value(communityId),
      name: Value(name),
      iconUrl: Value(iconUrl),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory UguisuNicoliveCommunitie.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UguisuNicoliveCommunitie(
      id: serializer.fromJson<int>(json['id']),
      serviceId: serializer.fromJson<String>(json['serviceId']),
      communityId: serializer.fromJson<String>(json['communityId']),
      name: serializer.fromJson<String>(json['name']),
      iconUrl: serializer.fromJson<String>(json['iconUrl']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serviceId': serializer.toJson<String>(serviceId),
      'communityId': serializer.toJson<String>(communityId),
      'name': serializer.toJson<String>(name),
      'iconUrl': serializer.toJson<String>(iconUrl),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  UguisuNicoliveCommunitie copyWith(
          {int? id,
          String? serviceId,
          String? communityId,
          String? name,
          String? iconUrl,
          DateTime? fetchedAt}) =>
      UguisuNicoliveCommunitie(
        id: id ?? this.id,
        serviceId: serviceId ?? this.serviceId,
        communityId: communityId ?? this.communityId,
        name: name ?? this.name,
        iconUrl: iconUrl ?? this.iconUrl,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  @override
  String toString() {
    return (StringBuffer('UguisuNicoliveCommunitie(')
          ..write('id: $id, ')
          ..write('serviceId: $serviceId, ')
          ..write('communityId: $communityId, ')
          ..write('name: $name, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, serviceId, communityId, name, iconUrl, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UguisuNicoliveCommunitie &&
          other.id == this.id &&
          other.serviceId == this.serviceId &&
          other.communityId == this.communityId &&
          other.name == this.name &&
          other.iconUrl == this.iconUrl &&
          other.fetchedAt == this.fetchedAt);
}

class UguisuNicoliveCommunitiesCompanion
    extends UpdateCompanion<UguisuNicoliveCommunitie> {
  final Value<int> id;
  final Value<String> serviceId;
  final Value<String> communityId;
  final Value<String> name;
  final Value<String> iconUrl;
  final Value<DateTime> fetchedAt;
  const UguisuNicoliveCommunitiesCompanion({
    this.id = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.communityId = const Value.absent(),
    this.name = const Value.absent(),
    this.iconUrl = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  UguisuNicoliveCommunitiesCompanion.insert({
    this.id = const Value.absent(),
    required String serviceId,
    required String communityId,
    required String name,
    required String iconUrl,
    required DateTime fetchedAt,
  })  : serviceId = Value(serviceId),
        communityId = Value(communityId),
        name = Value(name),
        iconUrl = Value(iconUrl),
        fetchedAt = Value(fetchedAt);
  static Insertable<UguisuNicoliveCommunitie> custom({
    Expression<int>? id,
    Expression<String>? serviceId,
    Expression<String>? communityId,
    Expression<String>? name,
    Expression<String>? iconUrl,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceId != null) 'service_id': serviceId,
      if (communityId != null) 'community_id': communityId,
      if (name != null) 'name': name,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  UguisuNicoliveCommunitiesCompanion copyWith(
      {Value<int>? id,
      Value<String>? serviceId,
      Value<String>? communityId,
      Value<String>? name,
      Value<String>? iconUrl,
      Value<DateTime>? fetchedAt}) {
    return UguisuNicoliveCommunitiesCompanion(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      communityId: communityId ?? this.communityId,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serviceId.present) {
      map['service_id'] = Variable<String>(serviceId.value);
    }
    if (communityId.present) {
      map['community_id'] = Variable<String>(communityId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconUrl.present) {
      map['icon_url'] = Variable<String>(iconUrl.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UguisuNicoliveCommunitiesCompanion(')
          ..write('id: $id, ')
          ..write('serviceId: $serviceId, ')
          ..write('communityId: $communityId, ')
          ..write('name: $name, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $UguisuNicoliveCommunitiesTable extends UguisuNicoliveCommunities
    with TableInfo<$UguisuNicoliveCommunitiesTable, UguisuNicoliveCommunitie> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UguisuNicoliveCommunitiesTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _serviceIdMeta = const VerificationMeta('serviceId');
  @override
  late final GeneratedColumn<String> serviceId = GeneratedColumn<String>(
      'service_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _communityIdMeta =
      const VerificationMeta('communityId');
  @override
  late final GeneratedColumn<String> communityId = GeneratedColumn<String>(
      'community_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _iconUrlMeta = const VerificationMeta('iconUrl');
  @override
  late final GeneratedColumn<String> iconUrl = GeneratedColumn<String>(
      'icon_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _fetchedAtMeta = const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, serviceId, communityId, name, iconUrl, fetchedAt];
  @override
  String get aliasedName => _alias ?? 'uguisu_nicolive_communities';
  @override
  String get actualTableName => 'uguisu_nicolive_communities';
  @override
  VerificationContext validateIntegrity(
      Insertable<UguisuNicoliveCommunitie> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('service_id')) {
      context.handle(_serviceIdMeta,
          serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta));
    } else if (isInserting) {
      context.missing(_serviceIdMeta);
    }
    if (data.containsKey('community_id')) {
      context.handle(
          _communityIdMeta,
          communityId.isAcceptableOrUnknown(
              data['community_id']!, _communityIdMeta));
    } else if (isInserting) {
      context.missing(_communityIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_url')) {
      context.handle(_iconUrlMeta,
          iconUrl.isAcceptableOrUnknown(data['icon_url']!, _iconUrlMeta));
    } else if (isInserting) {
      context.missing(_iconUrlMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {serviceId, communityId},
      ];
  @override
  UguisuNicoliveCommunitie map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UguisuNicoliveCommunitie(
      id: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serviceId: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}service_id'])!,
      communityId: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}community_id'])!,
      name: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      iconUrl: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}icon_url'])!,
      fetchedAt: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
    );
  }

  @override
  $UguisuNicoliveCommunitiesTable createAlias(String alias) {
    return $UguisuNicoliveCommunitiesTable(attachedDatabase, alias);
  }
}

class UguisuNicoliveCommunityIconCache extends DataClass
    implements Insertable<UguisuNicoliveCommunityIconCache> {
  final int id;
  final int community;
  final String contentType;
  final String path;
  final DateTime? uploadedAt;
  final DateTime fetchedAt;
  const UguisuNicoliveCommunityIconCache(
      {required this.id,
      required this.community,
      required this.contentType,
      required this.path,
      this.uploadedAt,
      required this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['community'] = Variable<int>(community);
    map['content_type'] = Variable<String>(contentType);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || uploadedAt != null) {
      map['uploaded_at'] = Variable<DateTime>(uploadedAt);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  UguisuNicoliveCommunityIconCachesCompanion toCompanion(bool nullToAbsent) {
    return UguisuNicoliveCommunityIconCachesCompanion(
      id: Value(id),
      community: Value(community),
      contentType: Value(contentType),
      path: Value(path),
      uploadedAt: uploadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(uploadedAt),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory UguisuNicoliveCommunityIconCache.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UguisuNicoliveCommunityIconCache(
      id: serializer.fromJson<int>(json['id']),
      community: serializer.fromJson<int>(json['community']),
      contentType: serializer.fromJson<String>(json['contentType']),
      path: serializer.fromJson<String>(json['path']),
      uploadedAt: serializer.fromJson<DateTime?>(json['uploadedAt']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'community': serializer.toJson<int>(community),
      'contentType': serializer.toJson<String>(contentType),
      'path': serializer.toJson<String>(path),
      'uploadedAt': serializer.toJson<DateTime?>(uploadedAt),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  UguisuNicoliveCommunityIconCache copyWith(
          {int? id,
          int? community,
          String? contentType,
          String? path,
          Value<DateTime?> uploadedAt = const Value.absent(),
          DateTime? fetchedAt}) =>
      UguisuNicoliveCommunityIconCache(
        id: id ?? this.id,
        community: community ?? this.community,
        contentType: contentType ?? this.contentType,
        path: path ?? this.path,
        uploadedAt: uploadedAt.present ? uploadedAt.value : this.uploadedAt,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  @override
  String toString() {
    return (StringBuffer('UguisuNicoliveCommunityIconCache(')
          ..write('id: $id, ')
          ..write('community: $community, ')
          ..write('contentType: $contentType, ')
          ..write('path: $path, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, community, contentType, path, uploadedAt, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UguisuNicoliveCommunityIconCache &&
          other.id == this.id &&
          other.community == this.community &&
          other.contentType == this.contentType &&
          other.path == this.path &&
          other.uploadedAt == this.uploadedAt &&
          other.fetchedAt == this.fetchedAt);
}

class UguisuNicoliveCommunityIconCachesCompanion
    extends UpdateCompanion<UguisuNicoliveCommunityIconCache> {
  final Value<int> id;
  final Value<int> community;
  final Value<String> contentType;
  final Value<String> path;
  final Value<DateTime?> uploadedAt;
  final Value<DateTime> fetchedAt;
  const UguisuNicoliveCommunityIconCachesCompanion({
    this.id = const Value.absent(),
    this.community = const Value.absent(),
    this.contentType = const Value.absent(),
    this.path = const Value.absent(),
    this.uploadedAt = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  UguisuNicoliveCommunityIconCachesCompanion.insert({
    this.id = const Value.absent(),
    required int community,
    required String contentType,
    required String path,
    this.uploadedAt = const Value.absent(),
    required DateTime fetchedAt,
  })  : community = Value(community),
        contentType = Value(contentType),
        path = Value(path),
        fetchedAt = Value(fetchedAt);
  static Insertable<UguisuNicoliveCommunityIconCache> custom({
    Expression<int>? id,
    Expression<int>? community,
    Expression<String>? contentType,
    Expression<String>? path,
    Expression<DateTime>? uploadedAt,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (community != null) 'community': community,
      if (contentType != null) 'content_type': contentType,
      if (path != null) 'path': path,
      if (uploadedAt != null) 'uploaded_at': uploadedAt,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  UguisuNicoliveCommunityIconCachesCompanion copyWith(
      {Value<int>? id,
      Value<int>? community,
      Value<String>? contentType,
      Value<String>? path,
      Value<DateTime?>? uploadedAt,
      Value<DateTime>? fetchedAt}) {
    return UguisuNicoliveCommunityIconCachesCompanion(
      id: id ?? this.id,
      community: community ?? this.community,
      contentType: contentType ?? this.contentType,
      path: path ?? this.path,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (community.present) {
      map['community'] = Variable<int>(community.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (uploadedAt.present) {
      map['uploaded_at'] = Variable<DateTime>(uploadedAt.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UguisuNicoliveCommunityIconCachesCompanion(')
          ..write('id: $id, ')
          ..write('community: $community, ')
          ..write('contentType: $contentType, ')
          ..write('path: $path, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $UguisuNicoliveCommunityIconCachesTable
    extends UguisuNicoliveCommunityIconCaches
    with
        TableInfo<$UguisuNicoliveCommunityIconCachesTable,
            UguisuNicoliveCommunityIconCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UguisuNicoliveCommunityIconCachesTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _communityMeta = const VerificationMeta('community');
  @override
  late final GeneratedColumn<int> community = GeneratedColumn<int>(
      'community', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: 'REFERENCES uguisu_nicolive_communities (id)');
  final VerificationMeta _contentTypeMeta =
      const VerificationMeta('contentType');
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
      'content_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _uploadedAtMeta = const VerificationMeta('uploadedAt');
  @override
  late final GeneratedColumn<DateTime> uploadedAt = GeneratedColumn<DateTime>(
      'uploaded_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  final VerificationMeta _fetchedAtMeta = const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, community, contentType, path, uploadedAt, fetchedAt];
  @override
  String get aliasedName => _alias ?? 'uguisu_nicolive_community_icon_caches';
  @override
  String get actualTableName => 'uguisu_nicolive_community_icon_caches';
  @override
  VerificationContext validateIntegrity(
      Insertable<UguisuNicoliveCommunityIconCache> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('community')) {
      context.handle(_communityMeta,
          community.isAcceptableOrUnknown(data['community']!, _communityMeta));
    } else if (isInserting) {
      context.missing(_communityMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
          _contentTypeMeta,
          contentType.isAcceptableOrUnknown(
              data['content_type']!, _contentTypeMeta));
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('uploaded_at')) {
      context.handle(
          _uploadedAtMeta,
          uploadedAt.isAcceptableOrUnknown(
              data['uploaded_at']!, _uploadedAtMeta));
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {community},
      ];
  @override
  UguisuNicoliveCommunityIconCache map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UguisuNicoliveCommunityIconCache(
      id: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      community: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}community'])!,
      contentType: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}content_type'])!,
      path: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      uploadedAt: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}uploaded_at']),
      fetchedAt: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
    );
  }

  @override
  $UguisuNicoliveCommunityIconCachesTable createAlias(String alias) {
    return $UguisuNicoliveCommunityIconCachesTable(attachedDatabase, alias);
  }
}

class UguisuNicoliveProgram extends DataClass
    implements Insertable<UguisuNicoliveProgram> {
  final int id;
  final String serviceId;
  final String programId;
  final String title;
  final String providerType;
  final String visualProviderType;
  final DateTime beginTime;
  final DateTime endTime;
  final int user;
  final int community;
  final String webSocketUrl;
  final DateTime fetchedAt;
  const UguisuNicoliveProgram(
      {required this.id,
      required this.serviceId,
      required this.programId,
      required this.title,
      required this.providerType,
      required this.visualProviderType,
      required this.beginTime,
      required this.endTime,
      required this.user,
      required this.community,
      required this.webSocketUrl,
      required this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['service_id'] = Variable<String>(serviceId);
    map['program_id'] = Variable<String>(programId);
    map['title'] = Variable<String>(title);
    map['provider_type'] = Variable<String>(providerType);
    map['visual_provider_type'] = Variable<String>(visualProviderType);
    map['begin_time'] = Variable<DateTime>(beginTime);
    map['end_time'] = Variable<DateTime>(endTime);
    map['user'] = Variable<int>(user);
    map['community'] = Variable<int>(community);
    map['web_socket_url'] = Variable<String>(webSocketUrl);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  UguisuNicoliveProgramsCompanion toCompanion(bool nullToAbsent) {
    return UguisuNicoliveProgramsCompanion(
      id: Value(id),
      serviceId: Value(serviceId),
      programId: Value(programId),
      title: Value(title),
      providerType: Value(providerType),
      visualProviderType: Value(visualProviderType),
      beginTime: Value(beginTime),
      endTime: Value(endTime),
      user: Value(user),
      community: Value(community),
      webSocketUrl: Value(webSocketUrl),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory UguisuNicoliveProgram.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UguisuNicoliveProgram(
      id: serializer.fromJson<int>(json['id']),
      serviceId: serializer.fromJson<String>(json['serviceId']),
      programId: serializer.fromJson<String>(json['programId']),
      title: serializer.fromJson<String>(json['title']),
      providerType: serializer.fromJson<String>(json['providerType']),
      visualProviderType:
          serializer.fromJson<String>(json['visualProviderType']),
      beginTime: serializer.fromJson<DateTime>(json['beginTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      user: serializer.fromJson<int>(json['user']),
      community: serializer.fromJson<int>(json['community']),
      webSocketUrl: serializer.fromJson<String>(json['webSocketUrl']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serviceId': serializer.toJson<String>(serviceId),
      'programId': serializer.toJson<String>(programId),
      'title': serializer.toJson<String>(title),
      'providerType': serializer.toJson<String>(providerType),
      'visualProviderType': serializer.toJson<String>(visualProviderType),
      'beginTime': serializer.toJson<DateTime>(beginTime),
      'endTime': serializer.toJson<DateTime>(endTime),
      'user': serializer.toJson<int>(user),
      'community': serializer.toJson<int>(community),
      'webSocketUrl': serializer.toJson<String>(webSocketUrl),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  UguisuNicoliveProgram copyWith(
          {int? id,
          String? serviceId,
          String? programId,
          String? title,
          String? providerType,
          String? visualProviderType,
          DateTime? beginTime,
          DateTime? endTime,
          int? user,
          int? community,
          String? webSocketUrl,
          DateTime? fetchedAt}) =>
      UguisuNicoliveProgram(
        id: id ?? this.id,
        serviceId: serviceId ?? this.serviceId,
        programId: programId ?? this.programId,
        title: title ?? this.title,
        providerType: providerType ?? this.providerType,
        visualProviderType: visualProviderType ?? this.visualProviderType,
        beginTime: beginTime ?? this.beginTime,
        endTime: endTime ?? this.endTime,
        user: user ?? this.user,
        community: community ?? this.community,
        webSocketUrl: webSocketUrl ?? this.webSocketUrl,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  @override
  String toString() {
    return (StringBuffer('UguisuNicoliveProgram(')
          ..write('id: $id, ')
          ..write('serviceId: $serviceId, ')
          ..write('programId: $programId, ')
          ..write('title: $title, ')
          ..write('providerType: $providerType, ')
          ..write('visualProviderType: $visualProviderType, ')
          ..write('beginTime: $beginTime, ')
          ..write('endTime: $endTime, ')
          ..write('user: $user, ')
          ..write('community: $community, ')
          ..write('webSocketUrl: $webSocketUrl, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serviceId,
      programId,
      title,
      providerType,
      visualProviderType,
      beginTime,
      endTime,
      user,
      community,
      webSocketUrl,
      fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UguisuNicoliveProgram &&
          other.id == this.id &&
          other.serviceId == this.serviceId &&
          other.programId == this.programId &&
          other.title == this.title &&
          other.providerType == this.providerType &&
          other.visualProviderType == this.visualProviderType &&
          other.beginTime == this.beginTime &&
          other.endTime == this.endTime &&
          other.user == this.user &&
          other.community == this.community &&
          other.webSocketUrl == this.webSocketUrl &&
          other.fetchedAt == this.fetchedAt);
}

class UguisuNicoliveProgramsCompanion
    extends UpdateCompanion<UguisuNicoliveProgram> {
  final Value<int> id;
  final Value<String> serviceId;
  final Value<String> programId;
  final Value<String> title;
  final Value<String> providerType;
  final Value<String> visualProviderType;
  final Value<DateTime> beginTime;
  final Value<DateTime> endTime;
  final Value<int> user;
  final Value<int> community;
  final Value<String> webSocketUrl;
  final Value<DateTime> fetchedAt;
  const UguisuNicoliveProgramsCompanion({
    this.id = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.programId = const Value.absent(),
    this.title = const Value.absent(),
    this.providerType = const Value.absent(),
    this.visualProviderType = const Value.absent(),
    this.beginTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.user = const Value.absent(),
    this.community = const Value.absent(),
    this.webSocketUrl = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  UguisuNicoliveProgramsCompanion.insert({
    this.id = const Value.absent(),
    required String serviceId,
    required String programId,
    required String title,
    required String providerType,
    required String visualProviderType,
    required DateTime beginTime,
    required DateTime endTime,
    required int user,
    required int community,
    required String webSocketUrl,
    required DateTime fetchedAt,
  })  : serviceId = Value(serviceId),
        programId = Value(programId),
        title = Value(title),
        providerType = Value(providerType),
        visualProviderType = Value(visualProviderType),
        beginTime = Value(beginTime),
        endTime = Value(endTime),
        user = Value(user),
        community = Value(community),
        webSocketUrl = Value(webSocketUrl),
        fetchedAt = Value(fetchedAt);
  static Insertable<UguisuNicoliveProgram> custom({
    Expression<int>? id,
    Expression<String>? serviceId,
    Expression<String>? programId,
    Expression<String>? title,
    Expression<String>? providerType,
    Expression<String>? visualProviderType,
    Expression<DateTime>? beginTime,
    Expression<DateTime>? endTime,
    Expression<int>? user,
    Expression<int>? community,
    Expression<String>? webSocketUrl,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceId != null) 'service_id': serviceId,
      if (programId != null) 'program_id': programId,
      if (title != null) 'title': title,
      if (providerType != null) 'provider_type': providerType,
      if (visualProviderType != null)
        'visual_provider_type': visualProviderType,
      if (beginTime != null) 'begin_time': beginTime,
      if (endTime != null) 'end_time': endTime,
      if (user != null) 'user': user,
      if (community != null) 'community': community,
      if (webSocketUrl != null) 'web_socket_url': webSocketUrl,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  UguisuNicoliveProgramsCompanion copyWith(
      {Value<int>? id,
      Value<String>? serviceId,
      Value<String>? programId,
      Value<String>? title,
      Value<String>? providerType,
      Value<String>? visualProviderType,
      Value<DateTime>? beginTime,
      Value<DateTime>? endTime,
      Value<int>? user,
      Value<int>? community,
      Value<String>? webSocketUrl,
      Value<DateTime>? fetchedAt}) {
    return UguisuNicoliveProgramsCompanion(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      programId: programId ?? this.programId,
      title: title ?? this.title,
      providerType: providerType ?? this.providerType,
      visualProviderType: visualProviderType ?? this.visualProviderType,
      beginTime: beginTime ?? this.beginTime,
      endTime: endTime ?? this.endTime,
      user: user ?? this.user,
      community: community ?? this.community,
      webSocketUrl: webSocketUrl ?? this.webSocketUrl,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serviceId.present) {
      map['service_id'] = Variable<String>(serviceId.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<String>(programId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (providerType.present) {
      map['provider_type'] = Variable<String>(providerType.value);
    }
    if (visualProviderType.present) {
      map['visual_provider_type'] = Variable<String>(visualProviderType.value);
    }
    if (beginTime.present) {
      map['begin_time'] = Variable<DateTime>(beginTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (user.present) {
      map['user'] = Variable<int>(user.value);
    }
    if (community.present) {
      map['community'] = Variable<int>(community.value);
    }
    if (webSocketUrl.present) {
      map['web_socket_url'] = Variable<String>(webSocketUrl.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UguisuNicoliveProgramsCompanion(')
          ..write('id: $id, ')
          ..write('serviceId: $serviceId, ')
          ..write('programId: $programId, ')
          ..write('title: $title, ')
          ..write('providerType: $providerType, ')
          ..write('visualProviderType: $visualProviderType, ')
          ..write('beginTime: $beginTime, ')
          ..write('endTime: $endTime, ')
          ..write('user: $user, ')
          ..write('community: $community, ')
          ..write('webSocketUrl: $webSocketUrl, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $UguisuNicoliveProgramsTable extends UguisuNicolivePrograms
    with TableInfo<$UguisuNicoliveProgramsTable, UguisuNicoliveProgram> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UguisuNicoliveProgramsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _serviceIdMeta = const VerificationMeta('serviceId');
  @override
  late final GeneratedColumn<String> serviceId = GeneratedColumn<String>(
      'service_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _programIdMeta = const VerificationMeta('programId');
  @override
  late final GeneratedColumn<String> programId = GeneratedColumn<String>(
      'program_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _providerTypeMeta =
      const VerificationMeta('providerType');
  @override
  late final GeneratedColumn<String> providerType = GeneratedColumn<String>(
      'provider_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _visualProviderTypeMeta =
      const VerificationMeta('visualProviderType');
  @override
  late final GeneratedColumn<String> visualProviderType =
      GeneratedColumn<String>('visual_provider_type', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _beginTimeMeta = const VerificationMeta('beginTime');
  @override
  late final GeneratedColumn<DateTime> beginTime = GeneratedColumn<DateTime>(
      'begin_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  final VerificationMeta _endTimeMeta = const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  final VerificationMeta _userMeta = const VerificationMeta('user');
  @override
  late final GeneratedColumn<int> user = GeneratedColumn<int>(
      'user', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: 'REFERENCES uguisu_nicolive_users (id)');
  final VerificationMeta _communityMeta = const VerificationMeta('community');
  @override
  late final GeneratedColumn<int> community = GeneratedColumn<int>(
      'community', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: 'REFERENCES uguisu_nicolive_communities (id)');
  final VerificationMeta _webSocketUrlMeta =
      const VerificationMeta('webSocketUrl');
  @override
  late final GeneratedColumn<String> webSocketUrl = GeneratedColumn<String>(
      'web_socket_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _fetchedAtMeta = const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serviceId,
        programId,
        title,
        providerType,
        visualProviderType,
        beginTime,
        endTime,
        user,
        community,
        webSocketUrl,
        fetchedAt
      ];
  @override
  String get aliasedName => _alias ?? 'uguisu_nicolive_programs';
  @override
  String get actualTableName => 'uguisu_nicolive_programs';
  @override
  VerificationContext validateIntegrity(
      Insertable<UguisuNicoliveProgram> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('service_id')) {
      context.handle(_serviceIdMeta,
          serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta));
    } else if (isInserting) {
      context.missing(_serviceIdMeta);
    }
    if (data.containsKey('program_id')) {
      context.handle(_programIdMeta,
          programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta));
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('provider_type')) {
      context.handle(
          _providerTypeMeta,
          providerType.isAcceptableOrUnknown(
              data['provider_type']!, _providerTypeMeta));
    } else if (isInserting) {
      context.missing(_providerTypeMeta);
    }
    if (data.containsKey('visual_provider_type')) {
      context.handle(
          _visualProviderTypeMeta,
          visualProviderType.isAcceptableOrUnknown(
              data['visual_provider_type']!, _visualProviderTypeMeta));
    } else if (isInserting) {
      context.missing(_visualProviderTypeMeta);
    }
    if (data.containsKey('begin_time')) {
      context.handle(_beginTimeMeta,
          beginTime.isAcceptableOrUnknown(data['begin_time']!, _beginTimeMeta));
    } else if (isInserting) {
      context.missing(_beginTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('user')) {
      context.handle(
          _userMeta, user.isAcceptableOrUnknown(data['user']!, _userMeta));
    } else if (isInserting) {
      context.missing(_userMeta);
    }
    if (data.containsKey('community')) {
      context.handle(_communityMeta,
          community.isAcceptableOrUnknown(data['community']!, _communityMeta));
    } else if (isInserting) {
      context.missing(_communityMeta);
    }
    if (data.containsKey('web_socket_url')) {
      context.handle(
          _webSocketUrlMeta,
          webSocketUrl.isAcceptableOrUnknown(
              data['web_socket_url']!, _webSocketUrlMeta));
    } else if (isInserting) {
      context.missing(_webSocketUrlMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {serviceId, programId},
      ];
  @override
  UguisuNicoliveProgram map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UguisuNicoliveProgram(
      id: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serviceId: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}service_id'])!,
      programId: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}program_id'])!,
      title: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      providerType: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}provider_type'])!,
      visualProviderType: attachedDatabase.options.types.read(
          DriftSqlType.string, data['${effectivePrefix}visual_provider_type'])!,
      beginTime: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}begin_time'])!,
      endTime: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time'])!,
      user: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}user'])!,
      community: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}community'])!,
      webSocketUrl: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}web_socket_url'])!,
      fetchedAt: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
    );
  }

  @override
  $UguisuNicoliveProgramsTable createAlias(String alias) {
    return $UguisuNicoliveProgramsTable(attachedDatabase, alias);
  }
}

abstract class _$UguisuDatabase extends GeneratedDatabase {
  _$UguisuDatabase(QueryExecutor e) : super(e);
  late final $UguisuNicoliveUsersTable uguisuNicoliveUsers =
      $UguisuNicoliveUsersTable(this);
  late final $UguisuNicoliveUserIconCachesTable uguisuNicoliveUserIconCaches =
      $UguisuNicoliveUserIconCachesTable(this);
  late final $UguisuNicoliveCommunitiesTable uguisuNicoliveCommunities =
      $UguisuNicoliveCommunitiesTable(this);
  late final $UguisuNicoliveCommunityIconCachesTable
      uguisuNicoliveCommunityIconCaches =
      $UguisuNicoliveCommunityIconCachesTable(this);
  late final $UguisuNicoliveProgramsTable uguisuNicolivePrograms =
      $UguisuNicoliveProgramsTable(this);
  @override
  Iterable<TableInfo<Table, dynamic>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        uguisuNicoliveUsers,
        uguisuNicoliveUserIconCaches,
        uguisuNicoliveCommunities,
        uguisuNicoliveCommunityIconCaches,
        uguisuNicolivePrograms
      ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}
