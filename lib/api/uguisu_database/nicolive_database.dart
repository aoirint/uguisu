// Program
class UguisuNicoliveProgram {
  final String serviceId;
  final String programId;
  final String title;
  final String? webSocketUrl;
  final DateTime fetchedAt;

  UguisuNicoliveProgram({
    required this.programId,
    required this.serviceId,
    required this.title,
    required this.webSocketUrl,
    required this.fetchedAt,
  });
}

abstract class UguisuNicoliveProgramRespository {
  Future<void> upsertNicoliveProgram({required UguisuNicoliveProgram nicoliveProgram});
  Future<UguisuNicoliveProgram?> loadNicoliveProgramById({required String serviceId, required String programId});
  Future<List<UguisuNicoliveProgram>> loadAllNicolivePrograms({required String serviceId});
}


// Schedule
class UguisuNicoliveSchedule {
  final String serviceId;
  final String programId;
  final DateTime begin;
  final DateTime end;
  final DateTime fetchedAt;

  UguisuNicoliveSchedule({
    required this.programId,
    required this.serviceId,
    required this.begin,
    required this.end,
    required this.fetchedAt,
  });
}

abstract class UguisuNicoliveScheduleRespository {
  Future<void> upsertNicoliveSchedule({required UguisuNicoliveSchedule nicoliveSchedule});
  Future<UguisuNicoliveSchedule?> loadNicoliveScheduleById({required String serviceId, required String programId});
}


// Statistics
class UguisuNicoliveStatistics {
  final String serviceId;
  final String programId;
  final int viewers;
  final int comments;
  final int adPoints;
  final int giftPoints;
  final DateTime fetchedAt;

  UguisuNicoliveStatistics({
    required this.programId,
    required this.serviceId,
    required this.viewers,
    required this.comments,
    required this.adPoints,
    required this.giftPoints,
    required this.fetchedAt,
  });
}

abstract class UguisuNicoliveStatisticsRespository {
  Future<void> insertNicoliveStatistics({required UguisuNicoliveStatistics nicoliveStatistics});
  Future<UguisuNicoliveStatistics?> loadLatestNicoliveStatisticsById({required String serviceId, required String programId});
  Future<List<UguisuNicoliveStatistics>> loadAllNicoliveStatisticsById({required String serviceId, required String programId});
}


// Room (Thread)
class UguisuNicoliveRoom {
  final String serviceId;
  final String programId;
  final String threadId;
  final String name;
  final DateTime fetchedAt;

  UguisuNicoliveRoom({
    required this.programId,
    required this.serviceId,
    required this.threadId,
    required this.name,
    required this.fetchedAt,
  });
}

abstract class NicoliveProgramRoomRespository {
  Future<void> upsertNicoliveRoom({required UguisuNicoliveRoom nicoliveRoom});
  Future<List<UguisuNicoliveRoom>> loadAllNicoliveRoomsByProgramId({required String serviceId, required String programId});
  Future<UguisuNicoliveRoom?> loadNicoliveRoomByProgramIdAndThreadId({required String serviceId, required String programId, required String threadId});
  Future<List<UguisuNicoliveRoom>> loadAllNicoliveRooms();
}

// Chat message
class UguisuNicoliveChatMessage {
  final String serviceId;
  final String programId;
  final String threadId;
  final DateTime fetchedAt;

  final int? anonymity;
  final String content;
  final int date;
  final int dateUsec;
  final int no;
  final int? premium;
  final String? mail;
  final String userId;
  final int vpos;

  UguisuNicoliveChatMessage({
    required this.programId,
    required this.serviceId,
    required this.threadId,
    required this.fetchedAt,
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
}

abstract class UguisuNicoliveProgramChatMessageRespository {
  Future<void> upsertNicoliveChatMessage({required String serviceId, required String programId, required UguisuNicoliveChatMessage nicoliveChatMessage});
  Future<void> upsertAllNicoliveChatMessages({required String serviceId, required String programId, required List<UguisuNicoliveChatMessage> nicoliveChatMessages});
  Future<UguisuNicoliveChatMessage> loadNicoliveChatMessageByNo({required String serviceId, required String programId, required String threadId, required String no});
  Future<List<UguisuNicoliveChatMessage>> loadAllNicoliveChatMessages({required String serviceId, required String programId, required String threadId});
}
