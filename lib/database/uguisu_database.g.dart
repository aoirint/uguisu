// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uguisu_database.dart';

// **************************************************************************
// DriftDatabaseGenerator
// **************************************************************************

// ignore_for_file: type=lint
class UguisuNicoliveProgram extends DataClass
    implements Insertable<UguisuNicoliveProgram> {
  final int id;
  final String serviceId;
  final String programId;
  final String title;
  final String? webSocketUrl;
  final DateTime fetchedAt;
  const UguisuNicoliveProgram(
      {required this.id,
      required this.serviceId,
      required this.programId,
      required this.title,
      this.webSocketUrl,
      required this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['service_id'] = Variable<String>(serviceId);
    map['program_id'] = Variable<String>(programId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || webSocketUrl != null) {
      map['web_socket_url'] = Variable<String>(webSocketUrl);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  UguisuNicoliveProgramsCompanion toCompanion(bool nullToAbsent) {
    return UguisuNicoliveProgramsCompanion(
      id: Value(id),
      serviceId: Value(serviceId),
      programId: Value(programId),
      title: Value(title),
      webSocketUrl: webSocketUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(webSocketUrl),
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
      webSocketUrl: serializer.fromJson<String?>(json['webSocketUrl']),
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
      'webSocketUrl': serializer.toJson<String?>(webSocketUrl),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  UguisuNicoliveProgram copyWith(
          {int? id,
          String? serviceId,
          String? programId,
          String? title,
          Value<String?> webSocketUrl = const Value.absent(),
          DateTime? fetchedAt}) =>
      UguisuNicoliveProgram(
        id: id ?? this.id,
        serviceId: serviceId ?? this.serviceId,
        programId: programId ?? this.programId,
        title: title ?? this.title,
        webSocketUrl:
            webSocketUrl.present ? webSocketUrl.value : this.webSocketUrl,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  @override
  String toString() {
    return (StringBuffer('UguisuNicoliveProgram(')
          ..write('id: $id, ')
          ..write('serviceId: $serviceId, ')
          ..write('programId: $programId, ')
          ..write('title: $title, ')
          ..write('webSocketUrl: $webSocketUrl, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, serviceId, programId, title, webSocketUrl, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UguisuNicoliveProgram &&
          other.id == this.id &&
          other.serviceId == this.serviceId &&
          other.programId == this.programId &&
          other.title == this.title &&
          other.webSocketUrl == this.webSocketUrl &&
          other.fetchedAt == this.fetchedAt);
}

class UguisuNicoliveProgramsCompanion
    extends UpdateCompanion<UguisuNicoliveProgram> {
  final Value<int> id;
  final Value<String> serviceId;
  final Value<String> programId;
  final Value<String> title;
  final Value<String?> webSocketUrl;
  final Value<DateTime> fetchedAt;
  const UguisuNicoliveProgramsCompanion({
    this.id = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.programId = const Value.absent(),
    this.title = const Value.absent(),
    this.webSocketUrl = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  UguisuNicoliveProgramsCompanion.insert({
    this.id = const Value.absent(),
    required String serviceId,
    required String programId,
    required String title,
    this.webSocketUrl = const Value.absent(),
    required DateTime fetchedAt,
  })  : serviceId = Value(serviceId),
        programId = Value(programId),
        title = Value(title),
        fetchedAt = Value(fetchedAt);
  static Insertable<UguisuNicoliveProgram> custom({
    Expression<int>? id,
    Expression<String>? serviceId,
    Expression<String>? programId,
    Expression<String>? title,
    Expression<String>? webSocketUrl,
    Expression<DateTime>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceId != null) 'service_id': serviceId,
      if (programId != null) 'program_id': programId,
      if (title != null) 'title': title,
      if (webSocketUrl != null) 'web_socket_url': webSocketUrl,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  UguisuNicoliveProgramsCompanion copyWith(
      {Value<int>? id,
      Value<String>? serviceId,
      Value<String>? programId,
      Value<String>? title,
      Value<String?>? webSocketUrl,
      Value<DateTime>? fetchedAt}) {
    return UguisuNicoliveProgramsCompanion(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      programId: programId ?? this.programId,
      title: title ?? this.title,
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
  final VerificationMeta _webSocketUrlMeta =
      const VerificationMeta('webSocketUrl');
  @override
  late final GeneratedColumn<String> webSocketUrl = GeneratedColumn<String>(
      'web_socket_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  final VerificationMeta _fetchedAtMeta = const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, serviceId, programId, title, webSocketUrl, fetchedAt];
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
    if (data.containsKey('web_socket_url')) {
      context.handle(
          _webSocketUrlMeta,
          webSocketUrl.isAcceptableOrUnknown(
              data['web_socket_url']!, _webSocketUrlMeta));
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
      webSocketUrl: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}web_socket_url']),
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
  late final $UguisuNicoliveProgramsTable uguisuNicolivePrograms =
      $UguisuNicoliveProgramsTable(this);
  @override
  Iterable<TableInfo<Table, dynamic>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [uguisuNicolivePrograms];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}
