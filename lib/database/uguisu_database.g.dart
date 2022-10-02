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
  final String userId;
  final bool anonymity;
  final String? nickname;
  final String? iconUrl;
  final DateTime fetchedAt;
  const UguisuNicoliveUser(
      {required this.id,
      required this.serviceId,
      required this.userId,
      required this.anonymity,
      this.nickname,
      this.iconUrl,
      required this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['service_id'] = Variable<String>(serviceId);
    map['user_id'] = Variable<String>(userId);
    map['anonymity'] = Variable<bool>(anonymity);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    if (!nullToAbsent || iconUrl != null) {
      map['icon_url'] = Variable<String>(iconUrl);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  UguisuNicoliveUsersCompanion toCompanion(bool nullToAbsent) {
    return UguisuNicoliveUsersCompanion(
      id: Value(id),
      serviceId: Value(serviceId),
      userId: Value(userId),
      anonymity: Value(anonymity),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      iconUrl: iconUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(iconUrl),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory UguisuNicoliveUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UguisuNicoliveUser(
      id: serializer.fromJson<int>(json['id']),
      serviceId: serializer.fromJson<String>(json['serviceId']),
      userId: serializer.fromJson<String>(json['userId']),
      anonymity: serializer.fromJson<bool>(json['anonymity']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      iconUrl: serializer.fromJson<String?>(json['iconUrl']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serviceId': serializer.toJson<String>(serviceId),
      'userId': serializer.toJson<String>(userId),
      'anonymity': serializer.toJson<bool>(anonymity),
      'nickname': serializer.toJson<String?>(nickname),
      'iconUrl': serializer.toJson<String?>(iconUrl),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  UguisuNicoliveUser copyWith(
          {int? id,
          String? serviceId,
          String? userId,
          bool? anonymity,
          Value<String?> nickname = const Value.absent(),
          Value<String?> iconUrl = const Value.absent(),
          DateTime? fetchedAt}) =>
      UguisuNicoliveUser(
        id: id ?? this.id,
        serviceId: serviceId ?? this.serviceId,
        userId: userId ?? this.userId,
        anonymity: anonymity ?? this.anonymity,
        nickname: nickname.present ? nickname.value : this.nickname,
        iconUrl: iconUrl.present ? iconUrl.value : this.iconUrl,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  @override
  String toString() {
    return (StringBuffer('UguisuNicoliveUser(')
          ..write('id: $id, ')
          ..write('serviceId: $serviceId, ')
          ..write('userId: $userId, ')
          ..write('anonymity: $anonymity, ')
          ..write('nickname: $nickname, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, serviceId, userId, anonymity, nickname, iconUrl, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UguisuNicoliveUser &&
          other.id == this.id &&
          other.serviceId == this.serviceId &&
          other.userId == this.userId &&
          other.anonymity == this.anonymity &&
          other.nickname == this.nickname &&
          other.iconUrl == this.iconUrl &&
          other.fetchedAt == this.fetchedAt);
}

class UguisuNicoliveUsersCompanion extends UpdateCompanion<UguisuNicoliveUser> {
  final Value<int> id;
  final Value<String> serviceId;
  final Value<String> userId;
  final Value<bool> anonymity;
  final Value<String?> nickname;
  final Value<String?> iconUrl;
  final Value<DateTime> fetchedAt;
  const UguisuNicoliveUsersCompanion({
    this.id = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.anonymity = const Value.absent(),
    this.nickname = const Value.absent(),
    this.iconUrl = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  UguisuNicoliveUsersCompanion.insert({
    this.id = const Value.absent(),
    required String serviceId,
    required String userId,
    required bool anonymity,
    this.nickname = const Value.absent(),
    this.iconUrl = const Value.absent(),
    required DateTime fetchedAt,
  })  : serviceId = Value(serviceId),
        userId = Value(userId),
        anonymity = Value(anonymity),
        fetchedAt = Value(fetchedAt);
  static Insertable<UguisuNicoliveUser> custom({
    Expression<int>? id,
    Expression<String>? serviceId,
    Expression<String>? userId,
    Expression<bool>? anonymity,
    Expression<String>? nickname,
    Expression<String>? iconUrl,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceId != null) 'service_id': serviceId,
      if (userId != null) 'user_id': userId,
      if (anonymity != null) 'anonymity': anonymity,
      if (nickname != null) 'nickname': nickname,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  UguisuNicoliveUsersCompanion copyWith(
      {Value<int>? id,
      Value<String>? serviceId,
      Value<String>? userId,
      Value<bool>? anonymity,
      Value<String?>? nickname,
      Value<String?>? iconUrl,
      Value<DateTime>? fetchedAt}) {
    return UguisuNicoliveUsersCompanion(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      userId: userId ?? this.userId,
      anonymity: anonymity ?? this.anonymity,
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
      map['user_id'] = Variable<String>(userId.value);
    }
    if (anonymity.present) {
      map['anonymity'] = Variable<bool>(anonymity.value);
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
          ..write('anonymity: $anonymity, ')
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
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _anonymityMeta = const VerificationMeta('anonymity');
  @override
  late final GeneratedColumn<bool> anonymity = GeneratedColumn<bool>(
      'anonymity', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: 'CHECK (anonymity IN (0, 1))');
  final VerificationMeta _nicknameMeta = const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  final VerificationMeta _iconUrlMeta = const VerificationMeta('iconUrl');
  @override
  late final GeneratedColumn<String> iconUrl = GeneratedColumn<String>(
      'icon_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  final VerificationMeta _fetchedAtMeta = const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, serviceId, userId, anonymity, nickname, iconUrl, fetchedAt];
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
    if (data.containsKey('anonymity')) {
      context.handle(_anonymityMeta,
          anonymity.isAcceptableOrUnknown(data['anonymity']!, _anonymityMeta));
    } else if (isInserting) {
      context.missing(_anonymityMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    }
    if (data.containsKey('icon_url')) {
      context.handle(_iconUrlMeta,
          iconUrl.isAcceptableOrUnknown(data['icon_url']!, _iconUrlMeta));
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
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      anonymity: attachedDatabase.options.types
          .read(DriftSqlType.bool, data['${effectivePrefix}anonymity'])!,
      nickname: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}nickname']),
      iconUrl: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}icon_url']),
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

class UguisuNicoliveRoom extends DataClass
    implements Insertable<UguisuNicoliveRoom> {
  final int id;
  final int program;
  final String thread;
  final String name;
  final DateTime fetchedAt;
  const UguisuNicoliveRoom(
      {required this.id,
      required this.program,
      required this.thread,
      required this.name,
      required this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['program'] = Variable<int>(program);
    map['thread'] = Variable<String>(thread);
    map['name'] = Variable<String>(name);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  UguisuNicoliveRoomsCompanion toCompanion(bool nullToAbsent) {
    return UguisuNicoliveRoomsCompanion(
      id: Value(id),
      program: Value(program),
      thread: Value(thread),
      name: Value(name),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory UguisuNicoliveRoom.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UguisuNicoliveRoom(
      id: serializer.fromJson<int>(json['id']),
      program: serializer.fromJson<int>(json['program']),
      thread: serializer.fromJson<String>(json['thread']),
      name: serializer.fromJson<String>(json['name']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'program': serializer.toJson<int>(program),
      'thread': serializer.toJson<String>(thread),
      'name': serializer.toJson<String>(name),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  UguisuNicoliveRoom copyWith(
          {int? id,
          int? program,
          String? thread,
          String? name,
          DateTime? fetchedAt}) =>
      UguisuNicoliveRoom(
        id: id ?? this.id,
        program: program ?? this.program,
        thread: thread ?? this.thread,
        name: name ?? this.name,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  @override
  String toString() {
    return (StringBuffer('UguisuNicoliveRoom(')
          ..write('id: $id, ')
          ..write('program: $program, ')
          ..write('thread: $thread, ')
          ..write('name: $name, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, program, thread, name, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UguisuNicoliveRoom &&
          other.id == this.id &&
          other.program == this.program &&
          other.thread == this.thread &&
          other.name == this.name &&
          other.fetchedAt == this.fetchedAt);
}

class UguisuNicoliveRoomsCompanion extends UpdateCompanion<UguisuNicoliveRoom> {
  final Value<int> id;
  final Value<int> program;
  final Value<String> thread;
  final Value<String> name;
  final Value<DateTime> fetchedAt;
  const UguisuNicoliveRoomsCompanion({
    this.id = const Value.absent(),
    this.program = const Value.absent(),
    this.thread = const Value.absent(),
    this.name = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  UguisuNicoliveRoomsCompanion.insert({
    this.id = const Value.absent(),
    required int program,
    required String thread,
    required String name,
    required DateTime fetchedAt,
  })  : program = Value(program),
        thread = Value(thread),
        name = Value(name),
        fetchedAt = Value(fetchedAt);
  static Insertable<UguisuNicoliveRoom> custom({
    Expression<int>? id,
    Expression<int>? program,
    Expression<String>? thread,
    Expression<String>? name,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (program != null) 'program': program,
      if (thread != null) 'thread': thread,
      if (name != null) 'name': name,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  UguisuNicoliveRoomsCompanion copyWith(
      {Value<int>? id,
      Value<int>? program,
      Value<String>? thread,
      Value<String>? name,
      Value<DateTime>? fetchedAt}) {
    return UguisuNicoliveRoomsCompanion(
      id: id ?? this.id,
      program: program ?? this.program,
      thread: thread ?? this.thread,
      name: name ?? this.name,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (program.present) {
      map['program'] = Variable<int>(program.value);
    }
    if (thread.present) {
      map['thread'] = Variable<String>(thread.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UguisuNicoliveRoomsCompanion(')
          ..write('id: $id, ')
          ..write('program: $program, ')
          ..write('thread: $thread, ')
          ..write('name: $name, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $UguisuNicoliveRoomsTable extends UguisuNicoliveRooms
    with TableInfo<$UguisuNicoliveRoomsTable, UguisuNicoliveRoom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UguisuNicoliveRoomsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _programMeta = const VerificationMeta('program');
  @override
  late final GeneratedColumn<int> program = GeneratedColumn<int>(
      'program', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: 'REFERENCES uguisu_nicolive_programs (id)');
  final VerificationMeta _threadMeta = const VerificationMeta('thread');
  @override
  late final GeneratedColumn<String> thread = GeneratedColumn<String>(
      'thread', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _fetchedAtMeta = const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, program, thread, name, fetchedAt];
  @override
  String get aliasedName => _alias ?? 'uguisu_nicolive_rooms';
  @override
  String get actualTableName => 'uguisu_nicolive_rooms';
  @override
  VerificationContext validateIntegrity(Insertable<UguisuNicoliveRoom> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('program')) {
      context.handle(_programMeta,
          program.isAcceptableOrUnknown(data['program']!, _programMeta));
    } else if (isInserting) {
      context.missing(_programMeta);
    }
    if (data.containsKey('thread')) {
      context.handle(_threadMeta,
          thread.isAcceptableOrUnknown(data['thread']!, _threadMeta));
    } else if (isInserting) {
      context.missing(_threadMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
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
        {program, thread},
      ];
  @override
  UguisuNicoliveRoom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UguisuNicoliveRoom(
      id: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      program: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}program'])!,
      thread: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}thread'])!,
      name: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      fetchedAt: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
    );
  }

  @override
  $UguisuNicoliveRoomsTable createAlias(String alias) {
    return $UguisuNicoliveRoomsTable(attachedDatabase, alias);
  }
}

class UguisuNicoliveComment extends DataClass
    implements Insertable<UguisuNicoliveComment> {
  final int id;
  final int room;
  final int user;
  final int no;
  final String content;
  final int? anonymity;
  final int? premium;
  final String? mail;
  final DateTime postedAt;
  final int vpos;
  final DateTime fetchedAt;
  const UguisuNicoliveComment(
      {required this.id,
      required this.room,
      required this.user,
      required this.no,
      required this.content,
      this.anonymity,
      this.premium,
      this.mail,
      required this.postedAt,
      required this.vpos,
      required this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['room'] = Variable<int>(room);
    map['user'] = Variable<int>(user);
    map['no'] = Variable<int>(no);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || anonymity != null) {
      map['anonymity'] = Variable<int>(anonymity);
    }
    if (!nullToAbsent || premium != null) {
      map['premium'] = Variable<int>(premium);
    }
    if (!nullToAbsent || mail != null) {
      map['mail'] = Variable<String>(mail);
    }
    map['posted_at'] = Variable<DateTime>(postedAt);
    map['vpos'] = Variable<int>(vpos);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  UguisuNicoliveCommentsCompanion toCompanion(bool nullToAbsent) {
    return UguisuNicoliveCommentsCompanion(
      id: Value(id),
      room: Value(room),
      user: Value(user),
      no: Value(no),
      content: Value(content),
      anonymity: anonymity == null && nullToAbsent
          ? const Value.absent()
          : Value(anonymity),
      premium: premium == null && nullToAbsent
          ? const Value.absent()
          : Value(premium),
      mail: mail == null && nullToAbsent ? const Value.absent() : Value(mail),
      postedAt: Value(postedAt),
      vpos: Value(vpos),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory UguisuNicoliveComment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UguisuNicoliveComment(
      id: serializer.fromJson<int>(json['id']),
      room: serializer.fromJson<int>(json['room']),
      user: serializer.fromJson<int>(json['user']),
      no: serializer.fromJson<int>(json['no']),
      content: serializer.fromJson<String>(json['content']),
      anonymity: serializer.fromJson<int?>(json['anonymity']),
      premium: serializer.fromJson<int?>(json['premium']),
      mail: serializer.fromJson<String?>(json['mail']),
      postedAt: serializer.fromJson<DateTime>(json['postedAt']),
      vpos: serializer.fromJson<int>(json['vpos']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'room': serializer.toJson<int>(room),
      'user': serializer.toJson<int>(user),
      'no': serializer.toJson<int>(no),
      'content': serializer.toJson<String>(content),
      'anonymity': serializer.toJson<int?>(anonymity),
      'premium': serializer.toJson<int?>(premium),
      'mail': serializer.toJson<String?>(mail),
      'postedAt': serializer.toJson<DateTime>(postedAt),
      'vpos': serializer.toJson<int>(vpos),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  UguisuNicoliveComment copyWith(
          {int? id,
          int? room,
          int? user,
          int? no,
          String? content,
          Value<int?> anonymity = const Value.absent(),
          Value<int?> premium = const Value.absent(),
          Value<String?> mail = const Value.absent(),
          DateTime? postedAt,
          int? vpos,
          DateTime? fetchedAt}) =>
      UguisuNicoliveComment(
        id: id ?? this.id,
        room: room ?? this.room,
        user: user ?? this.user,
        no: no ?? this.no,
        content: content ?? this.content,
        anonymity: anonymity.present ? anonymity.value : this.anonymity,
        premium: premium.present ? premium.value : this.premium,
        mail: mail.present ? mail.value : this.mail,
        postedAt: postedAt ?? this.postedAt,
        vpos: vpos ?? this.vpos,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  @override
  String toString() {
    return (StringBuffer('UguisuNicoliveComment(')
          ..write('id: $id, ')
          ..write('room: $room, ')
          ..write('user: $user, ')
          ..write('no: $no, ')
          ..write('content: $content, ')
          ..write('anonymity: $anonymity, ')
          ..write('premium: $premium, ')
          ..write('mail: $mail, ')
          ..write('postedAt: $postedAt, ')
          ..write('vpos: $vpos, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, room, user, no, content, anonymity,
      premium, mail, postedAt, vpos, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UguisuNicoliveComment &&
          other.id == this.id &&
          other.room == this.room &&
          other.user == this.user &&
          other.no == this.no &&
          other.content == this.content &&
          other.anonymity == this.anonymity &&
          other.premium == this.premium &&
          other.mail == this.mail &&
          other.postedAt == this.postedAt &&
          other.vpos == this.vpos &&
          other.fetchedAt == this.fetchedAt);
}

class UguisuNicoliveCommentsCompanion
    extends UpdateCompanion<UguisuNicoliveComment> {
  final Value<int> id;
  final Value<int> room;
  final Value<int> user;
  final Value<int> no;
  final Value<String> content;
  final Value<int?> anonymity;
  final Value<int?> premium;
  final Value<String?> mail;
  final Value<DateTime> postedAt;
  final Value<int> vpos;
  final Value<DateTime> fetchedAt;
  const UguisuNicoliveCommentsCompanion({
    this.id = const Value.absent(),
    this.room = const Value.absent(),
    this.user = const Value.absent(),
    this.no = const Value.absent(),
    this.content = const Value.absent(),
    this.anonymity = const Value.absent(),
    this.premium = const Value.absent(),
    this.mail = const Value.absent(),
    this.postedAt = const Value.absent(),
    this.vpos = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  UguisuNicoliveCommentsCompanion.insert({
    this.id = const Value.absent(),
    required int room,
    required int user,
    required int no,
    required String content,
    this.anonymity = const Value.absent(),
    this.premium = const Value.absent(),
    this.mail = const Value.absent(),
    required DateTime postedAt,
    required int vpos,
    required DateTime fetchedAt,
  })  : room = Value(room),
        user = Value(user),
        no = Value(no),
        content = Value(content),
        postedAt = Value(postedAt),
        vpos = Value(vpos),
        fetchedAt = Value(fetchedAt);
  static Insertable<UguisuNicoliveComment> custom({
    Expression<int>? id,
    Expression<int>? room,
    Expression<int>? user,
    Expression<int>? no,
    Expression<String>? content,
    Expression<int>? anonymity,
    Expression<int>? premium,
    Expression<String>? mail,
    Expression<DateTime>? postedAt,
    Expression<int>? vpos,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (room != null) 'room': room,
      if (user != null) 'user': user,
      if (no != null) 'no': no,
      if (content != null) 'content': content,
      if (anonymity != null) 'anonymity': anonymity,
      if (premium != null) 'premium': premium,
      if (mail != null) 'mail': mail,
      if (postedAt != null) 'posted_at': postedAt,
      if (vpos != null) 'vpos': vpos,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  UguisuNicoliveCommentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? room,
      Value<int>? user,
      Value<int>? no,
      Value<String>? content,
      Value<int?>? anonymity,
      Value<int?>? premium,
      Value<String?>? mail,
      Value<DateTime>? postedAt,
      Value<int>? vpos,
      Value<DateTime>? fetchedAt}) {
    return UguisuNicoliveCommentsCompanion(
      id: id ?? this.id,
      room: room ?? this.room,
      user: user ?? this.user,
      no: no ?? this.no,
      content: content ?? this.content,
      anonymity: anonymity ?? this.anonymity,
      premium: premium ?? this.premium,
      mail: mail ?? this.mail,
      postedAt: postedAt ?? this.postedAt,
      vpos: vpos ?? this.vpos,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (room.present) {
      map['room'] = Variable<int>(room.value);
    }
    if (user.present) {
      map['user'] = Variable<int>(user.value);
    }
    if (no.present) {
      map['no'] = Variable<int>(no.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (anonymity.present) {
      map['anonymity'] = Variable<int>(anonymity.value);
    }
    if (premium.present) {
      map['premium'] = Variable<int>(premium.value);
    }
    if (mail.present) {
      map['mail'] = Variable<String>(mail.value);
    }
    if (postedAt.present) {
      map['posted_at'] = Variable<DateTime>(postedAt.value);
    }
    if (vpos.present) {
      map['vpos'] = Variable<int>(vpos.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UguisuNicoliveCommentsCompanion(')
          ..write('id: $id, ')
          ..write('room: $room, ')
          ..write('user: $user, ')
          ..write('no: $no, ')
          ..write('content: $content, ')
          ..write('anonymity: $anonymity, ')
          ..write('premium: $premium, ')
          ..write('mail: $mail, ')
          ..write('postedAt: $postedAt, ')
          ..write('vpos: $vpos, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $UguisuNicoliveCommentsTable extends UguisuNicoliveComments
    with TableInfo<$UguisuNicoliveCommentsTable, UguisuNicoliveComment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UguisuNicoliveCommentsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<int> room = GeneratedColumn<int>(
      'room', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: 'REFERENCES uguisu_nicolive_rooms (id)');
  final VerificationMeta _userMeta = const VerificationMeta('user');
  @override
  late final GeneratedColumn<int> user = GeneratedColumn<int>(
      'user', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: 'REFERENCES uguisu_nicolive_users (id)');
  final VerificationMeta _noMeta = const VerificationMeta('no');
  @override
  late final GeneratedColumn<int> no = GeneratedColumn<int>(
      'no', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  final VerificationMeta _contentMeta = const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  final VerificationMeta _anonymityMeta = const VerificationMeta('anonymity');
  @override
  late final GeneratedColumn<int> anonymity = GeneratedColumn<int>(
      'anonymity', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  final VerificationMeta _premiumMeta = const VerificationMeta('premium');
  @override
  late final GeneratedColumn<int> premium = GeneratedColumn<int>(
      'premium', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  final VerificationMeta _mailMeta = const VerificationMeta('mail');
  @override
  late final GeneratedColumn<String> mail = GeneratedColumn<String>(
      'mail', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  final VerificationMeta _postedAtMeta = const VerificationMeta('postedAt');
  @override
  late final GeneratedColumn<DateTime> postedAt = GeneratedColumn<DateTime>(
      'posted_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  final VerificationMeta _vposMeta = const VerificationMeta('vpos');
  @override
  late final GeneratedColumn<int> vpos = GeneratedColumn<int>(
      'vpos', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  final VerificationMeta _fetchedAtMeta = const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        room,
        user,
        no,
        content,
        anonymity,
        premium,
        mail,
        postedAt,
        vpos,
        fetchedAt
      ];
  @override
  String get aliasedName => _alias ?? 'uguisu_nicolive_comments';
  @override
  String get actualTableName => 'uguisu_nicolive_comments';
  @override
  VerificationContext validateIntegrity(
      Insertable<UguisuNicoliveComment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('room')) {
      context.handle(
          _roomMeta, room.isAcceptableOrUnknown(data['room']!, _roomMeta));
    } else if (isInserting) {
      context.missing(_roomMeta);
    }
    if (data.containsKey('user')) {
      context.handle(
          _userMeta, user.isAcceptableOrUnknown(data['user']!, _userMeta));
    } else if (isInserting) {
      context.missing(_userMeta);
    }
    if (data.containsKey('no')) {
      context.handle(_noMeta, no.isAcceptableOrUnknown(data['no']!, _noMeta));
    } else if (isInserting) {
      context.missing(_noMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('anonymity')) {
      context.handle(_anonymityMeta,
          anonymity.isAcceptableOrUnknown(data['anonymity']!, _anonymityMeta));
    }
    if (data.containsKey('premium')) {
      context.handle(_premiumMeta,
          premium.isAcceptableOrUnknown(data['premium']!, _premiumMeta));
    }
    if (data.containsKey('mail')) {
      context.handle(
          _mailMeta, mail.isAcceptableOrUnknown(data['mail']!, _mailMeta));
    }
    if (data.containsKey('posted_at')) {
      context.handle(_postedAtMeta,
          postedAt.isAcceptableOrUnknown(data['posted_at']!, _postedAtMeta));
    } else if (isInserting) {
      context.missing(_postedAtMeta);
    }
    if (data.containsKey('vpos')) {
      context.handle(
          _vposMeta, vpos.isAcceptableOrUnknown(data['vpos']!, _vposMeta));
    } else if (isInserting) {
      context.missing(_vposMeta);
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
        {room, no},
      ];
  @override
  UguisuNicoliveComment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UguisuNicoliveComment(
      id: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      room: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}room'])!,
      user: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}user'])!,
      no: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}no'])!,
      content: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      anonymity: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}anonymity']),
      premium: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}premium']),
      mail: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}mail']),
      postedAt: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}posted_at'])!,
      vpos: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}vpos'])!,
      fetchedAt: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
    );
  }

  @override
  $UguisuNicoliveCommentsTable createAlias(String alias) {
    return $UguisuNicoliveCommentsTable(attachedDatabase, alias);
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
  late final $UguisuNicoliveRoomsTable uguisuNicoliveRooms =
      $UguisuNicoliveRoomsTable(this);
  late final $UguisuNicoliveCommentsTable uguisuNicoliveComments =
      $UguisuNicoliveCommentsTable(this);
  @override
  Iterable<TableInfo<Table, dynamic>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        uguisuNicoliveUsers,
        uguisuNicoliveUserIconCaches,
        uguisuNicoliveCommunities,
        uguisuNicoliveCommunityIconCaches,
        uguisuNicolivePrograms,
        uguisuNicoliveRooms,
        uguisuNicoliveComments
      ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}
