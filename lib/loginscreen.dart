import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ricecare/components/btn_text.dart';
import 'package:ricecare/constants/colors.dart';
import 'package:ricecare/forgotscreen.dart';
import 'package:ricecare/services/google_auth_service.dart';
import 'package:ricecare/test.dart';

import 'components/btn_social.dart';
import 'components/textfield_type.dart';
import 'features/auth_repository.dart';
import 'models/usermodel.dart';
import 'services/token_service.dart';
import 'services/user_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginScreen({super.key, required this.showRegisterPage});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _focusNode1 = FocusNode();
  final _focusNode2 = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool isLoading = false;

  void login() async {
    setState(() => isLoading = true);

    bool success = await AuthRepository().login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Test()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("invalid_credentials".tr())));
    }
  }

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  Image.asset(
                    'assets/images/logo.jpeg',
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "welcome_back".tr(),
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
                          text: "sign_in_description".tr(),
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
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
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
                    focusNode: _focusNode1,
                    controller: _emailController,
                    hintText: "email_hint".tr(),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) =>
                        FocusScope.of(context).requestFocus(_focusNode2),
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
                    focusNode: _focusNode2,
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
                    onSubmitted: (value) => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "enter_password".tr();
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ForgotScreen()),
                      ),
                      child: Text(
                        'forgot_password'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  BtnText(
                    width: double.infinity,
                    text: isLoading ? "..." : "sign_in".tr(),
                    onPressed: isLoading ? null : login,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  //divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.primaryColor,
                          thickness: 2,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.02,
                        ),
                        child: Text(
                          "or_continue_with".tr(),
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.primaryColor,
                          thickness: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BtnSocial(
                        imagePath: 'assets/images/google.png',
                        text: "google".tr(),
                        onPressed: () async {
                          final google = GoogleAuthService();
                          final authRepo = AuthRepository();

                          try {
                            final googleData = await google.getGoogleData();

                            if (googleData == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("google_login_cancelled".tr()),
                                ),
                              );
                              return;
                            }

                            final success = await authRepo.loginWithGoogle(
                              googleData.idToken,
                            );

                            if (success) {
                              final userId = await TokenService.getUserId();

                              if (userId != null) {
                                final user = UserModel(
                                  id: userId,
                                  username: googleData.name ?? '',
                                  email: googleData.email ?? '',
                                  phone: '',
                                  location: '',
                                  bio: '',
                                  imageUrl: googleData.photoUrl ?? '',
                                  createdAt: DateTime.now(),
                                );

                                await UserService().createUser(userId, user);
                              }
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => Test()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("login_failed".tr())),
                              );
                            }
                          } catch (e) {
                            print("Google login error: $e");

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("error".tr(args: [e.toString()])),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      BtnSocial(
                        imagePath: 'assets/images/facebook.png',
                        text: "Facebook",
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "no_account".tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textNormalColor,
                          ),
                        ),
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.showRegisterPage,
                          text: "sign_up".tr(),
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
