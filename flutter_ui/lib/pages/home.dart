import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_ui/pages/graphsPage.dart';
import 'package:flutter_ui/pages/login.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Center(
        child: middleContent(),
      ),
      drawer: Drawer(
        child: mainDrawer(context),
      ),
    );
  }

  ListView mainDrawer(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close)),
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.deepPurple,
          ),
          child: Text(
            'Data Sculpor',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),
          ),
        ),
        ListTile(
          title: const Text('Home'),
          onTap: () {
            // Add your logic here
          },
        ),
        ListTile(
          title: const Text('About'),
          onTap: () {
            // Add your logic here
          },
        ),
        ListTile(
          title: const Text('Contact'),
          onTap: () {
            // Add your logic here
          },
        ),
                ListTile(
          title: const Text('Graphs'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GraphsPage()));
          },
        ),
      ],
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
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: 'Menu',
          );
        },
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0),
            color: Colors.grey[200],
          ),
          child: Builder(builder: (context) {
            return IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              },
              tooltip: 'Login',
            );
          }),
        ),
      ],
    );
  }

  Widget middleContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Welcome to Data Sculptor',
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
