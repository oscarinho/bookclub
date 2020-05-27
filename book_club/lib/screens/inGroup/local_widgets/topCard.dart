import 'dart:async';

import 'package:book_club/models/authModel.dart';
import 'package:book_club/models/groupModel.dart';
import 'package:book_club/services/dbFuture.dart';
import 'package:book_club/utils/timeLeft.dart';
import 'package:book_club/widgets/shadowContainer.dart';
import 'package:book_club/screens/review/review.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopCard extends StatefulWidget {
  final GroupModel groupModel;

  TopCard({
    this.groupModel,
  });

  @override
  _TopCardState createState() => _TopCardState();
}

class _TopCardState extends State<TopCard> {
  String _timeUntil = "time";
  AuthModel _authModel;
  bool _doneWithBook = true;
  Timer _timer;

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        _timeUntil = TimeLeft().timeLeft(widget.groupModel.currentBookDue.toDate());
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authModel = Provider.of<AuthModel>(context);
    isUserDoneWithBook();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  isUserDoneWithBook() async {
    if (await DBFuture().isUserDoneWithBook(
        widget.groupModel.id, widget.groupModel.currentBookId, _authModel.uid)) {
      _doneWithBook = true;
    } else {
      _doneWithBook = false;
    }
  }

  void _goToReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Review(
          groupModel: widget.groupModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShadowContainer(
      child: Column(
        children: <Widget>[
          Text(
            widget.groupModel.currentBookId ?? "loading..",
            style: TextStyle(
              fontSize: 30,
              color: Colors.grey[600],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              children: <Widget>[
                Text(
                  "Due In: ",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.grey[600],
                  ),
                ),
                Expanded(
                  child: Text(
                    _timeUntil ?? "loading...",
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          RaisedButton(
            child: Text(
              "Finished Book",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _doneWithBook ? null : _goToReview,
          )
        ],
      ),
    );
  }
}
