import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fortuntella/auth_wrapper.dart';
import 'package:rive/rive.dart';
import '../repositories/firestore_user_repository.dart';
import '../services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService userService = UserService(FirestoreUserRepository());
  User? user = currentUser();
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  SMITrigger? _shakeInput;

  void _onRiveInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');
    artboard.addController(controller!);
    _shakeInput = controller.findInput<bool>('Shake') as SMITrigger;
  }

  void _shake() {
    _shakeInput?.fire();
  }

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
        userData = await userService.getUser(user!.uid);
        setState(() {
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchUserData,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24), // Provide some spacing at the top
              Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : errorMessage != null
                        ? Column(
                            children: [
                              Text(errorMessage!),
                              const SizedBox(height: 16),
                              const Text(
                                'Pull down to retry',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          )
                        : userData != null
                            ? Column(
                                children: [
                                  Text(
                                    'Welcome, ${userData!['email'] ?? 'User'}',
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(height: 24),
                                  Align(
                                    alignment: const AlignmentDirectional(0, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Container(
                                            width: 300,
                                            height: 300,
                                            decoration: const BoxDecoration(
                                              color: Color.fromRGBO(
                                                  121, 121, 188, 0.498),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SizedBox(
                                                width: 150,
                                                height: 130,
                                                child: RiveAnimation.asset(
                                                  'assets/animations/pes.riv',
                                                  artboard: 'Pes Animace',
                                                  fit: BoxFit.none,
                                                  onInit: _onRiveInit,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        FloatingActionButton(
                                          onPressed: _shake,
                                          tooltip: 'Shake',
                                          child: const Icon(Icons.animation),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            : const Text(
                                'No user data available. Pull down to refresh.'),
              ),
              const SizedBox(height: 24), // Provide some spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
