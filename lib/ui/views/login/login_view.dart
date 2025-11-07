import 'package:flutter/material.dart';
import 'package:salims_apps_new/core/utils/style.dart';
import 'package:salims_apps_new/ui/views/login/login_viewmodel.dart';

import 'package:stacked/stacked.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  bool isShowPassword = false;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => LoginViewModel(context: context),
      builder: (context, vm, child) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo / Header
                          Image.asset("assets/images/salims.png", width: 250),
                          SizedBox(height: 10),
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[700],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Login to your account',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 40),

                          // Email Field
                          _buildTextField(
                            controller: vm.usernameController!,
                            hint: "Username",
                            icon: Icons.people,
                          ),
                          SizedBox(height: 20),

                          // Password Field
                          _buildTextField(
                            controller: vm.passwordController,
                            hint: "Password",
                            icon: Icons.lock_outline,
                            suffixIcon: isShowPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            obscureText: !isShowPassword,
                          ),
                          SizedBox(height: 10),

                          // Lupa password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text("Forgot Password?"),
                            ),
                          ),

                          SizedBox(height: 30),

                          // Tombol Login
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color.fromARGB(255, 3, 141, 255),
                                  const Color.fromARGB(255, 156, 210, 255),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: TextButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  vm.doLogin();
                                }
                              },
                              child: Text(
                                'LOGIN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            vm.isBusy
                ? const Stack(
                    children: [
                      ModalBarrier(
                        dismissible: false,
                        color: const Color.fromARGB(118, 0, 0, 0),
                      ),
                      Center(child: loadingSpinWhite),
                    ],
                  )
                : const Stack(),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    IconData? suffixIcon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter value';
          }
          return null;
        },
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(suffixIcon),
            onPressed: () {
              setState(() {
                isShowPassword = !isShowPassword;
              });
            },
          ),
          prefixIcon: Icon(icon),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }
}
