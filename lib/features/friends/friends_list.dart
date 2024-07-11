import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/features/friends/friend_points.dart';
import 'package:percent_indicator/percent_indicator.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _usernameController.text.isEmpty) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> _friendsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .snapshots()
          .asyncMap((snapshot) async {
        List<Map<String, dynamic>> tempFriendsList = [];
        for (var doc in snapshot.docs) {
          final friendData = await FirebaseFirestore.instance
              .collection('users')
              .doc(doc.id)
              .get();
          if (friendData.exists) {
            tempFriendsList.add({
              'uid': doc.id,
              'name': friendData['name'],
              'streak': friendData.data()?['meditation_streak'] ?? 0,
            });
          }
        }
        return tempFriendsList;
      });
    } else {
      return Stream.value([]);
    }
  }

  Stream<List<Map<String, dynamic>>> _friendRequestsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('friend_requests')
          .where('receiver_id', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'sender_id': doc['sender_id'],
            'sender_name': doc['sender_name'] ?? 'Necunoscut',
          };
        }).toList();
      });
    } else {
      return Stream.value([]);
    }
  }

  Future<void> _sendFriendRequest(String username) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final currentUserSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final currentUserName = currentUserSnapshot.data()?['name'];

        if (username == currentUserName) {
          setState(() {
            _errorMessage = 'Nu te poți adăuga pe tine însuți ca prieten.';
          });
          return;
        }

        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('name', isEqualTo: username)
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          final receiverId = userSnapshot.docs.first.id;
          final receiverName = userSnapshot.docs.first['name'];

          final existingRequestSnapshot = await FirebaseFirestore.instance
              .collection('friend_requests')
              .where('sender_id', isEqualTo: user.uid)
              .where('receiver_id', isEqualTo: receiverId)
              .get();

          if (existingRequestSnapshot.docs.isNotEmpty) {
            final existingRequest = existingRequestSnapshot.docs.first;
            final status = existingRequest['status'];
            if (status == 'pending') {
              setState(() {
                _errorMessage = 'Cererea de prietenie a fost deja trimisă.';
              });
              return;
            } else if (status == 'accepted') {
              setState(() {
                _errorMessage = 'Sunteți deja prieteni.';
              });
              return;
            }
          }

          final friendSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('friends')
              .doc(receiverId)
              .get();

          if (friendSnapshot.exists) {
            setState(() {
              _errorMessage = 'Sunteți deja prieteni.';
            });
            return;
          }

          final reverseRequestSnapshot = await FirebaseFirestore.instance
              .collection('friend_requests')
              .where('sender_id', isEqualTo: receiverId)
              .where('receiver_id', isEqualTo: user.uid)
              .get();

          if (reverseRequestSnapshot.docs.isNotEmpty) {
            final reverseRequest = reverseRequestSnapshot.docs.first;
            final status = reverseRequest['status'];
            if (status == 'pending') {
              setState(() {
                _errorMessage =
                    'Ai primit deja o cerere de prietenie de la acest utilizator.';
              });
              return;
            } else if (status == 'accepted') {
              setState(() {
                _errorMessage = 'Sunteți deja prieteni.';
              });
              return;
            }
          }

          final senderSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (senderSnapshot.exists) {
            final senderName = senderSnapshot['name'] ?? 'Fără Nume';

            await FirebaseFirestore.instance.collection('friend_requests').add({
              'sender_id': user.uid,
              'sender_name': senderName,
              'receiver_id': receiverId,
              'receiver_name': receiverName,
              'status': 'pending',
            });

            setState(() {
              _errorMessage = 'Cererea de prietenie a fost trimisă!';
            });
          } else {
            setState(() {
              _errorMessage = 'Expeditorul nu a fost găsit';
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Utilizatorul nu a fost găsit';
          });
        }
      }
    } catch (e) {
      print('Eroare la trimiterea cererii de prietenie: $e');
      setState(() {
        _errorMessage =
            'Eroare la trimiterea cererii de prietenie. Vă rugăm să încercați din nou.';
      });
    }
  }

  Future<void> _acceptFriendRequest(
      String requestId, String senderId, String senderName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('friend_requests')
            .doc(requestId)
            .update({'status': 'accepted'});

        final currentUserSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final currentUserName =
            currentUserSnapshot.data()?['name'] ?? 'Fără Nume';

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('friends')
            .doc(senderId)
            .set({'uid': senderId, 'name': senderName});

        await FirebaseFirestore.instance
            .collection('users')
            .doc(senderId)
            .collection('friends')
            .doc(user.uid)
            .set({'uid': user.uid, 'name': currentUserName});

        setState(() {
          _errorMessage = 'Cererea de prietenie a fost acceptată!';
        });
      }
    } catch (e) {
      print('Eroare la acceptarea cererii de prietenie: $e');
      setState(() {
        _errorMessage =
            'Eroare la acceptarea cererii de prietenie. Vă rugăm să încercați din nou.';
      });
    }
  }

  Future<void> _declineFriendRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('friend_requests')
          .doc(requestId)
          .update({'status': 'declined'});

      setState(() {
        _errorMessage = 'Cererea de prietenie a fost refuzată!';
      });
    } catch (e) {
      print('Eroare la refuzarea cererii de prietenie: $e');
      setState(() {
        _errorMessage =
            'Eroare la refuzarea cererii de prietenie. Vă rugăm să încercați din nou.';
      });
    }
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

  Future<void> _showFriendPoints(String friendUid) async {
    try {
      final friendPoints = await UserPointsService().getUserPoints(friendUid);
      const int maxPoints = 160;

      double progressPercentage = friendPoints / maxPoints;
      if (progressPercentage > 1.0) {
        progressPercentage = 1.0;
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Center(
              child: Text(
                'NIVEL',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularPercentIndicator(
                  radius: 120.0,
                  lineWidth: 15.0,
                  animation: true,
                  percent: progressPercentage,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$friendPoints',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const Text(
                        'Puncte',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.blueAccent,
                  backgroundColor: Colors.blue.shade100,
                ),
                const SizedBox(height: 20),
                Text(
                  'Nivel: ${_getLevel(friendPoints)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Eroare la preluarea punctelor prietenului: $e');
    }
  }

  String _getLevel(int points) {
    if (points <= 20) {
      return 'Începător';
    } else if (points <= 81) {
      return 'Cunoscător';
    } else if (points <= 160) {
      return 'Avansat';
    } else {
      return 'PRO';
    }
  }

  Future<void> _unfriend(String friendId, String friendName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('friends')
            .doc(friendId)
            .delete();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .collection('friends')
            .doc(user.uid)
            .delete();

        final requestsSnapshot = await FirebaseFirestore.instance
            .collection('friend_requests')
            .where('sender_id', isEqualTo: user.uid)
            .where('receiver_id', isEqualTo: friendId)
            .get();

        for (var doc in requestsSnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('friend_requests')
              .doc(doc.id)
              .delete();
        }

        final requestsSnapshotReverse = await FirebaseFirestore.instance
            .collection('friend_requests')
            .where('sender_id', isEqualTo: friendId)
            .where('receiver_id', isEqualTo: user.uid)
            .get();

        for (var doc in requestsSnapshotReverse.docs) {
          await FirebaseFirestore.instance
              .collection('friend_requests')
              .doc(doc.id)
              .delete();
        }

        setState(() {
          _errorMessage = 'Ai șters prietenul $friendName';
        });
      }
    } catch (e) {
      print('Eroare la ștergerea prietenului: $e');
      setState(() {
        _errorMessage =
            'Eroare la ștergerea prietenului. Vă rugăm să încercați din nou.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Prieteni',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
            shadows: [],
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent.withOpacity(0.6),
                    Colors.lightBlueAccent.withOpacity(0.6)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: _focusNode.hasFocus ? '' : 'Caută un prieten',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onTap: () {
                      setState(() {
                        _focusNode.requestFocus();
                      });
                    },
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _errorMessage!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 14.0),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            top: 140,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Lista de prieteni',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _friendsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('Nu ai încă prieteni adăugați.'));
                      }
                      return Column(
                        children: snapshot.data!
                            .map((friend) => ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blueAccent,
                                    child: Text(
                                      friend['name'][0].toUpperCase(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(friend['name']),
                                  subtitle:
                                      Text('Streak: ${friend['streak']} zile',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          )),
                                  onTap: () => _showFriendPoints(friend['uid']),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    onPressed: () => _unfriend(
                                        friend['uid'], friend['name']),
                                  ),
                                ))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Cererile de prietenie',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _friendRequestsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('Momentan nu ai cereri de prietenie.'));
                      }
                      return Column(
                        children: snapshot.data!
                            .map((request) => ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blueAccent,
                                    child: Text(
                                      request['sender_name'][0].toUpperCase(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(request['sender_name']),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check,
                                            color: Colors.green),
                                        onPressed: () => _acceptFriendRequest(
                                            request['id'],
                                            request['sender_id'],
                                            request['sender_name']),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.red),
                                        onPressed: () => _declineFriendRequest(
                                            request['id']),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _sendFriendRequest(_usernameController.text),
        child: const Icon(Icons.person_add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
