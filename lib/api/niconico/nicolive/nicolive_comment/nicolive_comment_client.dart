
import 'nicolive_comment.dart';

abstract class NicoLiveCommentListener {
  void onNicoLiveCommentAdded({required NicoLiveComment nicoLiveComment});
}

abstract class NicoLiveCommentClient {
  void addNicoLiveCommentListener({required NicoLiveCommentListener nicoLiveCommentListener});
  void removeAllNicoLiveCommentListeners();

  Future<void> connect();
  Future<void> disconnect();
}
