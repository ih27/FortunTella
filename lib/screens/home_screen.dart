import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fortuntella/screens/fortune_tell_screen.dart';
import 'package:fortuntella/widgets/form_button.dart';

class HomeScreen extends StatefulWidget {
  final Function()? onLogout;

  const HomeScreen({this.onLogout, super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  Function()? get onLogout => widget.onLogout;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get()
            .timeout(const Duration(seconds: 10)); // Timeout after 10 seconds

        setState(() {
          userData = userDoc.data() as Map<String, dynamic>?;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to fetch user data. Please try again.';
      });
    }
  }

  // Future<void> _signOut() async {
  //   await FirebaseAuth.instance.signOut();
  //   // After sign out, navigate back to login screen
  //   if (!mounted) return;
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => const AuthWrapper()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUserData,
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : errorMessage != null
                  ? ListView(
                      children: [
                        Center(child: Text(errorMessage!)),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            'Pull down to retry',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      children: [
                        Center(
                          child: Text('Welcome, ${userData!['email']}'),
                        ),
                        const SizedBox(height: 24),
                        FormButton(
                          text: '🚶‍➡️ 🚪 => 🔮',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const FortuneTellScreen()),
                            );
                          }
                        )
                      ],
                    ),
        ),
      ),
    );
  }
}
