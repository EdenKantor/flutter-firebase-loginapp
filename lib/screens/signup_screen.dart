import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logionapp/main.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  String _email = '';
  String _password = '';

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final RegExp _emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
  final RegExp _passwordRegex =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&^()_\-+=]).+$');

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    IconData? icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  String? _validatePasswordRules(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (!_passwordRegex.hasMatch(value)) {
      return 'Password must include letter, number and symbol';
    }
    return null;
  }

  void _showPasswordRequirements() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Password Requirements'),
        content: const Text(
          'Password must contain at least:\n'
          '- one letter\n'
          '- one number\n'
          '- one symbol',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signup Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password sign-up is disabled in Firebase Console.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Sign-up failed.';
    }
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      if (_passwordController.text.isNotEmpty &&
          !_passwordRegex.hasMatch(_passwordController.text)) {
        _showPasswordRequirements();
      }
      return;
    }
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      // 1) Create the user in Firebase Authentication.
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.trim(),
        password: _password,
      );

      // 2) Set the displayName on the auth profile.
      await cred.user?.updateDisplayName(_fullName);

      // 3) Persist additional profile fields in Firestore (users/{uid}).
      //    Best-effort: the account already exists in Firebase Auth (step 1),
      //    and the rest of the app (Profile/Settings) tolerates a missing user
      //    doc. So a Firestore failure here — e.g. the database isn't enabled
      //    or security rules deny the write — must NOT block sign-up or be shown
      //    to the user as an error.
      final uid = cred.user!.uid;
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'fullName': _fullName,
          'email': _email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Signup: Firestore profile write failed (ignored): $e');
      }

      // AuthGate (in main.dart) will automatically navigate to WelcomePage
      // because the auth state stream now emits a signed-in user. We only
      // pop back to the login route so the gate can take over.
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(_mapAuthError(e));
    } catch (e) {
      if (!mounted) return;
      _showError('Unexpected error. Please try again.\n\n$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.person_add_alt_1,
                          size: 64,
                          color: kPrimaryColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          decoration: _inputDecoration(
                            label: 'Full Name',
                            icon: Icons.person_outline,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter full name';
                            }
                            return null;
                          },
                          onSaved: (value) => _fullName = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            label: 'Email',
                            icon: Icons.email_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email';
                            }
                            if (!_emailRegex.hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          onSaved: (value) => _email = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _hidePassword,
                          decoration: _inputDecoration(
                            label: 'Password',
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _hidePassword = !_hidePassword;
                                });
                              },
                            ),
                          ),
                          validator: _validatePasswordRules,
                          onSaved: (value) => _password = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _hideConfirmPassword,
                          decoration: _inputDecoration(
                            label: 'Confirm Password',
                            icon: Icons.lock_reset_outlined,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _hideConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _hideConfirmPassword =
                                      !_hideConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          onSaved: (value) {},
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signup,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Create Account'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
