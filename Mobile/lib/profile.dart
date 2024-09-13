import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile/base/variables.dart';
import 'package:mobile/models.dart' as models;
import 'package:shared_preferences/shared_preferences.dart';
import 'base/sidemenu.dart';
import 'services/api.dart' as api;
import 'editprofile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  models.User? userData;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    if (user != null) {
      setState(() {
        userData = user!;
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('id');

      if (id != null) {
        final response = await api
            .request(context, api.ApiService.auth, 'GET', '/api/users/$id', null);

        if (response == null) return;

        Map<String, dynamic> json = jsonDecode(response);
        models.User jsonUser = models.User.fromJson(json);

        setState(() {
          userData = jsonUser;
          user = jsonUser;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SideMenu(
      selectedIndex: 2,
      body: Stack(
        children: [
          const Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Your Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Center(
            child: userData == null
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      userData?.profilePicture != null && userData!.profilePicture.isNotEmpty ?
                      ClipOval(
                        child: Image(
                          image: NetworkImage(userData!.profilePicture),
                          height: 100,
                          width: 100, // Ensure width matches the height to make it fully round
                          fit: BoxFit.cover, // This makes sure the image fits inside the circle properly
                        ),
                      )
                      : const Icon(
                        Icons.account_circle,
                        size: 100,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        userData!.username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userData!.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.9, // 90% height
                              child: EditProfilePage(userData: user),
                            );
                          },
                        );
                      },
                      child: const Text('Edit'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
