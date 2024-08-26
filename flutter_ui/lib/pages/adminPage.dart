import 'package:flutter/material.dart';
import 'package:flutter_ui/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class Group {
  late String name;
  late String adminEmail;
  late List<String> members;
}

class _AdminPageState extends State<AdminPage> {
  List<Group> groups = [];

  Future<List<Group>> fetchGroups() async {
    var headers = {
      'Content-Type': 'application/json',
      'email': email,
    };
    debugPrint("headers: $headers");

    final response =
        await http.get(Uri.parse('$basePath/group'), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) {
        return Group()
          ..name = e['group_name']
          ..members = List<String>.from(e['user_emails']);
      }).toList();
    } else {
      debugPrint('Error Fetching Groups');
      return [];
    }
  }

  void addUser(String user, String password) async {
    //TODO: Add user to group via API call
    //Make sure current user is an admin
    http
        .post(
      Uri.parse('$basePath/group/add-user'),
      body: json.encode({
        'group_name': currentGroup?.name,
        'admin_email': email,
        'user_email': user,
        'admin_password': password,
      }),
    )
        .then((response) {
      if (response.statusCode == 200) {
        debugPrint('User Added');
      } else {
        debugPrint('Error Adding User');
      }
    });
    setState(() {
      currentGroup?.members.add(user);
    });
  }

  void removeUser(String user, String password) async {
    //TODO: Remove user from group via API call
    //Make sure current user is an admin
    http
        .delete(
      Uri.parse('$basePath/group/remove-user'),
      body: json.encode({
        'group_name': currentGroup?.name,
        'admin_email': email,
        'user_email': user,
        'admin_password': password,
      }),
    )
        .then((response) {
      if (response.statusCode == 200) {
        debugPrint('User Removed');
      } else {
        debugPrint('Error Removing User');
      }
    });

    setState(() {
      currentGroup?.members.remove(user);
    });
  }

  void createGroup(String user, String password) async {
    //TODO: Remove user from group via API call
    //Make sure current user is an admin
    http
        .delete(
      Uri.parse('$basePath/group/remove-user'),
      body: json.encode({
        'group_name': currentGroup?.name,
        'admin_email': email,
        'user_email': user,
        'admin_password': password,
      }),
    )
        .then((response) {
      if (response.statusCode == 200) {
        debugPrint('User Removed');
      } else {
        debugPrint('Error Removing User');
      }
    });

    setState(() {
      currentGroup?.members.remove(user);
    });
  }

  void deleteGroup(String user, String password) async {
    //TODO: Remove user from group via API call
    //Make sure current user is an admin
    http
        .delete(
      Uri.parse('$basePath/group'),
      body: json.encode({
        'group_name': currentGroup?.name,
        'admin_email': email,
        'admin_password': password,
      }),
    )
        .then((response) {
      if (response.statusCode == 200) {
        debugPrint('Group Removed');
      } else {
        debugPrint('Error Removing Group');
      }
    });

    groups.remove(currentGroup);

    setState(() {
      currentGroup = groups.isNotEmpty ? groups[0] : null;
    });
  }

  Group? currentGroup;

  @override
  Widget build(BuildContext context) {
    debugPrint("buildGroups $groups");
    if (email == '') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Page'),
        ),
        body: const Center(
          child: Text('Please login to view this page'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
        leading: Builder(
          builder: (BuildContext context) {
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  tooltip: 'Back',
                ),
                const Spacer(),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.plus_one),
            onPressed: () {
              _dialogBuilder(context);
            },
            tooltip: 'Add a new Group',
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              _removeGroup(context);
            },
            tooltip: 'Remove Group',
          ),
        ],
      ),
      body: FutureBuilder<List<Group>>(
        future: fetchGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching groups'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                children: [
                  const Text('No groups available. Create one?'),
                  FloatingActionButton(
                    onPressed: () {
                      _dialogBuilder(context);
                    },
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            );
          } else {
            final groups = snapshot.data!;
            currentGroup ??= groups.isNotEmpty ? groups[0] : null;

            return Column(
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
                    itemCount: currentGroup?.members.length ?? 0,
                    itemBuilder: (context, index) {
                      final user = currentGroup?.members[index];
                      if (user == null) {
                        return const SizedBox();
                      }
                      return ListTile(
                        title: Text(user),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                String password = '';
                                return AlertDialog(
                                  title: const Text('Confirm User Removal'),
                                  content: Column(
                                    children: [
                                      TextField(
                                        onChanged: (value) {
                                          password = value;
                                        },
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          labelText: 'Admin Password',
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Remove'),
                                      onPressed: () {
                                        removeUser(user, password);
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
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String newUser = '';
              String password = '';
              return AlertDialog(
                title: const Text('Add User'),
                content: Column(
                  children: [
                    TextField(
                      onChanged: (value) {
                        newUser = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'New User Email',
                      ),
                    ),
                    TextField(
                      onChanged: (value) {
                        password = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Your Password',
                      ),
                    ),
                  ],
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
                      addUser(newUser, password);
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

  Future<void> _dialogBuilder(BuildContext context) {
    final nameController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create A New Group'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Group Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Submit'),
              onPressed: () {
                http
                    .post(
                  Uri.parse('$basePath/group'),
                  body: json.encode({
                    'group_name': nameController.text,
                    'admin_email': email,
                  }),
                )
                    .then((response) {
                  if (response.statusCode == 200) {
                    debugPrint('Group Created');
                    setState(() {
                      groups.add(Group()
                        ..name = nameController.text
                        ..adminEmail = email
                        ..members = [email]);
                    });
                  } else {
                    debugPrint('Error Creating Group');
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeGroup(BuildContext context) {
    final passwordController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Removing group ${currentGroup?.name}'),
          content: TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Confirm Using your Password',
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Submit'),
              onPressed: () {
                deleteGroup(email, passwordController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
