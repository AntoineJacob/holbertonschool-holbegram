import 'package:flutter/material.dart';
import 'package:holbegram/widgets/text_field.dart';
import 'login_screen.dart';
import 'upload_image_screen.dart';

// Classe pour l'écran d'inscription
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

// Classe State associée au widget SignUpScreen
class SignUpScreenState extends State<SignUpScreen> {
  // Déclaration des contrôleurs pour gérer les entrées utilisateur
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();
  bool _passwordVisible = true;

  // Libère les ressources des contrôleurs lorsqu'ils ne sont plus nécessaires
  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  // Initialise l'état du widget
  @override
  void initState() {
    super.initState();
    _passwordVisible = true;
  }

  // Vérifie si les champs ne sont pas vides avant de naviguer vers AddPicture
  void navigateToAddPicture() {
    if (emailController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        passwordConfirmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    } else if (passwordController.text != passwordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPicture(
            email: emailController.text,
            username: usernameController.text,
            password: passwordController.text,
          ),
        ),
      );
    }
  }

  // Construire l'interface utilisateur
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
            child: Column(
              children: <Widget>[
                SizedBox(height: screenHeight * 0.06),

                // Affiche le texte et le logo de l'application
                Text(
                  'Holbegram',
                  style: TextStyle(
                    fontFamily: 'Billabong',
                    fontSize: screenHeight * 0.08,
                  ),
                ),
                Image.asset(
                  'assets/images/logo.png',
                  width: screenWidth * 0.2,
                  height: screenHeight * 0.08,
                ),
                SizedBox(height: screenHeight * 0.05),

                // Affiche le texte d'invitation à s'inscrire
                Text(
                  'Sign up to see photos and videos\nfrom your friends.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenHeight * 0.02,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),

                // Affiche les champs de saisie pour l'inscription
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    children: <Widget>[
                      TextFieldInput(
                        controller: emailController,
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      TextFieldInput(
                        controller: usernameController,
                        hintText: 'Username',
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      TextFieldInput(
                        controller: passwordController,
                        isPassword: !_passwordVisible,
                        hintText: 'Password',
                        keyboardType: TextInputType.visiblePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: const Color.fromARGB(218, 226, 37, 24),
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // Affiche le champ de confirmation du mot de passe
                      TextFieldInput(
                        controller: passwordConfirmController,
                        isPassword: !_passwordVisible,
                        hintText: 'Confirm Password',
                        keyboardType: TextInputType.visiblePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: const Color.fromARGB(218, 226, 37, 24),
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.06),

                      // Affiche le bouton d'inscription
                      SizedBox(
                        height: screenHeight * 0.06,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(218, 226, 37, 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                              side: const BorderSide(color: Colors.transparent),
                            ),
                          ),
                          onPressed: navigateToAddPicture,
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenHeight * 0.017,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      const Divider(thickness: 2),

                      // Affiche le texte pour se connecter si l'utilisateur a déjà un compte
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(
                              fontSize: screenHeight * 0.017,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(218, 226, 37, 24),
                                fontSize: screenHeight * 0.017,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}