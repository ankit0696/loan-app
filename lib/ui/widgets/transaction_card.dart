import 'package:flutter/material.dart';

class DismissibleCard extends StatefulWidget {
  final String title;
  final String subtitle;

  const DismissibleCard({Key? key, required this.title, required this.subtitle})
      : super(key: key);

  @override
  _DismissibleCardState createState() => _DismissibleCardState();
}

class _DismissibleCardState extends State<DismissibleCard> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.title),
      onDismissed: (direction) {
        // Do something when dismissed
      },
      background: Container(
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Colors.green,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(
                Icons.check,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      child: Card(
          color: Colors.black,
          child: ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://avatars.githubusercontent.com/u/61448739?v=4"),
            ),
            title: const Text("Alina",
                style: TextStyle(fontSize: 15, color: Colors.white)),
            subtitle: const Text("Paid you 1000",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("10/10/2021",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text("10:00 AM",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          )),
    );
  }
}
