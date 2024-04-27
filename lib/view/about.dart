import 'package:flutter/material.dart';

class AboutSample extends StatefulWidget {
  const AboutSample({super.key});

  @override
  State<AboutSample> createState() => _AboutSampleState();
}

class _AboutSampleState extends State<AboutSample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
      ),
    );
  }
}
