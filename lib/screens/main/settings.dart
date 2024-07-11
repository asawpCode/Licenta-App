import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:untitled/components/navigation.dart';
import 'package:untitled/components/textfields.dart';
import 'package:untitled/screens/start_screens/start_screen.dart';
import 'package:untitled/screens/login_register/login_or_register_page.dart';
import 'package:untitled/features/friends/friends_list.dart';
import 'package:untitled/features/meditation/meditation_history.dart';
import 'package:untitled/features/progress/progress_screen.dart';
import 'package:untitled/services/check_username.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _fetchPendingRequestCount();
  }

  Future<void> _fetchPendingRequestCount() async {
    int count = await _getPendingRequestCount();
    setState(() {});
  }

  Future<int> _getPendingRequestCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('receiver_id', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .get();

      return requestsSnapshot.docs.length;
    }
    return 0;
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginOrRegisterPage()),
          (route) => false,
        );
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Ai fost delogat.')),
        );
      }
    } catch (e) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Delogarea nu a functionat: $e')),
      );
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmare Ștergere Cont'),
          content: const Text(
              'Ești sigur că vrei să ștergi contul? Aceasta acțiune nu poate fi anulată.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Anulare'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Ștergere'),
              onPressed: () async {
                Navigator.of(context).pop();
                _deleteAccount();
                await Future.delayed(const Duration(seconds: 1));
                _signOut();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final firestore = FirebaseFirestore.instance;

      try {
        final WriteBatch batch = firestore.batch();

        var requestsSnapshot = await firestore
            .collection('friend_requests')
            .where('sender_id', isEqualTo: user.uid)
            .get();
        for (var doc in requestsSnapshot.docs) {
          batch.delete(doc.reference);
        }

        requestsSnapshot = await firestore
            .collection('friend_requests')
            .where('receiver_id', isEqualTo: user.uid)
            .get();
        for (var doc in requestsSnapshot.docs) {
          batch.delete(doc.reference);
        }

        var friendsSnapshot = await firestore
            .collection('users')
            .doc(user.uid)
            .collection('friends')
            .get();
        for (var doc in friendsSnapshot.docs) {
          final friendId = doc.id;

          batch.delete(doc.reference);

          final friendRef = firestore
              .collection('users')
              .doc(friendId)
              .collection('friends')
              .doc(user.uid);
          batch.delete(friendRef);
        }

        await batch.commit();

        await firestore.collection('users').doc(user.uid).delete();

        await user.delete();

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const StartScreen()),
            (route) => false,
          );
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(content: Text('Cont șters cu succes.')),
          );
        }
      } catch (e) {
        if (mounted) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text('Ștergerea contului nu a funcționat: $e')),
          );
        }
      }
    }
  }

  void _ChangeUsername() {
    final TextEditingController _newNameController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Schimbă numele de utilizator'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: _newNameController,
                    hintText: "Nume de utilizator",
                    style: const TextStyle(),
                    obscureText: false,
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Anulare'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Salvare'),
                  onPressed: () async {
                    if (_newNameController.text.isNotEmpty) {
                      bool result =
                          await _saveUsername(_newNameController.text);
                      if (result) {
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          errorMessage =
                              'Numele de utilizator este deja folosit.';
                        });
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _saveUsername(String username) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final usernameService = UsernameService();
      final isUsernameTaken = await usernameService.isUsernameTaken(username);
      if (isUsernameTaken) {
        return false;
      }

      final oldUsername = user.displayName;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'name': username});

      user.updateDisplayName(username);

      final friendsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .get();

      for (var friendDoc in friendsSnapshot.docs) {
        final friendId = friendDoc.id;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .collection('friends')
            .doc(user.uid)
            .update({'name': username});
      }

      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      body: Stack(
        children: [
          Lottie.asset(
            'android/assets/videos/bg4.json',
            width: double.infinity,
            height: double.infinity,
            repeat: true,
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              const SizedBox(height: 110),
              Padding(
                padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.7),
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Setări',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Stack(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.people,
                              color: Color.fromARGB(255, 27, 113, 241)),
                          title: const Text(
                            'Prieteni',
                            style: TextStyle(fontSize: 18),
                          ),
                          trailing: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('friend_requests')
                                .where('receiver_id',
                                    isEqualTo:
                                        FirebaseAuth.instance.currentUser?.uid)
                                .where('status', isEqualTo: 'pending')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox();
                              }

                              final int requestCount =
                                  snapshot.data?.docs.length ?? 0;

                              if (requestCount == 0) {
                                return const SizedBox();
                              }

                              return CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.blue,
                                child: Text(
                                  requestCount > 50
                                      ? '50+'
                                      : requestCount.toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FriendsListPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    ListTile(
                      leading: const Icon(Icons.grade,
                          color: Color.fromARGB(255, 69, 70, 29)),
                      title: const Text(
                        'Progres',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProgressionScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.book,
                          color: Color.fromARGB(255, 112, 76, 34)),
                      title: const Text(
                        'Jurnal',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MeditationHistoryPage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit,
                          color: Color.fromARGB(255, 55, 66, 87)),
                      title: const Text(
                        'Schimbă numele de utilizator',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: _ChangeUsername,
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete,
                          color: Color.fromARGB(255, 241, 0, 0)),
                      title: const Text(
                        'Ștergere cont',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: _confirmDeleteAccount,
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout,
                          color: Color.fromARGB(255, 0, 0, 0)),
                      title: const Text(
                        'Delogare',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: _signOut,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavigationBar(
              onItemSelected: (int value) {},
              currentIndex: 3,
            ),
          ),
        ],
      ),
    );
  }
}
