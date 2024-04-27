import 'package:flutter/material.dart';

class ProfileSample extends StatefulWidget {
  const ProfileSample({super.key});

  @override
  State<ProfileSample> createState() => _ProfileSampleState();
}

class _ProfileSampleState extends State<ProfileSample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Form(
        child: Column(
          children: [
            Center(
                child: Text(
              "Profile",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
            )),
            CircleAvatar(
              radius: 110,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                  child: TextFormField(
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'Name',
                  label: Text("Name"),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.name,
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                  child: TextFormField(
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'Email',
                  label: Text("Email"),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                  child: TextFormField(
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  label: Text("Phone Number"),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              )),
            )
          ],
        ),
      ),
    );
  }
}
