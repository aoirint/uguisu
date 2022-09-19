
abstract class NicoliveComment {
  String getThreadId();
  String getUserId();

  int getNo();
  bool isAnonymous();
  bool isPremium();
  bool isBroadcaster();
  bool isCommand();
  bool isAdmin();
  bool isRed();
  bool isDisconnect();
  String getContent();
  DateTime getPostedAt();
  int getVpos();
}
