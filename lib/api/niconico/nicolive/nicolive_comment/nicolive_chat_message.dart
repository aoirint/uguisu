import 'nicolive_comment.dart';

class NicoliveChatMessage with NicoliveComment {
  String thread;

  int? anonymity;
  String content;
  int date;
  int dateUsec;
  int no;
  int? premium;
  String? mail;
  String userId;
  int vpos;

  NicoliveChatMessage({
    required this.thread,
    this.anonymity,
    required this.content,
    required this.date,
    required this.dateUsec,
    required this.no,
    this.premium,
    this.mail,
    required this.userId,
    required this.vpos,
  });

  @override String getThreadId() => thread;

  @override String getContent() => content;
  @override int getNo() => no;
  @override DateTime getPostedAt() =>
    DateTime.fromMicrosecondsSinceEpoch(date * 1000 * 1000 + dateUsec, isUtc: true);

  @override String getUserId() => userId;
  @override int getVpos() => vpos;

  @override bool isAnonymous() => anonymity == 1;
  @override bool isPremium() => premium == 1;
  @override bool isBroadcaster() => anonymity == null && premium == 3;
  @override bool isCommand() => anonymity != null && premium == 3;
  @override bool isAdmin() => premium == 2;
  @override bool isRed() => isBroadcaster() || isCommand() || isAdmin();
  @override bool isDisconnect() => isAdmin() && getContent() == '/disconnect';
}

abstract class NicoliveChatMessageRepository {
  Future<void> upsertNicoliveChatMessage({required String nicoliveProgramId, required NicoliveChatMessage nicoliveChatMessage});
  Future<void> upsertAllNicoliveChatMessages({required String nicoliveProgramId, required List<NicoliveChatMessage> nicoliveChatMessages});
  Future<NicoliveChatMessage> loadNicoliveChatMessageByNo({required String nicoliveProgramId, required String threadId, required String no});
  Future<List<NicoliveChatMessage>> loadAllNicoliveChatMessages({required String nicoliveProgramId, required String threadId, required String no});
}

abstract class NicoliveChatMessageDatabase {
  Future<void> upsertNicoliveChatMessage({required String nicoliveProgramId, required NicoliveChatMessage nicoliveChatMessage});
  Future<void> upsertAllNicoliveChatMessages({required String nicoliveProgramId, required List<NicoliveChatMessage> nicoliveChatMessages});
  Future<NicoliveChatMessage> loadNicoliveChatMessageByNo({required String nicoliveProgramId, required String threadId, required String no});
  Future<List<NicoliveChatMessage>> loadAllNicoliveChatMessages({required String nicoliveProgramId, required String threadId, required String no});
}

class NicoliveChatMessageDatabaseRepository extends NicoliveChatMessageRepository {
  final NicoliveChatMessageDatabase database;

  NicoliveChatMessageDatabaseRepository({required this.database});

  @override Future<List<NicoliveChatMessage>> loadAllNicoliveChatMessages() =>
    database.loadAllNicoliveChatMessages();

  @override Future<NicoliveChatMessage> loadNicoliveChatMessageByNo({required String no}) =>
    database.loadNicoliveChatMessageByNo(no: no);

  @override
  Future<void> upsertAllNicoliveChatMessages({required List<NicoliveChatMessage> nicoliveChatMessages}) =>
    database.upsertAllNicoliveChatMessages(nicoliveChatMessages: nicoliveChatMessages);

  @override
  Future<void> upsertNicoliveChatMessage({required NicoliveChatMessage nicoliveChatMessage}) =>
    database.upsertNicoliveChatMessage(nicoliveChatMessage: nicoliveChatMessage);
}
