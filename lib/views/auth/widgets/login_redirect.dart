import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodly_user/common/app_style.dart';
import 'package:foodly_user/common/custom_container.dart';
import 'package:foodly_user/common/reusable_text.dart';
import 'package:foodly_user/constants/constants.dart';
import 'package:foodly_user/views/auth/login_page.dart';
import 'package:foodly_user/views/home/widgets/custom_btn.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LoginRedirection extends StatelessWidget {
  const LoginRedirection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary,
      appBar: AppBar(
        backgroundColor: kLightWhite,
        elevation: 0.3,
        title: ReusableText(
            text: "Please login to access this page",
            style: appStyle(12, kDark, FontWeight.w500)),
      ),
      body: SafeArea(
        child: CustomContainer(
            containerHieght: MediaQuery.of(context).size.height * 0.76,
            containerContent: Column(
              children: [
                Container(
                  width: width,
                  height: hieght / 2,
                  color: Colors.white,
                  child: LottieBuilder.asset(
                    "assets/anime/delivery.json",
                    width: width,
                    height: hieght / 2,
                  ),
                ),
                CustomButton(
                    onTap: () {
                      Get.to(() => const Login());
                    },
                    color: kPrimary,
                    btnHieght: 40.h,
                    btnWidth: width - 20.w,
                    text: "L O G I N")
              ],
            )),
      ),
    );
  }
}
