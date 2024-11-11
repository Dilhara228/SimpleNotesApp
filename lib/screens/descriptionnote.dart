import 'package:flutter/material.dart';

class DescriptionNote extends StatefulWidget {
  final String tittle;
  final String description;
  final Color color;

  DescriptionNote({
    required this.tittle,
    required this.description,
    required this.color,
  });

  @override
  State<DescriptionNote> createState() => _DescriptionNoteState();
}

class _DescriptionNoteState extends State<DescriptionNote> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Note Description',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
      ),
      backgroundColor: Colors.lightBlue[50],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Card(
                    color: widget.color,
                    child: ListTile(
                      title: Text(widget.tittle),
                      subtitle: Text(widget.description),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
