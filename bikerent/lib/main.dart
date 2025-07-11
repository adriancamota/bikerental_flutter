import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:file_picker/file_picker.dart';
import 'user_storage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Bike Rental',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _isNotRobot = false;
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final user = await UserStorage().authenticate(email, password);
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    if (user != null) {
      // Check user role and route accordingly
      final userRole = user['role'] ?? 'user';
      if (userRole == 'admin' || userRole == 'manager') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomePage(userEmail: user['email'])),
          (route) => false,
        );
      }
    } else {
      // Check if user exists
      final exists = await UserStorage().emailExists(email);
      setState(() {
        if (exists) {
          _errorMessage = 'Incorrect password.';
        } else {
          _errorMessage = 'No account found for this email.';
        }
        _passwordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with opacity
          Opacity(
            opacity: 0.2,
            child: Image.asset('assets/batangas_bg.jpg', fit: BoxFit.cover),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Banner always at the top
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              child: Image.asset(
                                'assets/spartaride.png',
                                width: double.infinity,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 32,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: AssetImage(
                                          'assets/spartan_logo.png',
                                        ),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'UNIVERSITY BIKE RENTAL',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.red,
                                            ),
                                          ),
                                          Text(
                                            'Rent. Ride. Return. Spartan-style.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Please Log In',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Email field
                                  TextField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.email_outlined),
                                      labelText: 'Email',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 16),
                                  // Password field
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.lock_outline),
                                      labelText: 'Password',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '* Password is case sensitive',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Not a robot checkbox
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _isNotRobot,
                                        onChanged: (val) {
                                          setState(() {
                                            _isNotRobot = val ?? false;
                                          });
                                        },
                                      ),
                                      const Text("I'm not a robot"),
                                      Spacer(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: const [
                                          Text(
                                            'reCAPTCHA',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            'Privacy - Terms',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Sign In button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.yellow[700],
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      onPressed: _isNotRobot && !_isLoading
                                          ? _signIn
                                          : null,
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.black,
                                              ),
                                            )
                                          : const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                    ),
                                  ),
                                  // Sign up
                                  Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: RichText(
                                        text: TextSpan(
                                          text: "Don't have an account? ",
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 13,
                                          ),
                                          children: [
                                            WidgetSpan(
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const SignUpPage(),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  'Sign Up',
                                                  style: const TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_errorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();
    final exists = await UserStorage().emailExists(email);
    if (!mounted) return;
    if (exists) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An account with this email already exists.';
      });
      return;
    }
    await UserStorage().addUser({
      'email': email,
      'password': password,
      'name': name,
      'role': 'user',
    });
    setState(() {
      _isLoading = false;
    });
    if (!mounted) return;
    Navigator.pop(context); // Go back to login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with opacity
          Opacity(
            opacity: 0.2,
            child: Image.asset('assets/batangas_bg.jpg', fit: BoxFit.cover),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Banner always at the top
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          child: Image.asset(
                            'assets/spartaride.png',
                            width: double.infinity,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Name field
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person_outline),
                                  labelText: 'Full Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.name,
                              ),
                              const SizedBox(height: 16),
                              // Email field
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email_outlined),
                                  labelText: 'Email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              // Password field
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline),
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Confirm Password field
                              TextField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline),
                                  labelText: 'Confirm Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow[700],
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: _isLoading ? null : _signUp,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.black,
                                          ),
                                        )
                                      : const Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Already have an account? Log In',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String userEmail;
  const HomePage({super.key, required this.userEmail});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showMobileAppBar = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    return Scaffold(
      key: _scaffoldKey,
      appBar: isMobile
          ? AppBar(
              backgroundColor: Colors.white.withValues(alpha: 0.95),
              elevation: 2,
              titleSpacing: 0,
              toolbarHeight: 60,
              leading: IconButton(
                icon: const Icon(Icons.menu, size: 32, color: Colors.black),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              title: null,
              actions: [],
            )
          : AppBar(
              backgroundColor: Colors.white.withValues(alpha: 0.95),
              elevation: 2,
              titleSpacing: 0,
              toolbarHeight: 70,
              leading: Padding(
                padding: const EdgeInsets.all(0),
                child: Transform.scale(
                  scale: 1.6,
                  child: Image.asset(
                    'assets/spartan_logo.png',
                    height: 48,
                    width: 48,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Stack(
                    children: [
                      Text(
                        'SPARTA',
                        style: GoogleFonts.anton(
                          fontSize: 40,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w900,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3.0
                            ..color = Colors.black,
                        ),
                      ),
                      Text(
                        'SPARTA',
                        style: GoogleFonts.anton(
                          color: const Color.fromARGB(255, 216, 14, 0),
                          fontSize: 40,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _NavBar(
                          selectedIndex: _selectedTabIndex,
                          onTabSelected: (index) {
                            setState(() {
                              _selectedTabIndex = index;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
      drawer: isMobile
          ? Drawer(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: Image.asset('assets/spartan_logo.png', height: 60),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Stack(
                        children: [
                          Text(
                            'SPARTA',
                            style: GoogleFonts.anton(
                              fontSize: 32,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w900,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 3.0
                                ..color = Colors.black,
                            ),
                          ),
                          Text(
                            'SPARTA',
                            style: GoogleFonts.anton(
                              color: const Color.fromARGB(255, 216, 14, 0),
                              fontSize: 32,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(),
                    _DrawerNavItem(
                      label: 'Home',
                      icon: Icons.home,
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = 0;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    _DrawerNavItem(
                      label: 'Rent a Bike',
                      icon: Icons.directions_bike,
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = 1;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    _DrawerNavItem(
                      label: 'My Rentals',
                      icon: Icons.list_alt,
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = 2;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    _DrawerNavItem(
                      label: 'About',
                      icon: Icons.info_outline,
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = 3;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text('Sign Out'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset('assets/batangas_bg.jpg', fit: BoxFit.cover),
          Container(
            color: Colors.black.withValues(
              alpha: 0.65,
            ), // Darker overlay for contrast
          ),
          SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isMobile ? 400 : 900),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                  child: Column(
                    children: [
                      if (_selectedTabIndex == 0) ...[
                        SizedBox(height: isMobile ? 24 : 36),
                        // Branding section
                        if (!isMobile || !_showMobileAppBar)
                          GestureDetector(
                            onTap: isMobile
                                ? () {
                                    setState(() {
                                      _showMobileAppBar = true;
                                    });
                                  }
                                : null,
                            child: Column(
                              children: [
                                SizedBox(height: isMobile ? 24 : 36),
                                Image.asset(
                                  'assets/spartan_logo.png',
                                  height: isMobile ? 90 : 120,
                                ),
                                const SizedBox(height: 12),
                                // SPARTA with black border
                                Stack(
                                  children: [
                                    // Black stroke
                                    Text(
                                      'SPARTA',
                                      style: GoogleFonts.anton(
                                        fontSize: isMobile ? 44 : 64,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.w900,
                                        foreground: Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 5
                                          ..color = Colors.black,
                                      ),
                                    ),
                                    // Red fill
                                    Text(
                                      'SPARTA',
                                      style: GoogleFonts.anton(
                                        color: const Color.fromARGB(
                                          255,
                                          216,
                                          14,
                                          0,
                                        ),
                                        fontSize: isMobile ? 44 : 64,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'BATANGAS STATE UNIVERSITY - TNEU',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 16 : 20,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 18),
                        Text(
                          'University Bike Rental',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 36 : 54,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 6,
                                color: Colors.black87,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sustainable, affordable, and fun bike rentals for Batangas State University - TNEU.',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black54,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: isMobile ? 220 : 260,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow[700],
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: isMobile ? 18 : 22,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              textStyle: TextStyle(
                                fontSize: isMobile ? 20 : 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              elevation: 6,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedTabIndex = 1;
                              });
                            },
                            child: const Text('Get Started'),
                          ),
                        ),
                        const SizedBox(height: 36),
                        isMobile
                            ? Column(
                                children: [
                                  _FeatureCard(
                                    icon: Icons.spa,
                                    title: 'Eco-Friendly',
                                    description:
                                        'Reduce your carbon footprint and help keep our campus green by choosing bikes over cars.',
                                    isMobile: true,
                                  ),
                                  const SizedBox(height: 20),
                                  _FeatureCard(
                                    icon: Icons.attach_money,
                                    title: 'Affordable',
                                    description:
                                        'Enjoy low-cost rentals designed for students and staff. No hidden fees, just easy rides.',
                                    isMobile: true,
                                  ),
                                  const SizedBox(height: 20),
                                  _FeatureCard(
                                    icon: Icons.place,
                                    title: 'Convenient',
                                    description:
                                        'Pick up and return bikes at multiple campus locations. Fast, simple, and always available.',
                                    isMobile: true,
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: _FeatureCard(
                                      icon: Icons.spa,
                                      title: 'Eco-Friendly',
                                      description:
                                          'Reduce your carbon footprint and help keep our campus green by choosing bikes over cars.',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Flexible(
                                    child: _FeatureCard(
                                      icon: Icons.attach_money,
                                      title: 'Affordable',
                                      description:
                                          'Enjoy low-cost rentals designed for students and staff. No hidden fees, just easy rides.',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Flexible(
                                    child: _FeatureCard(
                                      icon: Icons.place,
                                      title: 'Convenient',
                                      description:
                                          'Pick up and return bikes at multiple campus locations. Fast, simple, and always available.',
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 40),
                      ] else if (_selectedTabIndex == 1) ...[
                        const SizedBox(height: 32),
                        RentBikeSwiper(),
                      ] else if (_selectedTabIndex == 2) ...[
                        const SizedBox(height: 32),
                        _MyRentalsTab(currentUserEmail: widget.userEmail),
                      ] else if (_selectedTabIndex == 3) ...[
                        const SizedBox(height: 32),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 600;
                            final cardWidth = isWide ? 480.0 : double.infinity;
                            final horizontalPad = isWide ? 32.0 : 16.0;
                            final verticalPad = isWide ? 32.0 : 20.0;
                            final titleSize = isWide ? 26.0 : 20.0;
                            final descSize = isWide ? 15.0 : 13.5;
                            final sectionPad = isWide ? 28.0 : 18.0;
                            final iconSize = isWide ? 28.0 : 22.0;
                            final contactIconSize = isWide ? 24.0 : 20.0;
                            final contactFontSize = isWide ? 15.0 : 13.0;
                            return Center(
                              child: Card(
                                color: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Container(
                                  width: cardWidth,
                                  padding: EdgeInsets.symmetric(
                                    vertical: verticalPad,
                                    horizontal: horizontalPad,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Logo
                                      Image.asset(
                                        'assets/spartan_logo.png',
                                        height: isWide ? 70 : 50,
                                      ),
                                      SizedBox(height: isWide ? 18 : 12),
                                      // Title
                                      Text(
                                        'About University Bike Rental',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: titleSize,
                                          color: Colors.blue[800],
                                          letterSpacing: 1.1,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: isWide ? 16 : 10),
                                      // Description
                                      Text(
                                        'The University Bike Rental program at Batangas State University - TNEU provides students, faculty, and staff with sustainable, affordable, and convenient transportation around campus. Our mission is to promote eco-friendly mobility, healthy living, and a vibrant campus community.',
                                        style: TextStyle(
                                          fontSize: descSize,
                                          color: Colors.black87,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: sectionPad),
                                      // Mission
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.flag,
                                            color: Colors.red[700],
                                            size: iconSize,
                                          ),
                                          SizedBox(width: isWide ? 12 : 8),
                                          Expanded(
                                            child: Text(
                                              'Mission: To empower the university community with safe, sustainable, and accessible bike transportation, reducing our carbon footprint and supporting a healthy lifestyle.',
                                              style: TextStyle(
                                                fontSize: descSize,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: isWide ? 18 : 12),
                                      // Vision
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.visibility,
                                            color: Colors.blue[700],
                                            size: iconSize,
                                          ),
                                          SizedBox(width: isWide ? 12 : 8),
                                          Expanded(
                                            child: Text(
                                              'Vision: To be a model campus for green mobility and active living, inspiring other institutions to adopt sustainable transport solutions.',
                                              style: TextStyle(
                                                fontSize: descSize,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: sectionPad),
                                      // Contact Us
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.email,
                                            color: Colors.orange[700],
                                            size: contactIconSize,
                                          ),
                                          SizedBox(width: isWide ? 8 : 6),
                                          Text(
                                            'bikerental@bsu.edu.ph',
                                            style: TextStyle(
                                              fontSize: contactFontSize,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Spacer(),
                                          Icon(
                                            Icons.phone,
                                            color: Colors.green[700],
                                            size: contactIconSize,
                                          ),
                                          SizedBox(width: isWide ? 8 : 6),
                                          Text(
                                            '+63 912 345 6789',
                                            style: TextStyle(
                                              fontSize: contactFontSize,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isMobile;
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Colors.white,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 28 : 32,
          horizontal: isMobile ? 18 : 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isMobile ? 44 : 56, color: Colors.green[700]),
            SizedBox(height: isMobile ? 16 : 20),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 22 : 24,
                color: Colors.green[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 10 : 12),
            Text(
              description,
              style: TextStyle(
                fontSize: isMobile ? 15 : 17,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  const _NavBar({required this.selectedIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavItem(
          label: 'Home',
          isActive: selectedIndex == 0,
          onTap: () => onTabSelected(0),
        ),
        const SizedBox(width: 36),
        _NavItem(
          label: 'Rent a Bike',
          isActive: selectedIndex == 1,
          onTap: () => onTabSelected(1),
        ),
        const SizedBox(width: 36),
        _NavItem(
          label: 'My Rentals',
          isActive: selectedIndex == 2,
          onTap: () => onTabSelected(2),
        ),
        const SizedBox(width: 36),
        _NavItem(
          label: 'About',
          isActive: selectedIndex == 3,
          onTap: () => onTabSelected(3),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  const _NavItem({required this.label, this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.blue[700] : Colors.black,
            fontWeight: isActive ? FontWeight.w900 : FontWeight.w500,
            fontSize: 22,
            letterSpacing: 0.5,
            // No underline
          ),
        ),
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _DrawerNavItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}

// 1. Create a new page for the full-screen application form
class BikeRentalApplicationPage extends StatelessWidget {
  final Map<String, dynamic> bike;
  const BikeRentalApplicationPage({super.key, required this.bike});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bike Rental Application')),
      body: BikeRentalApplicationForm(bike: bike),
    );
  }
}

// 2. Make RentBikeSwiper stateful to track current index and navigate to form page
class RentBikeSwiper extends StatefulWidget {
  RentBikeSwiper({super.key});

  final List<Map<String, dynamic>> bikes = List.generate(10, (index) {
    return {
      'id': 'BSU ${(index + 1).toString().padLeft(3, '0')}',
      'image': 'assets/bike.webp',
      'amenities': ['Helmet', 'Tumbler', 'Air pump'],
      'available': true,
    };
  });

  @override
  State<RentBikeSwiper> createState() => _RentBikeSwiperState();
}

class _RentBikeSwiperState extends State<RentBikeSwiper> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double swiperWidth;
    double itemWidth;
    double viewportFraction;

    if (width < 600) {
      swiperWidth = width * 0.98;
      itemWidth = width * 0.92;
      viewportFraction = 0.98;
    } else if (width < 900) {
      swiperWidth = width * 0.90;
      itemWidth = 320.0;
      viewportFraction = 0.6;
    } else {
      swiperWidth = width * 0.85;
      itemWidth = 420.0;
      viewportFraction = 0.28;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double availableHeight = constraints.maxHeight;
        double swiperHeight;
        if (width < 600) {
          swiperHeight = availableHeight > 0 ? availableHeight * 0.95 : 420;
          swiperHeight = swiperHeight.clamp(360, 480);
        } else {
          swiperHeight = availableHeight > 0 ? availableHeight * 0.8 : 520;
          swiperHeight = swiperHeight.clamp(420, 600);
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                    elevation: 6,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BikeRentalApplicationPage(
                          bike: widget.bikes[currentIndex],
                        ),
                      ),
                    );
                  },
                  child: const Text('Rent a bike'),
                ),
              ),
            ),
            SizedBox(
              height: swiperHeight,
              width: swiperWidth,
              child: Swiper(
                itemCount: widget.bikes.length,
                itemWidth: itemWidth,
                layout: SwiperLayout.STACK,
                viewportFraction: viewportFraction,
                onIndexChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return BikeCard(bike: widget.bikes[index], isActive: true);
                },
                pagination: SwiperPagination(
                  margin: const EdgeInsets.only(top: 40),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class BikeCard extends StatelessWidget {
  final Map<String, dynamic> bike;
  final bool isActive;
  const BikeCard({required this.bike, this.isActive = false, super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive ? Colors.blue : Colors.grey.shade300,
          width: isActive ? 3 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.15 * 255).toInt()),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      width: isDesktop ? 420 : 340, // Wider on desktop
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: isDesktop ? 24 : 16), // More top gap on desktop
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 16.0 : 8.0),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    bike['image'],
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: isDesktop ? 20 : 12),
          Text(
            bike['id'],
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: isDesktop ? 32 : 24,
              color: Colors.blue,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: isDesktop ? 8 : 4),
          Text(
            'Available for BSU students',
            style: TextStyle(
              fontSize: isDesktop ? 19 : 15,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isDesktop ? 16 : 10),
          Text(
            'Amenities',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: isDesktop ? 22 : 16,
            ),
          ),
          ...List.generate(
            bike['amenities'].length,
            (i) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  i == 0
                      ? Icons.sports_motorsports
                      : i == 1
                      ? Icons.local_drink
                      : Icons.air,
                  size: isDesktop ? 24 : 18,
                  color: Colors.green[700],
                ),
                SizedBox(width: 6),
                Text(
                  bike['amenities'][i],
                  style: TextStyle(fontSize: isDesktop ? 18 : 14),
                ),
              ],
            ),
          ),
          SizedBox(height: isDesktop ? 12 : 8),
          Text(
            bike['available'] ? 'Available' : 'Not Available',
            style: TextStyle(
              color: bike['available'] ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 18 : 15,
            ),
          ),
          SizedBox(height: isDesktop ? 8 : 4),
        ],
      ),
    );
  }
}

class BikeRentalApplicationForm extends StatefulWidget {
  final Map<String, dynamic> bike;
  const BikeRentalApplicationForm({super.key, required this.bike});

  @override
  State<BikeRentalApplicationForm> createState() =>
      _BikeRentalApplicationFormState();
}

class _BikeRentalApplicationFormState extends State<BikeRentalApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  // Controllers for all fields
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController srCodeController = TextEditingController();
  String? sex;
  DateTime? dob;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController gwaController = TextEditingController();
  final TextEditingController activitiesController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController barangayController = TextEditingController();
  String? distanceFromCampus;
  final TextEditingController incomeController = TextEditingController();
  String? duration;
  final TextEditingController durationOtherController = TextEditingController();
  bool termsAccepted = false;
  bool isSubmitting = false;
  PlatformFile? selectedFile;

  @override
  void dispose() {
    lastNameController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    srCodeController.dispose();
    phoneController.dispose();
    emailController.dispose();
    collegeController.dispose();
    gwaController.dispose();
    activitiesController.dispose();
    houseController.dispose();
    streetController.dispose();
    provinceController.dispose();
    cityController.dispose();
    barangayController.dispose();
    incomeController.dispose();
    durationOtherController.dispose();
    super.dispose();
  }

  // Replace the form build with a modern, visually appealing design
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isWide ? 16.0 : 8.0),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Form fields
                      Expanded(
                        flex: 2,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bike Rental Application',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Name row
                              Row(
                                children: [
                                  Expanded(
                                    child: _formField(
                                      lastNameController,
                                      'Last Name*',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _formField(
                                      firstNameController,
                                      'First Name*',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _formField(
                                      middleNameController,
                                      'Middle Name',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // SR Code, Sex, Certificate row
                              Row(
                                children: [
                                  Expanded(
                                    child: _formField(
                                      srCodeController,
                                      'SR Code*',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _dropdownField('Sex*', sex, [
                                      'Male',
                                      'Female',
                                      'Other',
                                    ], (val) => setState(() => sex = val)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(child: _filePickerButton()),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // DOB, Phone, Email row
                              Row(
                                children: [
                                  Expanded(
                                    child: _datePickerField('Date of Birth*'),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _formField(
                                      phoneController,
                                      'Phone Number*',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _formField(
                                      emailController,
                                      'Email Address*',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // College, GWA, Activities row
                              Row(
                                children: [
                                  Expanded(
                                    child: _formField(
                                      collegeController,
                                      'College/Program*',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _formField(
                                      gwaController,
                                      'GWA Last Semester*',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _formField(
                                      activitiesController,
                                      'Extracurricular Activities',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Address row
                              Row(
                                children: [
                                  Expanded(
                                    child: _formField(
                                      houseController,
                                      'House No.',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _formField(
                                      streetController,
                                      'Street Name',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _formField(
                                      provinceController,
                                      'Province',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _formField(
                                      cityController,
                                      'Municipality/City',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _formField(
                                      barangayController,
                                      'Barangay',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(child: Container()),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Distance, Income, Duration row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _radioGroup(
                                      'Distance from Campus*',
                                      distanceFromCampus,
                                      [
                                        'Less than 1 km',
                                        '1 km but less than 5 km',
                                        '5 km and above',
                                      ],
                                      (val) => setState(
                                        () => distanceFromCampus = val,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _formField(
                                      incomeController,
                                      'Monthly Family Income*',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(child: _durationRadioGroup()),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        (termsAccepted && selectedFile != null)
                                        ? Colors.blue[700]
                                        : Colors.grey[400],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  onPressed:
                                      (termsAccepted &&
                                          !isSubmitting &&
                                          selectedFile != null)
                                      ? _submitForm
                                      : null,
                                  child: isSubmitting
                                      ? const CircularProgressIndicator()
                                      : const Text('Submit Application'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Right: Rental Agreement
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(
                                  (0.05 * 255).toInt(),
                                ),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: _rentalAgreementWidget(),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bike Rental Application',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _formField(lastNameController, 'Last Name*'),
                      _formField(firstNameController, 'First Name*'),
                      _formField(middleNameController, 'Middle Name'),
                      _formField(srCodeController, 'SR Code*'),
                      _dropdownField('Sex*', sex, [
                        'Male',
                        'Female',
                        'Other',
                      ], (val) => setState(() => sex = val)),
                      _filePickerButton(),
                      _datePickerField('Date of Birth*'),
                      _formField(phoneController, 'Phone Number*'),
                      _formField(emailController, 'Email Address*'),
                      _formField(collegeController, 'College/Program*'),
                      _formField(gwaController, 'GWA Last Semester*'),
                      _formField(
                        activitiesController,
                        'Extracurricular Activities',
                      ),
                      _formField(houseController, 'House No.'),
                      _formField(streetController, 'Street Name'),
                      _formField(provinceController, 'Province'),
                      _formField(cityController, 'Municipality/City'),
                      _formField(barangayController, 'Barangay'),
                      _radioGroup(
                        'Distance from Campus*',
                        distanceFromCampus,
                        [
                          'Less than 1 km',
                          '1 km but less than 5 km',
                          '5 km and above',
                        ],
                        (val) => setState(() => distanceFromCampus = val),
                      ),
                      _formField(incomeController, 'Monthly Family Income*'),
                      _durationRadioGroup(),
                      const SizedBox(height: 12),
                      // Rental Agreement ExpansionTile
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ExpansionTile(
                          title: const Text(
                            'Rental Agreement',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2),
                              fontSize: 18,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: _rentalAgreementWidget(),
                            ),
                          ],
                        ),
                      ),
                      // Checkbox for agreement acceptance (always visible)
                      Row(
                        children: [
                          Checkbox(
                            value: termsAccepted,
                            onChanged: (val) {
                              setState(() {
                                termsAccepted = val ?? false;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'I have read and accept the terms and conditions',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                (termsAccepted && selectedFile != null)
                                ? Colors.blue[700]
                                : Colors.grey[400],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          onPressed: null,
                          child: const Text(
                            'Application submission is currently disabled',
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _rentalAgreementWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rental Agreement',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'By submitting this application, you agree to the following terms:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '• You will use the bike responsibly and follow all campus rules.',
        ),
        const Text(
          '• You will return the bike in good condition at the end of the rental period.',
        ),
        const Text(
          '• You are responsible for reporting any damage or issues immediately.',
        ),
        const Text(
          '• Loss or damage due to negligence may result in penalties.',
        ),
        const SizedBox(height: 12),
        const Text(
          'Please read all terms carefully before submitting your application.',
          style: TextStyle(color: Colors.blue),
        ),
        // Checkbox moved here
        Row(
          children: [
            Checkbox(
              value: termsAccepted,
              onChanged: (val) {
                setState(() {
                  termsAccepted = val ?? false;
                });
              },
            ),
            const Expanded(
              child: Text('I have read and accept the terms and conditions'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          'How will the bike be maintained?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'All bikes are regularly checked and maintained by the BSU Bike Rental team. Please report any issues immediately after your ride.',
        ),
        const SizedBox(height: 16),
        const Text(
          'How to find your bike?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'After your application is approved, you will receive instructions on where to pick up your bike on campus.',
        ),
      ],
    );
  }

  // Helper widgets for form fields
  Widget _formField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      enabled: termsAccepted,
      style: TextStyle(
        fontSize: 16,
        color: termsAccepted ? Colors.black : Colors.grey[600],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 16,
          color: termsAccepted ? Colors.black : Colors.grey[600],
        ),
        filled: true,
        fillColor: termsAccepted ? Colors.grey[100] : Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: (v) =>
          label.endsWith('*') && (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _dropdownField(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (s) => DropdownMenuItem(
              value: s,
              child: Text(
                s,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          )
          .toList(),
      onChanged: termsAccepted ? onChanged : null,
      style: TextStyle(
        fontSize: 16,
        color: termsAccepted ? Colors.black : Colors.grey[600],
      ),
      dropdownColor: termsAccepted ? Colors.grey[100] : Colors.grey[200],
      iconEnabledColor: termsAccepted ? Colors.black : Colors.grey[600],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 16,
          color: termsAccepted ? Colors.black : Colors.grey[600],
        ),
        filled: true,
        fillColor: termsAccepted ? Colors.grey[100] : Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: (v) =>
          label.endsWith('*') && (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _datePickerField(String label) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 16,
          color: termsAccepted ? Colors.black : Colors.grey[600],
        ),
        filled: true,
        fillColor: termsAccepted ? Colors.grey[100] : Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      style: TextStyle(
        fontSize: 16,
        color: termsAccepted ? Colors.black : Colors.grey[600],
      ),
      readOnly: true,
      enabled: termsAccepted,
      controller: TextEditingController(
        text: dob == null ? '' : '${dob!.month}/${dob!.day}/${dob!.year}',
      ),
      onTap: !termsAccepted
          ? null
          : () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => dob = picked);
            },
      validator: (v) => dob == null ? 'Required' : null,
    );
  }

  Widget _filePickerButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: termsAccepted ? _pickFile : null,
          icon: Icon(
            Icons.attach_file,
            color: termsAccepted ? Colors.blue[700] : Colors.grey[400],
          ),
          label: Text(
            selectedFile != null
                ? 'File Selected'
                : 'Certificate of Indigency File',
            style: TextStyle(
              color: termsAccepted ? Colors.blue : Colors.grey[600],
              fontSize: 16,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: termsAccepted ? Colors.blue[200]! : Colors.grey[300]!,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            backgroundColor: termsAccepted ? Colors.grey[50] : Colors.grey[100],
          ),
        ),
        if (selectedFile != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedFile!.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: termsAccepted
                      ? () {
                          setState(() {
                            selectedFile = null;
                          });
                        }
                      : null,
                  icon: Icon(Icons.close, color: Colors.green[700], size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && mounted) {
        setState(() {
          selectedFile = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _radioGroup(
    String label,
    String? groupValue,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: termsAccepted ? Colors.black : Colors.grey[600],
          ),
        ),
        ...options.map(
          (opt) => RadioListTile<String>(
            value: opt,
            groupValue: groupValue,
            onChanged: termsAccepted ? onChanged : null,
            title: Text(
              opt,
              style: TextStyle(
                fontSize: 16,
                color: termsAccepted ? Colors.black : Colors.grey[600],
              ),
            ),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _durationRadioGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intended Duration of Use*',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: termsAccepted ? Colors.black : Colors.grey[600],
          ),
        ),
        RadioListTile<String>(
          value: 'One Semester',
          groupValue: duration,
          onChanged: termsAccepted
              ? (val) => setState(() => duration = val)
              : null,
          title: Text(
            'One Semester',
            style: TextStyle(
              fontSize: 16,
              color: termsAccepted ? Colors.black : Colors.grey[600],
            ),
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        Row(
          children: [
            Radio<String>(
              value: 'Others',
              groupValue: duration,
              onChanged: termsAccepted
                  ? (val) => setState(() => duration = val)
                  : null,
            ),
            Text(
              'Others:',
              style: TextStyle(
                fontSize: 16,
                color: termsAccepted ? Colors.black : Colors.grey[600],
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: durationOtherController,
                enabled: termsAccepted && duration == 'Others',
                decoration: InputDecoration(
                  hintText: 'Specify',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: termsAccepted ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: termsAccepted ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isSubmitting = true;
    });

    try {
      final formData = {
        'lastName': lastNameController.text,
        'firstName': firstNameController.text,
        'middleName': middleNameController.text,
        'srCode': srCodeController.text,
        'sex': sex,
        'dob': dob?.toIso8601String(),
        'phone': phoneController.text,
        'email': emailController.text,
        'college': collegeController.text,
        'gwa': gwaController.text,
        'activities': activitiesController.text,
        'house': houseController.text,
        'street': streetController.text,
        'province': provinceController.text,
        'city': cityController.text,
        'barangay': barangayController.text,
        'distanceFromCampus': distanceFromCampus,
        'income': incomeController.text,
        'duration': duration,
        'durationOther': durationOtherController.text,
        'certificateFile': selectedFile?.name ?? 'No file selected',
      };

      final applicationId = await ApplicationStorage().insertApplication({
        'userEmail': emailController.text,
        'bikeId': widget.bike['id'],
        'formData': jsonEncode(formData),
      });

      if (!mounted) return;
      setState(() {
        isSubmitting = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Application Submitted!'),
          content: Text(
            'Your application has been submitted.\nApplication ID: $applicationId',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isSubmitting = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Submission Error'),
          content: Text('There was an error submitting your application: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final result = await UserStorage().getUsers();
    setState(() {
      users = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Users (Debug)')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['email'] ?? ''),
                  subtitle: Text(
                    'Name: ${user['name'] ?? ''} | Role: ${user['role'] ?? ''}',
                  ),
                );
              },
            ),
    );
  }
}

// Remove the ApplicationListPage widget and its usages

class ApplicationStorage {
  static final ApplicationStorage _instance = ApplicationStorage._internal();
  factory ApplicationStorage() => _instance;
  ApplicationStorage._internal();

  File? _applicationFile;

  Future<File> get _file async {
    if (_applicationFile != null) return _applicationFile!;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/applications.json');
    if (!await file.exists()) {
      try {
        final data = await rootBundle.loadString('assets/applications.json');
        await file.writeAsString(data);
      } catch (e) {
        await file.writeAsString('[]');
      }
    }
    _applicationFile = file;
    return file;
  }

  Future<List<Map<String, dynamic>>> getApplications() async {
    final file = await _file;
    final data = await file.readAsString();
    final List<dynamic> applications = jsonDecode(data);
    return applications.cast<Map<String, dynamic>>();
  }

  Future<void> saveApplications(List<Map<String, dynamic>> applications) async {
    final file = await _file;
    await file.writeAsString(jsonEncode(applications));
  }

  Future<String> insertApplication(Map<String, dynamic> application) async {
    final applications = await getApplications();
    final newId = 'APP-${(applications.length + 1).toString().padLeft(3, '0')}';
    final newApplication = {
      'id': newId,
      'user_email': application['userEmail'],
      'bike_id': application['bikeId'],
      'status': 'pending',
      'application_date': DateTime.now().toIso8601String(),
      'form_data': application['formData'] != null
          ? jsonDecode(application['formData'])
          : {},
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    applications.add(newApplication);
    await saveApplications(applications);
    return newId;
  }
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedTabIndex =
      0; // 0: Dashboard, 1: Applications, 2: Bikes, 3: Activity Log

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    switch (_selectedTabIndex) {
      case 1:
        bodyContent = const _ApplicationsManagement();
        break;
      case 2:
        bodyContent = const Center(
          child: Text(
            'Bikes Management (Coming Soon)',
            style: TextStyle(fontSize: 24),
          ),
        );
        break;
      case 3:
        bodyContent = const Center(
          child: Text(
            'Activity Log (Coming Soon)',
            style: TextStyle(fontSize: 24),
          ),
        );
        break;
      case 0:
      default:
        bodyContent = SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage bike rentals and applications',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                _DashboardStatsRow(),
                const SizedBox(height: 32),
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _QuickActionsRow(),
              ],
            ),
          ),
        );
        break;
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _AdminAppBar(
          selectedTabIndex: _selectedTabIndex,
          onTabSelected: _onTabSelected,
        ),
      ),
      body: bodyContent,
    );
  }
}

class _AdminAppBar extends StatelessWidget {
  final int selectedTabIndex;
  final void Function(int) onTabSelected;
  const _AdminAppBar({
    required this.selectedTabIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      titleSpacing: 24,
      title: Row(
        children: [
          Image.asset('assets/spartan_logo.png', height: 40),
          const SizedBox(width: 12),
          const Text(
            'SPARTA',
            style: TextStyle(
              color: Color(0xFFB71C1C),
              fontWeight: FontWeight.w900,
              fontSize: 28,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
      actions: [
        _NavBarButton(
          label: 'Dashboard',
          icon: Icons.bar_chart,
          selected: selectedTabIndex == 0,
          onTap: () => onTabSelected(0),
        ),
        _NavBarButton(
          label: 'Applications',
          icon: Icons.assignment,
          selected: selectedTabIndex == 1,
          onTap: () => onTabSelected(1),
        ),
        _NavBarButton(
          label: 'Bikes',
          icon: Icons.directions_bike,
          selected: selectedTabIndex == 2,
          onTap: () => onTabSelected(2),
        ),
        _NavBarButton(
          label: 'Activity Log',
          icon: Icons.receipt_long,
          selected: selectedTabIndex == 3,
          onTap: () => onTabSelected(3),
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.red),
              onPressed: () {},
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '1',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          // Navigate back to login page and clear all routes
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('Log Out'),
          ),
        ),
      ],
    );
  }
}

class _NavBarButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;
  const _NavBarButton({
    required this.label,
    required this.icon,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: selected ? Colors.blue : Colors.black54),
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.blue : Colors.black87,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: selected
            ? Colors.blue.withValues(alpha: 0.07)
            : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

class _DashboardStatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace these with your actual data
    final stats = [
      _DashboardStatCard(
        label: 'Total Applications',
        value: '1',
        icon: Icons.assignment,
        color: Colors.blue,
      ),
      _DashboardStatCard(
        label: 'Pending Applications',
        value: '1',
        icon: Icons.hourglass_empty,
        color: Colors.orange,
      ),
      _DashboardStatCard(
        label: 'Assigned Applications',
        value: '0',
        icon: Icons.check_box,
        color: Colors.green,
      ),
      _DashboardStatCard(
        label: 'Total Bikes',
        value: '10',
        icon: Icons.directions_bike,
        color: Colors.purple,
      ),
      _DashboardStatCard(
        label: 'Available Bikes',
        value: '10',
        icon: Icons.fiber_manual_record,
        color: Colors.teal,
      ),
      _DashboardStatCard(
        label: 'Rented Bikes',
        value: '0',
        icon: Icons.fiber_manual_record,
        color: Colors.red,
      ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: stats
            .map(
              (card) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: card,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _DashboardStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: color, size: 24),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _QuickActionCard(
          title: 'Manage Applications',
          description: 'Review and assign bikes to rental applications',
          color: Colors.blue,
        ),
        SizedBox(width: 16),
        _QuickActionCard(
          title: 'Manage Bikes',
          description: 'Add, edit, and monitor bike inventory',
          color: Colors.green,
        ),
        SizedBox(width: 16),
        _QuickActionCard(
          title: 'Manage Accounts',
          description: 'Create, edit, and manage user accounts',
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  const _QuickActionCard({
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            const Icon(Icons.arrow_forward, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

// Placeholder for Applications Management
class _ApplicationsManagement extends StatelessWidget {
  const _ApplicationsManagement();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Rental Applications Management',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TabPill(label: 'All', selected: true),
                const SizedBox(width: 12),
                _TabPill(label: 'Pending', selected: false),
                const SizedBox(width: 12),
                _TabPill(label: 'Assigned', selected: false),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 400,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by email...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 32),
            DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Bike')),
                DataColumn(label: Text('Applied')),
                DataColumn(label: Text('Assign Bike')),
              ],
              rows: [
                DataRow(
                  cells: [
                    const DataCell(
                      Text('anthony lang sakanal, anthony lang sakanal'),
                    ),
                    const DataCell(Text('villablancaanthony2@gmail.com')),
                    const DataCell(Text('Pending')),
                    const DataCell(Text('-')),
                    const DataCell(Text('7/10/2025')),
                    DataCell(
                      DropdownButton<String>(
                        value: null,
                        hint: const Text('Select bike'),
                        items: const [
                          DropdownMenuItem(
                            value: 'bike1',
                            child: Text('Bike 1'),
                          ),
                          DropdownMenuItem(
                            value: 'bike2',
                            child: Text('Bike 2'),
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  const _TabPill({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Add this widget at the end of the file:
class _MyRentalsTab extends StatefulWidget {
  final String currentUserEmail;
  const _MyRentalsTab({required this.currentUserEmail});
  @override
  State<_MyRentalsTab> createState() => _MyRentalsTabState();
}

class _MyRentalsTabState extends State<_MyRentalsTab> {
  List<Map<String, dynamic>> rentals = [];
  bool isTracking = false;
  int? trackingIndex;
  late double totalDistance;
  late double totalCO2;
  List<String> allReports = [];
  @override
  void initState() {
    super.initState();
    // Always add a rental for the current user
    rentals = [
      {
        'bikeId': 'BSU 003',
        'kilometers': 15.0,
        'maintenanceReports': <String>[],
        'userEmail': widget.currentUserEmail,
      },
      {
        'bikeId': 'BSU 001',
        'kilometers': 12.5,
        'maintenanceReports': <String>[],
        'userEmail': 'student1@bikerent.com',
      },
      {
        'bikeId': 'BSU 002',
        'kilometers': 7.2,
        'maintenanceReports': <String>[],
        'userEmail': 'student2@bikerent.com',
      },
    ];
    totalDistance = _calculateTotalDistance();
    totalCO2 = _calculateTotalCO2();
    allReports = _getAllReports();
  }

  double _calculateTotalDistance() {
    return rentals
        .where((r) => r['userEmail'] == widget.currentUserEmail)
        .fold(0.0, (sum, r) => sum + (r['kilometers'] as double));
  }

  double _calculateTotalCO2() {
    return rentals
        .where((r) => r['userEmail'] == widget.currentUserEmail)
        .fold(0.0, (sum, r) => sum + ((r['kilometers'] as double) * 0.21));
  }

  List<String> _getAllReports() {
    return rentals
        .where((r) => r['userEmail'] == widget.currentUserEmail)
        .expand((r) => (r['maintenanceReports'] as List<String>))
        .toList();
  }

  void _showMaintenanceDialog(int index) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Maintenance Issue'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Describe the issue...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (result != null && result.isNotEmpty) {
      setState(() {
        rentals[index]['maintenanceReports'].add(result);
        allReports = _getAllReports();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maintenance report submitted!')),
      );
    }
  }

  void _startTracking(int index) {
    setState(() {
      isTracking = true;
      trackingIndex = index;
    });
    _simulateRide(index);
  }

  void _simulateRide(int index) async {
    while (isTracking && trackingIndex == index && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !isTracking || trackingIndex != index) break;
      setState(() {
        rentals[index]['kilometers'] += 0.1; // Simulate 0.1 km per second
        totalDistance = _calculateTotalDistance();
        totalCO2 = _calculateTotalCO2();
      });
    }
  }

  void _endTracking() {
    setState(() {
      isTracking = false;
      trackingIndex = null;
      totalDistance = _calculateTotalDistance();
      totalCO2 = _calculateTotalCO2();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userRentals = rentals
        .where((r) => r['userEmail'] == widget.currentUserEmail)
        .toList();
    final totalCostSaved = userRentals.fold(
      0.0,
      (sum, r) => sum + (r['kilometers'] / 4.0) * 13.0,
    );
    final longestRide = userRentals.isNotEmpty
        ? userRentals
              .map((r) => r['kilometers'] as double)
              .reduce((a, b) => a > b ? a : b)
        : 0.0;
    final mostInWeek = 32.0; // sample
    final mostInMonth = 42.5; // sample
    final treesPlanted = (totalCO2 / 21).floor(); // 1 tree = 21kg CO2
    final carKmAvoided = (totalDistance).round();
    final distanceGoal = 100.0;
    final co2Goal = 10.0;
    final distancePercent = ((totalDistance / distanceGoal) * 100)
        .clamp(0, 999)
        .toInt();
    final co2Percent = ((totalCO2 / co2Goal) * 100).clamp(0, 999).toInt();
    final leaderboard = [
      {'user': 'You', 'distance': totalDistance},
      {'user': 'Alex', 'distance': 38.0},
      {'user': 'Sam', 'distance': 35.0},
      {'user': 'Jamie', 'distance': 30.0},
    ];
    final currentBike = userRentals.isNotEmpty
        ? userRentals.first['bikeId']
        : 'No Bike';
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            color: const Color(0xFFF7F8FA),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Bike Card
                  Builder(
                    builder: (context) {
                      if (userRentals.isEmpty) {
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: Colors.red[100]!,
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.directions_bike,
                                  color: Colors.red,
                                  size: 32,
                                ),
                                SizedBox(width: 14),
                                Text(
                                  'No active bike rental',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      final rental = userRentals.first;
                      final co2Saved = (rental['kilometers'] * 0.21);
                      final costSaved = (rental['kilometers'] / 4.0) * 13.0;
                      final isLive = isTracking && trackingIndex == 0;
                      return Card(
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: Colors.blue[100]!,
                            width: 1.5,
                          ),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.directions_bike,
                                    color: Colors.blue[700],
                                    size: 28,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Bike: ${rental['bikeId']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.black87,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  if (isLive) ...[
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.red[200]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.flash_on,
                                            color: Colors.red,
                                            size: 14,
                                          ),
                                          SizedBox(width: 3),
                                          Text(
                                            'LIVE',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 14),
                              isWide
                                  ? Row(
                                      children: [
                                        _SportyStat(
                                          icon: Icons.route,
                                          label: 'Distance',
                                          value:
                                              '${rental['kilometers'].toStringAsFixed(2)} km',
                                          color: Colors.blue[700]!,
                                        ),
                                        const SizedBox(width: 18),
                                        _SportyStat(
                                          icon: Icons.eco,
                                          label: 'CO₂',
                                          value:
                                              '${co2Saved.toStringAsFixed(2)} kg',
                                          color: Colors.green[700]!,
                                        ),
                                        const SizedBox(width: 18),
                                        _SportyStat(
                                          icon: Icons.savings,
                                          label: 'Saved',
                                          value:
                                              '₱${costSaved.toStringAsFixed(2)}',
                                          color: Colors.orange[700]!,
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _SportyStat(
                                          icon: Icons.route,
                                          label: 'Distance',
                                          value:
                                              '${rental['kilometers'].toStringAsFixed(2)} km',
                                          color: Colors.blue[700]!,
                                        ),
                                        const SizedBox(height: 8),
                                        _SportyStat(
                                          icon: Icons.eco,
                                          label: 'CO₂',
                                          value:
                                              '${co2Saved.toStringAsFixed(2)} kg',
                                          color: Colors.green[700]!,
                                        ),
                                        const SizedBox(height: 8),
                                        _SportyStat(
                                          icon: Icons.savings,
                                          label: 'Saved',
                                          value:
                                              '₱${costSaved.toStringAsFixed(2)}',
                                          color: Colors.orange[700]!,
                                        ),
                                      ],
                                    ),
                              const SizedBox(height: 10),
                              isWide
                                  ? Row(
                                      children: [
                                        ElevatedButton.icon(
                                          icon: Icon(
                                            isLive
                                                ? Icons.stop
                                                : Icons.directions_bike,
                                          ),
                                          label: Text(
                                            isLive ? 'End Ride' : 'Track Ride',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isLive
                                                ? Colors.red
                                                : Colors.blue[50],
                                            foregroundColor: isLive
                                                ? Colors.white
                                                : Colors.blue[700],
                                            shape: const StadiumBorder(),
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: isLive
                                              ? _endTracking
                                              : () => _startTracking(0),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.build),
                                          label: const Text('Report Issue'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange[50],
                                            foregroundColor: Colors.orange[700],
                                            shape: const StadiumBorder(),
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: () =>
                                              _showMaintenanceDialog(0),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            icon: Icon(
                                              isLive
                                                  ? Icons.stop
                                                  : Icons.directions_bike,
                                            ),
                                            label: Text(
                                              isLive
                                                  ? 'End Ride'
                                                  : 'Track Ride',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isLive
                                                  ? Colors.red
                                                  : Colors.blue[50],
                                              foregroundColor: isLive
                                                  ? Colors.white
                                                  : Colors.blue[700],
                                              shape: const StadiumBorder(),
                                              textStyle: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              elevation: 0,
                                            ),
                                            onPressed: isLive
                                                ? _endTracking
                                                : () => _startTracking(0),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.build),
                                            label: const Text('Report Issue'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.orange[50],
                                              foregroundColor:
                                                  Colors.orange[700],
                                              shape: const StadiumBorder(),
                                              textStyle: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              elevation: 0,
                                            ),
                                            onPressed: () =>
                                                _showMaintenanceDialog(0),
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Stat Cards
                  isWide
                      ? Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _SportyCard(
                                    color: Colors.white,
                                    borderColor: Colors.blue[100]!,
                                    icon: Icons.route,
                                    label: 'Distance',
                                    value:
                                        '${totalDistance.toStringAsFixed(2)} km',
                                    iconColor: Colors.blue[700]!,
                                    isWide: isWide,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _SportyCard(
                                    color: Colors.white,
                                    borderColor: Colors.green[100]!,
                                    icon: Icons.eco,
                                    label: 'CO₂',
                                    value: '${totalCO2.toStringAsFixed(2)} kg',
                                    iconColor: Colors.green[700]!,
                                    isWide: isWide,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _SportyCard(
                                    color: Colors.white,
                                    borderColor: Colors.orange[100]!,
                                    icon: Icons.savings,
                                    label: 'Saving',
                                    value:
                                        '₱${totalCostSaved.toStringAsFixed(2)}',
                                    iconColor: Colors.orange[700]!,
                                    isWide: isWide,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _SportyCard(
                                    color: Colors.white,
                                    borderColor: Colors.red[100]!,
                                    icon: Icons.star,
                                    label: 'Longest',
                                    value:
                                        '${longestRide.toStringAsFixed(1)} km',
                                    iconColor: Colors.red[700]!,
                                    isWide: isWide,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _SportyCard(
                                    color: Colors.white,
                                    borderColor: Colors.purple[100]!,
                                    icon: Icons.calendar_view_week,
                                    label: 'Week',
                                    value: '$mostInWeek km',
                                    iconColor: Colors.purple[700]!,
                                    isWide: isWide,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _SportyCard(
                                    color: Colors.white,
                                    borderColor: Colors.teal[100]!,
                                    icon: Icons.calendar_today,
                                    label: 'Month',
                                    value: '$mostInMonth km',
                                    iconColor: Colors.teal[700]!,
                                    isWide: isWide,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _SportyCard(
                              color: Colors.white,
                              borderColor: Colors.blue[100]!,
                              icon: Icons.route,
                              label: 'Distance',
                              value: '${totalDistance.toStringAsFixed(2)} km',
                              iconColor: Colors.blue[700]!,
                              isWide: isWide,
                            ),
                            const SizedBox(height: 10),
                            _SportyCard(
                              color: Colors.white,
                              borderColor: Colors.green[100]!,
                              icon: Icons.eco,
                              label: 'CO₂',
                              value: '${totalCO2.toStringAsFixed(2)} kg',
                              iconColor: Colors.green[700]!,
                              isWide: isWide,
                            ),
                            const SizedBox(height: 10),
                            _SportyCard(
                              color: Colors.white,
                              borderColor: Colors.orange[100]!,
                              icon: Icons.savings,
                              label: 'Saving',
                              value: '₱${totalCostSaved.toStringAsFixed(2)}',
                              iconColor: Colors.orange[700]!,
                              isWide: isWide,
                            ),
                            const SizedBox(height: 10),
                            _SportyCard(
                              color: Colors.white,
                              borderColor: Colors.red[100]!,
                              icon: Icons.star,
                              label: 'Longest',
                              value: '${longestRide.toStringAsFixed(1)} km',
                              iconColor: Colors.red[700]!,
                              isWide: isWide,
                            ),
                            const SizedBox(height: 10),
                            _SportyCard(
                              color: Colors.white,
                              borderColor: Colors.purple[100]!,
                              icon: Icons.calendar_view_week,
                              label: 'Week',
                              value: '$mostInWeek km',
                              iconColor: Colors.purple[700]!,
                              isWide: isWide,
                            ),
                            const SizedBox(height: 10),
                            _SportyCard(
                              color: Colors.white,
                              borderColor: Colors.teal[100]!,
                              icon: Icons.calendar_today,
                              label: 'Month',
                              value: '$mostInMonth km',
                              iconColor: Colors.teal[700]!,
                              isWide: isWide,
                            ),
                          ],
                        ),
                  const SizedBox(height: 16),
                  // Goal Progress
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: Colors.orange[100]!, width: 1),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.flag,
                                color: Colors.orange[400],
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Goal Progress',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Distance: $distancePercent%',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          LinearProgressIndicator(
                            value: distancePercent / 100,
                            minHeight: 10,
                            color: Colors.blue[400],
                            backgroundColor: Colors.blue[100],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'CO₂: $co2Percent%',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          LinearProgressIndicator(
                            value: co2Percent / 100,
                            minHeight: 10,
                            color: Colors.green[400],
                            backgroundColor: Colors.green[100],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Leaderboard
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.all(18),
                      width: isWide ? 440 : double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue[100]!, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leaderboard (Top Distance This Week)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            color: Colors.blue[50],
                            child: Row(
                              children: const [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      'User',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      'Distance (km)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...leaderboard.map(
                            (entry) => Container(
                              color: entry['user'] == 'You'
                                  ? Colors.blue[50]
                                  : null,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        '${entry['user']}',
                                        style: TextStyle(
                                          fontWeight: entry['user'] == 'You'
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        ((entry['distance'] ?? 0.0) as double)
                                            .toStringAsFixed(1),
                                        style: TextStyle(
                                          fontWeight: entry['user'] == 'You'
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (allReports.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'All Maintenance Reports',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.orange,
                      ),
                    ),
                    ...allReports.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(left: 8, top: 2),
                        child: Text(
                          '- $r',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedPulse extends StatefulWidget {
  final Widget child;
  const AnimatedPulse({super.key, required this.child});
  @override
  State<AnimatedPulse> createState() => _AnimatedPulseState();
}

class _AnimatedPulseState extends State<AnimatedPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: widget.child);
  }
}

double costSaved(double kilometers) => (kilometers / 4.0) * 13.0;

// Helper widget for sporty stat
class _SportyStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _SportyStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoMono',
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Helper widget for sporty cards
class _SportyCard extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final bool isWide;
  const _SportyCard({
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.isWide = true,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isWide ? 18 : 22,
          horizontal: isWide ? 8 : 24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: isWide ? 24 : 30),
            SizedBox(height: isWide ? 7 : 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isWide ? 14 : 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isWide ? 4 : 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isWide ? 18 : 22,
                color: Colors.black87,
                fontFamily: 'RobotoMono',
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
    // Always return a Widget
    return isWide ? card : SizedBox(width: double.infinity, child: card);
  }
}
