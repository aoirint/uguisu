
import 'package:flutter/material.dart';

class NiconicoLiveStatistics extends StatelessWidget {
  final int? viewers;
  final int? comments;
  final int? adPoints;
  final int? giftPoints;

  const NiconicoLiveStatistics({
    super.key,
    this.viewers,
    this.comments,
    this.adPoints,
    this.giftPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: '来場者数',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 24.0, height: 24.0, child: FittedBox(child: Icon(Icons.person))),
                  const SizedBox(width: 4.0),
                  Text(viewers != null ? viewers.toString() :  '-'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: 'コメント数',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 24.0, height: 24.0, child: FittedBox(child: Icon(Icons.comment))),
                  const SizedBox(width: 4.0),
                  Text(comments != null ? comments.toString() :  '-'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: 'ニコニ広告ポイント',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 24.0, height: 24.0, child: FittedBox(child: Icon(Icons.campaign))),
                  const SizedBox(width: 4.0),
                  Text(adPoints != null ? adPoints.toString() :  '-'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: 'ギフトポイント',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 24.0, height: 24.0, child: FittedBox(child: Icon(Icons.redeem))),
                  const SizedBox(width: 4.0),
                  Text(giftPoints != null ? giftPoints.toString() :  '-'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
