import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialize/models/event.dart';

class EventCreationPage extends StatefulWidget {
  @override
  _EventCreationPageState createState() => _EventCreationPageState();
}

class _EventCreationPageState extends State<EventCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int _maxParticipants = 0;
  List<String> _tags = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Event")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Event Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Date field
              ListTile(
                title: Text(
                    "Event Date: ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year} at ${_selectedDate.hour}:${_selectedDate.minute < 10 ? "0${_selectedDate.minute}" : _selectedDate.minute}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != _selectedDate) {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: _selectedDate.hour,
                          minute: _selectedDate.minute),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
              ),
              SizedBox(height: 16),

              // Place field
              TextFormField(
                controller: _placeController,
                decoration: InputDecoration(labelText: 'Event Place'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a place';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 16),

              // Max Participants field
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Max Participants'),
                onChanged: (value) {
                  setState(() {
                    _maxParticipants = int.tryParse(value) ?? 0;
                  });
                },
              ),
              SizedBox(height: 16),

              // Tags field
              TextFormField(
                controller: _tagsController,
                decoration:
                    InputDecoration(labelText: 'Tags (comma separated)'),
                onChanged: (value) {
                  setState(() {
                    _tags = value.split(',').map((tag) => tag.trim()).toList();
                  });
                },
              ),
              SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final event = Event(
                        id: '',
                        // Will be auto-generated by Firestore
                        title: _titleController.text,
                        time: _selectedDate,
                        place: _placeController.text,
                        organizer: FirebaseFirestore.instance
                            .collection('user')
                            .doc(user.uid),
                        numParticipants: 0,
                        maxParticipants: _maxParticipants,
                        description: _descriptionController.text,
                        tags: _tags,
                      );

                      try {
                        // Add event to Firestore
                        print(event.toFirestore().toString());
                        await FirebaseFirestore.instance
                            .collection('event')
                            .add(event.toFirestore());
                        Navigator.pop(context);
                      } catch (e) {
                        print("Error creating event: $e");
                      }
                    }
                  }
                },
                child: Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
