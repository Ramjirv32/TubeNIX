import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../screens/new_dashboard_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../providers/auth_provider.dart';

/// Login/Signup Screen with enhanced UI
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Signup controllers
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();

  bool _isLoginPasswordVisible = false;
  bool _isSignupPasswordVisible = false;
  bool _isSignupConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      print('📝 Login form validated');
      print('📧 Email: ${_loginEmailController.text.trim()}');
      print('🔒 Password length: ${_loginPasswordController.text.length}');
      
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      print('🚀 Calling login API...');
      final response = await authProvider.login(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      print('📬 Response received: ${response.success}');
      print('💬 Message: ${response.message}');

      if (response.success) {
        // Navigate to dashboard on success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NewDashboardScreen()),
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: const Color(0xFFFF6B00),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('❌ Login form validation failed');
    }
  }

  void _handleSignup() async {
    if (_signupFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final response = await authProvider.signUp(
        name: _signupNameController.text.trim(),
        email: _signupEmailController.text.trim(),
        password: _signupPasswordController.text,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (response.success) {
        // Navigate to dashboard on success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NewDashboardScreen()),
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome ${_signupNameController.text}! ${response.message}'),
            backgroundColor: const Color(0xFFFF6B00),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleGoogleSignIn() async {
    // Show message that Google Sign-In is not available on Linux
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-In is not available on Linux Desktop.\nPlease use Email/Password login or run on Android/iOS.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 4),
      ),
    );
    
    // Uncomment below for Android/iOS/Web platforms
    /*
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    print('🔐 Starting Google Sign-In flow...');
    final response = await authProvider.signInWithGoogle();

    setState(() => _isLoading = false);

    if (!mounted) return;

    print('📬 Google Sign-In response: ${response.success}');
    print('💬 Message: ${response.message}');

    if (response.success) {
      // Navigate to dashboard on success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NewDashboardScreen()),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome! ${response.message}'),
          backgroundColor: const Color(0xFFFF6B00),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
        ),
      );
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background gradient circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF0000).withOpacity(0.1),
                    const Color(0xFFFF6B00).withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF6B00).withOpacity(0.1),
                    const Color(0xFF9C27B0).withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    
                    // Logo with animation
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF0000).withOpacity(0.4),
                              blurRadius: 25,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_circle_filled,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // App name with gradient
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                      ).createShader(bounds),
                      child: Text(
                        'TubeNix',
                        style: GoogleFonts.poppins(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create Stunning YouTube Thumbnails',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Custom Tab Bar
                    Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF0000).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: const [
                          Tab(text: 'Login'),
                          Tab(text: 'Sign Up'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Tab Views
                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildLoginForm(),
                          _buildSignupForm(),
                        ],
                      ),
                    ),
                    
                    // Divider
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Google Sign-In Button
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        child: InkWell(
                          onTap: _isLoading ? null : _handleGoogleSignIn,
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.g_mobiledata, size: 32, color: Colors.blue),
                                const SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          
          // Loading overlay - WHITE INDICATOR
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          // Email Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: _loginEmailController,
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 15),
              decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFFF6B00)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          
          // Password Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: _loginPasswordController,
              obscureText: !_isLoginPasswordVisible,
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 15),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF6B00)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isLoginPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() => _isLoginPasswordVisible = !_isLoginPasswordVisible);
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 10),
          
          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFFF6B00),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Login Button
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF0000).withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isLoading ? null : _handleLogin,
                borderRadius: BorderRadius.circular(15),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
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

  Widget _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Name Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _signupNameController,
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFFF6B00)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Email Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _signupEmailController,
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFFF6B00)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Password Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _signupPasswordController,
                obscureText: !_isSignupPasswordVisible,
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF6B00)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isSignupPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _isSignupPasswordVisible = !_isSignupPasswordVisible);
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Confirm Password Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _signupConfirmPasswordController,
                obscureText: !_isSignupConfirmPasswordVisible,
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF6B00)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isSignupConfirmPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _isSignupConfirmPasswordVisible = !_isSignupConfirmPasswordVisible);
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _signupPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Sign Up Button
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF0000).withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLoading ? null : _handleSignup,
                  borderRadius: BorderRadius.circular(15),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Create Account',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
