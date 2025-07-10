import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:card_swiper/card_swiper.dart';

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

  void _signIn() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    // Simulate a successful login after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    });
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
            child: Image.asset(
              'assets/batangas_bg.jpg',
              fit: BoxFit.cover,
            ),
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
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: AssetImage('assets/spartan_logo.png'),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                            style: TextStyle(fontSize: 12, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Please Log In',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                  ),
                                  const SizedBox(height: 16),
                                  // Email field
                                  TextField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.email_outlined),
                                      labelText: 'Email',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '* Password is case sensitive',
                                    style: TextStyle(fontSize: 11, color: Colors.black54),
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
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: const [
                                          Text(
                                            'reCAPTCHA',
                                            style: TextStyle(fontSize: 10, color: Colors.black54),
                                          ),
                                          Text(
                                            'Privacy - Terms',
                                            style: TextStyle(fontSize: 9, color: Colors.blue),
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
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: _isNotRobot && !_isLoading ? _signIn : null,
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                            )
                                          : const Text(
                                        'Sign In',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Forgot password
                                  Align(
                                    alignment: Alignment.center,
                                    child: TextButton(
                                      onPressed: () {},
                                      child: const Text('Forgot password?'),
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
                                          style: const TextStyle(color: Colors.black87, fontSize: 13),
                                          children: [
                                            WidgetSpan(
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                                                  );
                                                },
                                                child: Text(
                                                  'Sign Up',
                                                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
                                        style: const TextStyle(color: Colors.red, fontSize: 13),
                                      ),
                                    ),
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
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    // Simulate a successful sign up after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = "Passwords do not match";
          _isLoading = false;
        });
        return;
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context); // Go back to login
      }
    });
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
            child: Image.asset(
              'assets/batangas_bg.jpg',
              fit: BoxFit.cover,
            ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Create Account',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                              const SizedBox(height: 24),
                              // Name field
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person_outline),
                                  labelText: 'Full Name',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
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
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
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
                                    style: const TextStyle(color: Colors.red, fontSize: 13),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow[700],
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: _isLoading ? null : _signUp,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                        )
                                      : const Text(
                                    'Sign Up',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                                  child: const Text('Already have an account? Log In'),
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
  const HomePage({super.key});

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
              backgroundColor: Colors.white.withAlpha((0.95 * 255).toInt()),
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
              backgroundColor: Colors.white.withAlpha((0.95 * 255).toInt()),
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
                      child: Image.asset(
                        'assets/spartan_logo.png',
                        height: 60,
                      ),
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
                    _DrawerNavItem(label: 'Home', icon: Icons.home, onTap: () {
                      Navigator.pop(context);
                    }),
                    _DrawerNavItem(label: 'Rent a Bike', icon: Icons.directions_bike, onTap: () {
                      Navigator.pop(context);
                    }),
                    _DrawerNavItem(label: 'My Rentals', icon: Icons.list_alt, onTap: () {
                      Navigator.pop(context);
                    }),
                    _DrawerNavItem(label: 'About', icon: Icons.info_outline, onTap: () {
                      Navigator.pop(context);
                    }),
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
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginPage()),
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
          Image.asset(
            'assets/batangas_bg.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withAlpha((0.65 * 255).toInt()), // Darker overlay for contrast
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
                                          color: const Color.fromARGB(255, 216, 14, 0),
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
                                padding: EdgeInsets.symmetric(horizontal: 0, vertical: isMobile ? 18 : 22),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                textStyle: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                elevation: 6,
                              ),
                              onPressed: () {},
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
                                      description: 'Reduce your carbon footprint and help keep our campus green by choosing bikes over cars.',
                                      isMobile: true,
                                    ),
                                    const SizedBox(height: 20),
                                    _FeatureCard(
                                      icon: Icons.attach_money,
                                      title: 'Affordable',
                                      description: 'Enjoy low-cost rentals designed for students and staff. No hidden fees, just easy rides.',
                                      isMobile: true,
                                    ),
                                    const SizedBox(height: 20),
                                    _FeatureCard(
                                      icon: Icons.place,
                                      title: 'Convenient',
                                      description: 'Pick up and return bikes at multiple campus locations. Fast, simple, and always available.',
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
                                        description: 'Reduce your carbon footprint and help keep our campus green by choosing bikes over cars.',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Flexible(
                                      child: _FeatureCard(
                                        icon: Icons.attach_money,
                                        title: 'Affordable',
                                        description: 'Enjoy low-cost rentals designed for students and staff. No hidden fees, just easy rides.',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Flexible(
                                      child: _FeatureCard(
                                        icon: Icons.place,
                                        title: 'Convenient',
                                        description: 'Pick up and return bikes at multiple campus locations. Fast, simple, and always available.',
                                      ),
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 40),
                        ]
                        else if (_selectedTabIndex == 1) ...[
                          const SizedBox(height: 32),
                          RentBikeSwiper(),
                        ]
                        else if (_selectedTabIndex == 2) ...[
                          const SizedBox(height: 32),
                          Center(child: Text('My Rentals (Coming Soon)', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
                        ]
                        else if (_selectedTabIndex == 3) ...[
                          const SizedBox(height: 32),
                          Center(child: Text('About (Coming Soon)', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
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
  const _FeatureCard({required this.icon, required this.title, required this.description, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Colors.white,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 28 : 32, horizontal: isMobile ? 18 : 28),
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
              style: TextStyle(fontSize: isMobile ? 15 : 17, color: Colors.black87),
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
        _NavItem(label: 'Home', isActive: selectedIndex == 0, onTap: () => onTabSelected(0)),
        const SizedBox(width: 36),
        _NavItem(label: 'Rent a Bike', isActive: selectedIndex == 1, onTap: () => onTabSelected(1)),
        const SizedBox(width: 36),
        _NavItem(label: 'My Rentals', isActive: selectedIndex == 2, onTap: () => onTabSelected(2)),
        const SizedBox(width: 36),
        _NavItem(label: 'About', isActive: selectedIndex == 3, onTap: () => onTabSelected(3)),
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
  const _DrawerNavItem({required this.label, required this.icon, required this.onTap});

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

// Add this widget for the Rent a Bike page
class RentBikeSwiper extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            height: 520,
            width: 500, // Wider to allow arrows and card spread
            child: Swiper(
              itemCount: bikes.length,
              itemWidth: 340,
              layout: SwiperLayout.STACK,
              viewportFraction: 0.7, // Spread cards out more
              itemBuilder: (context, index) {
                return BikeCard(
                  bike: bikes[index],
                  isActive: true,
                );
              },
              pagination: SwiperPagination(
                margin: const EdgeInsets.only(top: 24), // Move dots further below cards
              ),
            ),
          ),
        ),
        const SizedBox(height: 24), // Extra space below swiper if needed
      ],
    );
  }
}

class BikeCard extends StatelessWidget {
  final Map<String, dynamic> bike;
  final bool isActive;
  const BikeCard({required this.bike, this.isActive = false, super.key});

  @override
  Widget build(BuildContext context) {
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
      width: 340, // Increased width for card
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 180, // Increased height for image container
            decoration: BoxDecoration(
              color: Colors.red[700],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Center(
              child: Image.asset(
                bike['image'],
                height: 150, // Increased image height
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            bike['id'],
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: Colors.blue,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Available for BSU students',
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          const Text(
            'Amenities',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: 16,
            ),
          ),
          ...List.generate(
            bike['amenities'].length,
            (i) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  i == 0
                      ? Icons.park
                      : i == 1
                          ? Icons.local_drink
                          : Icons.air,
                  size: 18,
                  color: Colors.green[700],
                ),
                const SizedBox(width: 6),
                Text(
                  bike['amenities'][i],
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bike['available'] ? 'Available' : 'Not Available',
            style: TextStyle(
              color: bike['available'] ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: () {},
              child: const Text('Rent Now'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
