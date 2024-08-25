import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class Group {
  late String name;
  late List<String> admins;
  late List<String> members;
}

class _AdminPageState extends State<AdminPage> {
  //TODO: Initialize the groups list with a API call
  List<Group> groups = [
    Group()
      ..name = 'Group 1'
      ..admins = ['Admin 1', 'Admin 2']
      ..members = ['Member 1', 'Member 2'],
    Group()
      ..name = 'Group 2'
      ..admins = ['Admin 3', 'Admin 4']
      ..members = ['Member 3', 'Member 4'],
  ];

  Group? currentGroup;

  @override
  void initState() {
    super.initState();
    currentGroup = groups.isNotEmpty ? groups[0] : null;
  }

  void addUser(String user) {
    //TODO: Add user to group via API call
    //Make sure current user is an admin
    setState(() {
      currentGroup?.members.add(user);
    });
  }

  void removeUser(String user) {
    //TODO: Remove user from group via API call
    //Make sure current user is an admin
    setState(() {
      currentGroup?.members.remove(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
      ),
      body: Container(
        child: Column(
          children: [
            DropdownMenu<Group>(
              label: const Text('Select Available Data'),
              onSelected: (Group? value) {
                if (value != null) {
                  debugPrint('Data: $value');
                  setState(() {
                    currentGroup = value;
                  });
                }
              },
              dropdownMenuEntries: [
                for (Group group in groups)
                  DropdownMenuEntry<Group>(
                    value: group,
                    label: group.name,
                  )
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: currentGroup?.members.length,
                itemBuilder: (context, index) {
                  final user = currentGroup?.members[index];
                  return ListTile(
                    title: Text(user!),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => removeUser(user),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String newUser = '';
              return AlertDialog(
                title: Text('Add User'),
                content: TextField(
                  onChanged: (value) {
                    newUser = value;
                  },
                ),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Add'),
                    onPressed: () {
                      addUser(newUser);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
