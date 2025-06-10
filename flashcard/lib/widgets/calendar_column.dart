import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarColumn extends StatefulWidget {
  final DateTime day; // N.B the hour and minute are stipped and ignored as they are useless
  final List<Event> events;

  const CalendarColumn({super.key, required this.day, required this.events});

  @override
  State<CalendarColumn> createState() => _CalendarColumnState();
}

class _CalendarColumnState extends State<CalendarColumn> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(2),
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE d/M").format(widget.day),
              style: theme.textTheme.bodyMedium!.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.fade,
            ),
            SizedBox(height: 10),
            Column(
              children: widget.events.map((event) {
                
                // Event Tile 
                return EventWidget(event: event);

              }).toList()
            )
          ]
        )
      )
    );
  }
}

class Event {
  final DateTime time;
  final String title;
  final String? description;
  final Function() link; // function is called when the event is presed

  Event({required this.time, required this.title, required this.link, this.description});
}

class EventWidget extends StatelessWidget {
  final Event event;

  const EventWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: event.link,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.only(left: 2, right: 2, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Color.fromRGBO(44, 44, 44, 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          event.title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
          textAlign: TextAlign.center,
          maxLines: 3,
        ),
      ),
    );
  }
}