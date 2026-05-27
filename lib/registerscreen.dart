import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ricecare/components/btn_text.dart';
import 'package:ricecare/constants/colors.dart';
import 'package:ricecare/services/token_service.dart';
import 'package:ricecare/services/user_service.dart';

import 'components/textfield_type.dart';
import 'features/auth_repository.dart';
import 'models/usermodel.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterScreen({super.key, required this.showLoginPage});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _focusNode1 = FocusNode();
  final _focusNode2 = FocusNode();
  final _focusNode3 = FocusNode();
  final _focusNode4 = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordCfController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    _focusNode4.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _passwordCfController.dispose();
    super.dispose();
  }

  void onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _passwordCfController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password confirmation does not match")),
      );
      return;
    }

    bool success = await AuthRepository().register(
      username: _emailController.text,
      password: _passwordController.text,
      dob: "2004-04-20",
    );

    if (success) {
      final userId = await TokenService.getUserId();
      log("USER ID: $userId");

      if (userId != null) {
        final user = UserModel(
          id: userId,
          username: _usernameController.text,
          email: _emailController.text,
          phone: '',
          location: '',
          bio: '',
          imageUrl: '',
          createdAt: DateTime.now(),
        );

        await UserService().createUser(userId, user);
      }

      log("Đăng ký thành công");

      widget.showLoginPage();
    } else {
      log("Đăng ký thất bại");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Image.asset(
                    'assets/images/logo.jpeg',
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "create_account".tr(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "join_text".tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textNormalColor,
                          ),
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Rice",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "Care",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextSpan(
                          text: "register_description".tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textNormalColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "username".tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                  MyTextField(
                    obscureText: false,
                    numBorder: 8,
                    focusNode: _focusNode1,
                    controller: _usernameController,
                    hintText: "@example",
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) =>
                        FocusScope.of(context).requestFocus(_focusNode2),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "enter_username".tr();
                      }
                      //  else if (!InputValidation().isEmailValid(value)) {
                      //   return 'Invalid email';
                      // }
                      return null;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "email_address".tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                  MyTextField(
                    obscureText: false,
                    numBorder: 8,
                    focusNode: _focusNode2,
                    controller: _emailController,
                    hintText: "example@gmail.com",
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) =>
                        FocusScope.of(context).requestFocus(_focusNode3),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "enter_email".tr();
                      }
                      //  else if (!InputValidation().isEmailValid(value)) {
                      //   return 'Invalid email';
                      // }
                      return null;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "password".tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                  MyTextField(
                    numBorder: 8,
                    obscureText: _obscureText,
                    hintText: "password_hint".tr(),
                    focusNode: _focusNode3,
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      color: AppColors.hintTextColor,
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    onSubmitted: (value) =>
                        FocusScope.of(context).requestFocus(_focusNode3),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "enter_password".tr();
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "confirm_password".tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                  MyTextField(
                    numBorder: 8,
                    obscureText: _obscureText,
                    hintText: "password_hint".tr(),
                    focusNode: _focusNode4,
                    controller: _passwordCfController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      color: AppColors.hintTextColor,
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    onSubmitted: (value) => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "enter_password".tr();
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  BtnText(
                    width: double.infinity,
                    text: "sign_up".tr(),
                    onPressed: () => onRegister(),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "already_have_account".tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textNormalColor,
                          ),
                        ),
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.showLoginPage,
                          text: "sign_in".tr(),
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
