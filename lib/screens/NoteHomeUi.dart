import 'package:flutter/material.dart';
import '../services/NoteDbHelper.dart';
import 'descriptionnote.dart';

class NoteHomeUI extends StatefulWidget {
  const NoteHomeUI({super.key});

  @override
  State<NoteHomeUI> createState() => _NoteHomeUIState();
}

class _NoteHomeUIState extends State<NoteHomeUI> {
  final List<Color> noteColors = [
    Colors.pink[100]!,  // Pink
    Colors.yellow[100]!, // Yellow
    Colors.green[100]!,  // Green
    Colors.orange[100]!, // Orange
    Colors.purple[100]!  // Purple
  ];

  @override
  void initState() {
    super.initState();
    checkAndInsertDummyNotes();
  }

  // Check if the database is empty and insert dummy notes only if it's empty
  Future<void> checkAndInsertDummyNotes() async {
    List<Map<String, dynamic>> notes = await NoteDbHelper.instance.queryAll();
    if (notes.isEmpty) {
      // Insert dummy notes if the database is empty
      insertDatabase("Buy Groceries", "Milk, Eggs, Bread");
      insertDatabase("Meeting with Team", "Project update at 3PM");
      insertDatabase("Workout", "Go for a run in the morning");
      insertDatabase("Call Mom", "Ask about the weekend plan");
      insertDatabase("Book Reading", "Finish the chapter on AI");
    }
    setState(() {}); // Refresh the UI
  }

  // Insert into the database
  void insertDatabase(String title, String description) {
    NoteDbHelper.instance.insert({
      NoteDbHelper.coltittle: title,
      NoteDbHelper.coldescription: description,
      NoteDbHelper.coldate: DateTime.now().toString(),
    });
  }

  // Update the database
  void updateDatabase(AsyncSnapshot snap, int index, String? newTitle, String? newDescription) {
    String currentTitle = snap.data![index][NoteDbHelper.coltittle];
    String currentDescription = snap.data![index][NoteDbHelper.coldescription];

    NoteDbHelper.instance.update({
      NoteDbHelper.colid: snap.data![index][NoteDbHelper.colid],
      NoteDbHelper.coltittle: newTitle?.isEmpty == false ? newTitle : currentTitle,
      NoteDbHelper.coldescription: newDescription?.isEmpty == false ? newDescription : currentDescription,
      NoteDbHelper.coldate: DateTime.now().toString(),
    });
  }

  // Delete from the database
  void deleteDatabase(AsyncSnapshot snap, int index) {
    NoteDbHelper.instance.delete(snap.data![index][NoteDbHelper.colid]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.07,
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Notes',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87 // Set text color to black
          ),
        ),
      ),
      backgroundColor: Colors.lightBlue[50],
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: NoteDbHelper.instance.queryAll(),
          builder: (context, snap) {
            if (snap.hasData) {
              return ListView.builder(
                itemCount: snap.data!.length,
                itemBuilder: (context, index) {
                  final colorIndex = index % noteColors.length;
                  final noteColor = noteColors[colorIndex];

                  return Dismissible(
                    key: UniqueKey(),
                    onDismissed: (direction) {
                      deleteDatabase(snap, index);
                      setState(() {}); // Refresh UI after deletion
                    },
                    background: Container(
                      color: Colors.red,
                      child: const Icon(Icons.delete),
                    ),
                    child: Card(
                      color: noteColor,
                      child: ListTile(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return DescriptionNote(
                                tittle: snap.data![index][NoteDbHelper.coltittle],
                                description: snap.data![index][NoteDbHelper.coldescription],
                                color: noteColor,
                              );
                            },
                          ));
                        },
                        leading: IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                // Initialize the title and description with current values
                                String title = snap.data![index][NoteDbHelper.coltittle];
                                String description = snap.data![index][NoteDbHelper.coldescription];

                                return AlertDialog(
                                  title: const Text(
                                    'Edit Note',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        onChanged: (value) {
                                          title = value; // Update title as user types
                                        },
                                        controller: TextEditingController(
                                          text: snap.data![index][NoteDbHelper.coltittle],
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'Title',
                                        ),
                                      ),
                                      TextField(
                                        onChanged: (value) {
                                          description = value; // Update description as user types
                                        },
                                        controller: TextEditingController(
                                          text: snap.data![index][NoteDbHelper.coldescription],
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'Description',
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.blueAccent,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Update the database with new or unchanged values
                                        updateDatabase(snap, index, title, description);
                                        Navigator.pop(context); // Close the dialog
                                        setState(() {}); // Refresh the UI to reflect changes
                                      },
                                      child: const Text('Save'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.blueAccent,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.edit),
                          color: Colors.blue, // Blue color for the edit icon
                        ),
                        title: Text(snap.data![index][NoteDbHelper.coltittle]),
                        subtitle: Text(snap.data![index][NoteDbHelper.coldescription]),
                        trailing: Text(snap.data![index][NoteDbHelper.coldate]
                            .toString()
                            .substring(0, 10)),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 6.0, // Increased elevation for a bolder shadow
        backgroundColor: Colors.blueAccent, // Bold color for the background
        foregroundColor: Colors.black87, // White color for the icon
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              var title = '';
              var description = '';
              return AlertDialog(
                title: const Text(
                  'Add Note',
                  style: TextStyle(fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        title = value;
                      },
                      decoration: const InputDecoration(hintText: 'Title'),
                    ),
                    TextField(
                      onChanged: (value) {
                        description = value;
                      },
                      decoration: const InputDecoration(hintText: 'Description'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      insertDatabase(title, description);
                      Navigator.pop(context);
                      setState(() {}); // Refresh the UI
                    },
                    child: const Text('Save'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
