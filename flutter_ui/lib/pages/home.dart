import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Center(
        child: middleContent(),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        'Data Sculpor',
        style: TextStyle(
          color: Colors.deepPurple,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.all(10.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: SvgPicture.asset(
          'assets/icons/Arrow - Left 2.svg',
          height: 20,
          width: 20,
        ),
      ),
      actions: [
        Container(
          color: Colors.grey[200],
          child: IconButton(
            icon: const Icon(Icons.login),
            onPressed: () {
            },
            tooltip: 'Login',
          ),
        ),
      ],
    );
  }

  Widget middleContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Welcome to Data Sculpor',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () {
            // Add your logic here
          },
          child: Text('Get Started'),
        ),
      ],
    );
  }
}
