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
    Colors.pink[100]!,
    Colors.yellow[100]!,
    Colors.green[100]!,
    Colors.orange[100]!,
    Colors.purple[100]!
  ];

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isAscending = true; // Variable to track sort order

  @override
  void initState() {
    super.initState();
    checkAndInsertDummyNotes();
  }

  Future<void> checkAndInsertDummyNotes() async {
    List<Map<String, dynamic>> notes = await NoteDbHelper.instance.queryAll();
    if (notes.isEmpty) {
      insertDatabase("Buy Groceries", "Milk, Eggs, Bread");
      insertDatabase("Meeting with Team", "Project update at 3PM");
      insertDatabase("Workout", "Go for a run in the morning");
      insertDatabase("Call Mom", "Ask about the weekend plan");
      insertDatabase("Book Reading", "Finish the chapter on AI");
    }
    setState(() {});
  }

  void insertDatabase(String title, String description) {
    NoteDbHelper.instance.insert({
      NoteDbHelper.coltittle: title,
      NoteDbHelper.coldescription: description,
      NoteDbHelper.coldate: DateTime.now().toString(),
    });
  }

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

  void deleteDatabase(AsyncSnapshot snap, int index) {
    NoteDbHelper.instance.delete(snap.data![index][NoteDbHelper.colid]);
  }

  // Toggle the sort order
  void toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.07,
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Notes',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        actions: [
          // Sort Icon
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.black),
            onPressed: () {
              toggleSortOrder(); // Toggle between ascending and descending order
            },
          ),
        ],
      ),
      backgroundColor: Colors.lightBlue[50],
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                textInputAction: TextInputAction.done, // Ensures no menu icon appears
                decoration: InputDecoration(
                  hintText: 'Search Notes...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
              ),
            ),
            // Notes List
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _searchQuery.isEmpty
                    ? NoteDbHelper.instance.queryAllOrdered(_isAscending)
                    : NoteDbHelper.instance.searchNotes(_searchQuery),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  } else if (snap.hasData && snap.data!.isEmpty) {
                    return const Center(child: Text('No Notes Found'));
                  } else if (snap.hasData) {
                    return ListView.builder(
                      itemCount: snap.data!.length,
                      itemBuilder: (context, index) {
                        final colorIndex = index % noteColors.length;
                        final noteColor = noteColors[colorIndex];

                        return Dismissible(
                          key: UniqueKey(),
                          onDismissed: (direction) {
                            deleteDatabase(snap, index);
                            setState(() {});
                          },
                          background: Container(
                            color: Colors.red,
                            child: const Icon(Icons.delete),
                          ),
                          child: Card(
                            color: noteColor,
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return DescriptionNote(
                                        tittle: snap.data![index][NoteDbHelper.coltittle],
                                        description: snap.data![index][NoteDbHelper.coldescription],
                                        color: noteColor,
                                      );
                                    },
                                  ),
                                );
                              },
                              leading: IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      String title = snap.data![index][NoteDbHelper.coltittle];
                                      String description = snap.data![index][NoteDbHelper.coldescription];

                                      return AlertDialog(
                                        title: const Text('Edit Note', style: TextStyle(fontWeight: FontWeight.bold)),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              onChanged: (value) {
                                                title = value;
                                              },
                                              controller: TextEditingController(
                                                text: snap.data![index][NoteDbHelper.coltittle],
                                              ),
                                              decoration: const InputDecoration(hintText: 'Title'),
                                            ),
                                            TextField(
                                              onChanged: (value) {
                                                description = value;
                                              },
                                              controller: TextEditingController(
                                                text: snap.data![index][NoteDbHelper.coldescription],
                                              ),
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
                                            style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              updateDatabase(snap, index, title, description);
                                              Navigator.pop(context);
                                              setState(() {});
                                            },
                                            child: const Text('Save'),
                                            style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.edit),
                                color: Colors.blue,
                              ),
                              title: Text(snap.data![index][NoteDbHelper.coltittle]),
                              subtitle: Text(snap.data![index][NoteDbHelper.coldescription]),
                              trailing: Text(snap.data![index][NoteDbHelper.coldate].toString().substring(0, 10)),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: Text('No notes found.'));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 6.0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.black87,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              var title = '';
              var description = '';
              return AlertDialog(
                title: const Text('Add Note', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
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
                    style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
                  ),
                  TextButton(
                    onPressed: () {
                      if (title.isNotEmpty && description.isNotEmpty) {
                        insertDatabase(title, description);
                        Navigator.pop(context);
                        setState(() {});
                      }
                    },
                    child: const Text('Save'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
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
