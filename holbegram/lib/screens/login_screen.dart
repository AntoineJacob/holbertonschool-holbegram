import 'package:flutter/material.dart';
import 'package:holbegram/widgets/text_field.dart';
import 'signup_screen.dart';
import 'package:holbegram/methods/auth_methods.dart';
import 'package:holbegram/screens/home.dart';


// Classe pour l'écran de connexion
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  // Crée l'état associé au widget LoginScreen
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Classe State associée au widget LoginScreen
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = true;

  // Méthode pour libérer les ressources utilisées par le contrôleur de texte
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Méthode pour initialiser l'état du widget
  @override
  void initState() {
    super.initState();
    _passwordVisible = true;
  }

  // Méthode pour gérer la soumission du formulaire de connexion
  void loginUser() async {
    String res = await AuthMethods().login(
      email: emailController.text,
      password: passwordController.text,
    );

     // Vérifie si le widget est toujours monté
    if (!mounted) return;

    if (res == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );
      // Naviguer vers la page d'accueil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
      // Redirige l'utilisateur vers l'écran d'accueil
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          width: screenWidth,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: screenHeight * 0.01),

              // Affiche le titre et le logo de l'application
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

              // Affiche les champs de saisie pour l'email et le mot de passe
              TextFieldInput(
                controller: emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
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
              SizedBox(height: screenHeight * 0.04),

              // Affiche le bouton de connexion
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
                  onPressed: loginUser,
                  child: Text(
                    'Log In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenHeight * 0.020,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // Affiche le texte pour réinitialiser le mot de passe
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Forgot your login details? ',
                    style: TextStyle(fontSize: screenHeight * 0.017),
                  ),
                  Text(
                    'Get help signing in.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight * 0.017,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              const Divider(thickness: 2),

              // Affiche le texte pour créer un compte
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account",
                      style: TextStyle(fontSize: screenHeight * 0.017),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },

                      // Affiche le bouton pour s'inscrire
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(218, 226, 37, 24),
                          fontSize: screenHeight * 0.017,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.01),

              // Affiche le texte OR
              Row(
                children: [
                  const Flexible(
                    child: Divider(thickness: 2),
                  ),
                  Text(
                    ' OR ',
                    style: TextStyle(fontSize: screenHeight * 0.017),
                  ),
                  const Flexible(
                    child: Divider(thickness: 2),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),

              // Affiche le bouton pour se connecter avec Google
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://www.freepnglogos.com/uploads/google-logo-png/google-logo-png-webinar-optimizing-for-success-google-business-webinar-13.png',
                    width: screenWidth * 0.1,
                    height: screenHeight * 0.05,
                  ),
                  Text(
                    'Sign in with Google',
                    style: TextStyle(fontSize: screenHeight * 0.017),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}