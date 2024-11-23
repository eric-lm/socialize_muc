import 'package:flutter/material.dart';

class JournalPage extends StatefulWidget {
  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  List<Map<String, String>> journals = [];

  void _openJournalDialog({int? index}) {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    // Populate fields if editing
    if (index != null) {
      titleController.text = journals[index]['title']!;
      contentController.text = journals[index]['content']!;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'New Journal' : 'Edit Journal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (index == null) {
                  // Add new journal
                  journals.add({
                    'title': titleController.text,
                    'content': contentController.text,
                  });
                } else {
                  // Update existing journal
                  journals[index] = {
                    'title': titleController.text,
                    'content': contentController.text,
                  };
                }
              });
              Navigator.pop(context);
            },
            child: Text(index == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journaling'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: journals.length,
        itemBuilder: (context, index) => Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(journals[index]['title']!),
            subtitle: Text(
              journals[index]['content']!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _openJournalDialog(index: index),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  journals.removeAt(index);
                });
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openJournalDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: JournalPage(),
    ));
