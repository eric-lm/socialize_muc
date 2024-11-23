import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key, required this.title});

  final String title;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? user_email = FirebaseAuth.instance.currentUser!.email;
  String? username = FirebaseAuth.instance.currentUser!.displayName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profilbild
            CircleAvatar(
                radius: 50,
                child: Icon(
                  Icons.person,
                  size: 80,
                )
                //backgroundImage:b AssetImage('assets/profile_picture.jpg'),
                ),
            SizedBox(height: 16),

            // Name
            Text(
              username ?? 'anonymous',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // E-Mail
            Text(
              user_email != null ? user_email! : 'anonymous',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Edit Profile'),
                ),
                SizedBox(width: 16),
                SignOutButton(),
              ],
            ),
            SizedBox(height: 32),

            // Weitere Details
          ],
        ),
      ),
    );
  }
}
