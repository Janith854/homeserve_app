import re

login_code = """
  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService.instance;
      final userModel = await authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        widget.onLoginSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
"""

with open(r"C:\Users\Chamo\Desktop\homeserve_app\lib\screens\auth\login_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# I messed up and deleted it earlier, so I need to insert it back. 
# It was located right after:
#   bool _isLoading = false;
# Let's just put it there.
content = re.sub(r'(bool _isLoading = false;\s*)', r'\1' + login_code + '\n', content)

with open(r"C:\Users\Chamo\Desktop\homeserve_app\lib\screens\auth\login_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)

signup_code = """
  Future<void> _handleSignUp() async {
    setState(() {
      _errorMessage = null;
    });

    if (_fullNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required.';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    if (!_agreeToTerms) {
      setState(() {
        _errorMessage = 'You must agree to the Terms & Conditions.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService.instance;
      await authService.signUpCustomer(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
      );
      
      if (mounted) {
        widget.onSignUpSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
"""

with open(r"C:\Users\Chamo\Desktop\homeserve_app\lib\screens\auth\signup_screen.dart", "r", encoding="utf-8") as f:
    s_content = f.read()
    
# replace the existing _handleSignUp
s_content = re.sub(r'Future<void> _handleSignUp\(\) async \{.*?\n  \}', signup_code, s_content, flags=re.DOTALL)

with open(r"C:\Users\Chamo\Desktop\homeserve_app\lib\screens\auth\signup_screen.dart", "w", encoding="utf-8") as f:
    f.write(s_content)

print("Done")
