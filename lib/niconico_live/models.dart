
class NiconicoLiveComment {
  final String accountId;
  final String text;
  final DateTime commentedAt; // UTC

  NiconicoLiveComment({required this.accountId, required this.text, required this.commentedAt});
}
