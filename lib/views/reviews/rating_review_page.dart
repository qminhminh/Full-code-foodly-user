import 'package:flutter/material.dart';
import 'package:foodly_user/common/app_style.dart';
import 'package:foodly_user/common/reusable_text.dart';
import 'package:foodly_user/constants/constants.dart';
import 'package:foodly_user/views/reviews/widgets/orders_to_rate.dart';

class RatingReview extends StatelessWidget {
  const RatingReview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kLightWhite,
        elevation: 0,
        title: ReusableText(
          text: "Reviews and Ratings",
          style: appStyle(16, Colors.black, FontWeight.w600),
        ),
      ),
      body: const RateOrders(),
    );
  }
}
