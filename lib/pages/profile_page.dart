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

class AchievementData {
  AchievementData({required this.name, required this.imagePath, required this.icon});
  final String name;
  final String imagePath;
  final IconData icon;
}

class _ProfilePageState extends State<ProfilePage> {
  String? user_email = FirebaseAuth.instance.currentUser!.email;
  String? username = FirebaseAuth.instance.currentUser!.displayName;

  final Map<String, AchievementData> achievements = {
    "STARTER": AchievementData(name: "Starter", imagePath: "lvl1_true.png", icon: Icons.keyboard_double_arrow_up),
    "THE_JOURNEY": AchievementData(name: "The Journey", imagePath: "lvl2_false.png", icon: Icons.keyboard_double_arrow_up),
    "HI_FOLKS": AchievementData(name: "Hi Folks!", imagePath: "lvl1_false.png", icon: Icons.calendar_month),
    "REGULAR": AchievementData(name: "Regular", imagePath: "lvl2_false.png", icon: Icons.calendar_month),
    "PROFESSIONAL_SOCIALIZER": AchievementData(name: "Professional Socializer", imagePath: "lvl3_false.png", icon: Icons.calendar_month),
    "HOST": AchievementData(name: "Host", imagePath: "lvl1_false.png", icon: Icons.cottage),
    "ORGANIZING_TALENT": AchievementData(name: "Organizing Talent", imagePath: "lvl2_false.png", icon: Icons.cottage),
    "BARTENDER": AchievementData(name: "Bartender", imagePath: "lvl3_false.png", icon: Icons.cottage),
    "LOCAL_HERO": AchievementData(name: "Local Hero", imagePath: "lvl4_false.png", icon: Icons.cottage),
    "ON_FIRE": AchievementData(name: "On FIRE", imagePath: "lvl1_false.png", icon: Icons.local_fire_department),
    "UNSTOPPABLE": AchievementData(name: "UNSTOPPABLE", imagePath: "lvl2_false.png", icon: Icons.local_fire_department),
    "VERIFIED": AchievementData(name: "Verified", imagePath: "lvl4_false.png", icon: Icons.verified_user),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

            const Text("Achievements", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
            SizedBox(height: 16),

            Expanded(
              child:
              GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 columns
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ), itemCount: achievements.keys.length, itemBuilder: (context, index) {
              final achievement = achievements[achievements.keys.elementAt(index)]!;
              return Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background image
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/img/${achievement.imagePath}"),
                            fit: BoxFit.cover,
                          ),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      // Overlay icon
                      Icon(
                        achievement.icon,
                        size: 52,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Achievement name
                  Text(
                    achievement.name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
            ))
            // Weitere Details
          ],
        ),
      ),
    );
  }
}
