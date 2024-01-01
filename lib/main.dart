import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
void main() {
  runApp(GymApp());
}

class GymApp extends StatelessWidget {
  final List<Map<String, dynamic>> users = [];

   GymApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gym App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        AdminPage.routeName: (context) => AdminPage(users: users), // Pass the users list to AdminPage
        RegisterUserPage.routeName: (context) => RegisterUserPage(usersList: users),
        UserListPage.routeName: (context) => UserListPage(users: users), // Pass the users list to UserListPage
        LoginPage.routeName: (context) => LoginPage(users: users), // Pass the users list to LoginPage
      },
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AdminPage.routeName);
              },
              child: const Text('Admin Page'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, LoginPage.routeName);
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  static const routeName = '/admin';

  final List<Map<String, dynamic>> users;

  const AdminPage({super.key, required this.users}); // Receive the users list as a parameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Admin Page'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, RegisterUserPage.routeName);
              },
              child: const Text('Register User'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, UserListPage.routeName);
              },
              child: const Text('Delete User'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterUserPage extends StatefulWidget {
  static const routeName = '/register';

  final List<Map<String, dynamic>> usersList;

  const RegisterUserPage({super.key, required this.usersList}); // Receive the users list as a parameter

  @override
  _RegisterUserPageState createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  String username = '';
  String password = '';
  String number = '';
  int monthlyTime = 0;

  Future<void> registerUser() async {
    final url = Uri.parse('https://123-project.000webhostapp.com/addusers.php');
    final response = await http.post(
      url,
      body: {
        'username': username,
        'password': password,
        'number': number,
        'monthlyTime': monthlyTime.toString(),
      },
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.cyan,
          title: Text('Success'),
          content: Text('User registered successfully'),
        ),
      ).then((value) {
        setState(() {
          username = '';
          password = '';
          number = '';
          monthlyTime = 0;
        });
      });
      print('User registered successfully');
    } else {
      throw Exception('Failed to register user. Error: ${response.statusCode}');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
              onChanged: (value) {
                setState(() {
                  username = value;
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Number',
              ),
              onChanged: (value) {
                setState(() {
                  number = value;
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Monthly Time',
              ),
              onChanged: (value) {
                setState(() {
                  monthlyTime = int.tryParse(value) ?? 0;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                registerUser();

              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserListPage extends StatefulWidget {
  static const routeName = '/userList';

  final List<Map<String, dynamic>> users;
  const UserListPage({super.key, required this.users}); // Receive the users list as a parameter

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<String> selectedUsers = [];
  TextEditingController monthlyTimeController = TextEditingController();
  List<Map<String, dynamic>> users = [];
  @override
  void initState() {
    super.initState();
    fetchUsers();
  }
  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('https://123-project.000webhostapp.com/getusers.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          users = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> updateUserMonthlyTime(String user, int newMonthlyTime) async {
    try {
      const url = 'https://123-project.000webhostapp.com/updatemonthlytime.php';      final response = await http.post(Uri.parse(url), body: {
        'action': 'updateMonthlyTime',
        'username': user,
        'monthlyTime': newMonthlyTime.toString(),
      });

      if (response.statusCode == 200) {
        // Update the local users list with the updated monthly time
        setState(() {
          final userObject = users.firstWhere((u) => u['username'] == user);
          userObject['monthlyTime'] = newMonthlyTime;
        });
      } else {
        print('Failed to update monthly time: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteUser(String username) async {
    try {
      const url = 'https://123-project.000webhostapp.com/deleteuser.php';
      final response = await http.post(Uri.parse(url), body: {
        'action': 'deleteUser',
        'username': username,
      });
      print('Delete user request sent');
      if (response.statusCode == 200) {
        final result = response.body;
        if (result == 'User deleted successfully from the database') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.redAccent,
              title: Text('Success'),
              content: const Text('User deleted successfully'),
            ),
          ).then((value) {
            setState(() {
              users.removeWhere((user) => user['username'] == username);
            });
          });
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text('Failed to delete user: $result'),
            ),
          );
          print('Failed to delete user: $result');
        }
      } else {
        print('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index]['username'];
          final isSelected = selectedUsers.contains(user);

          return ListTile(
            title: Text(user),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedUsers.add(user);
                  } else {
                    selectedUsers.remove(user);
                  }
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Change Monthly Time'),
                  content: TextField(
                    controller: monthlyTimeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'New Monthly Time',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        monthlyTimeController.clear();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        final newMonthlyTime = int.tryParse(monthlyTimeController.text);
                        if (newMonthlyTime != null) {
                          setState(() {
                            for (final user in selectedUsers) {
                              updateUserMonthlyTime(user, newMonthlyTime);
                            }
                            selectedUsers.clear();
                            Navigator.pop(context);
                            monthlyTimeController.clear();
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Done'),
                                content: const Text('Operation completed successfully.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          });
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Invalid Monthly Time'),
                              content: const Text('Please enter a valid number for the monthly time.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Change Monthly Time',
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              setState(() async {
                for (var user in selectedUsers) {
                  await deleteUser(user);
                }
                selectedUsers.clear();
              });
            },
            tooltip: 'Delete Selected Users',
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  final List<Map<String, dynamic>> users;

  const LoginPage({Key? key, required this.users}) : super(key: key); // Receive the users list as a parameter

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username = '';
  String password = '';
  void login(String username, String password) async {
    try {
      const url = 'https://123-project.000webhostapp.com/login.php';
      final response = await http.post(Uri.parse(url), body: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final status = result['status'];
        final message = result['message'];

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: status == 'success' ? Colors.green : Colors.red,
            title: Text(status == 'success' ? 'Success' : 'Error'),
            content: Text(message),
          ),
        );
      } else {
        print('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void decrementMonthlyTime(String username) {
    final userIndex = widget.users.indexWhere((u) => u['username'] == username);
    if (userIndex != -1) {
      setState(() {
        widget.users[userIndex]['monthlyTime'] = (widget.users[userIndex]['monthlyTime'] as int? ?? 0) - 1;
      });
    }
  }

  bool validateLogin() {
    final user = widget.users.firstWhere(
          (u) => u['username'] == username && u['password'] == password,
      orElse: () => {},
    );

    if (user != {} && user['monthlyTime'] > 0) {
      return true; // Allow login if user exists and monthlyTime is greater than 0
    } else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          backgroundColor: Colors.red,
          title: Text('Error'),
          content: Text('Invalid username or password or insufficient monthly time.'),
        ),
      );
      return false; // Deny login
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
              onChanged: (value) {
                setState(() {
                  username = value;
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () => login(username, password),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}