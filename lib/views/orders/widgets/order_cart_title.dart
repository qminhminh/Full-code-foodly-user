import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodly_user/common/app_style.dart';
import 'package:foodly_user/common/reusable_text.dart';
import 'package:foodly_user/constants/constants.dart';
import 'package:foodly_user/models/user_cart.dart';

class OrderCartTile extends StatelessWidget {
  const OrderCartTile({
    super.key,
    required this.item,
  });

  final UserCart item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Get.to(
        //   () => FoodPage(
        //     food: item.productId, // Assuming productId has the food object
        //   ),
        //   transition: Transition.native,
        //   duration: const Duration(seconds: 1),
        // );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        height: 90.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  SizedBox(
                    height: 100.h,
                    width: 90.h,
                    child: Image.network(
                      item.productId.imageUrl.isNotEmpty
                          ? item.productId.imageUrl[0]
                          : 'https://via.placeholder.com/80', // Placeholder
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/placeholder.png', // Your local placeholder
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.only(left: 6, bottom: 2),
                      color: kGray.withOpacity(0.7),
                      height: 20,
                      width: 90.h,
                      child: RatingBarIndicator(
                        rating: item.productId.rating,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 15.0,
                        direction: Axis.horizontal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableText(
                      text: item.productId.title,
                      style: appStyle(13, kDark, FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    ReusableText(
                      text:
                          "Delivery time: ${item.productId.restaurant.time}", // Adjust as necessary
                      style: appStyle(11, kGray, FontWeight.w400),
                    ),
                    const SizedBox(height: 1),
                    SizedBox(
                      height: 20,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: item.additives.length,
                        itemBuilder: (context, i) {
                          final additive = item.additives[i];
                          return Container(
                            margin: const EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                              color: kSecondaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ReusableText(
                                  text: additive,
                                  style: appStyle(10, kDark, FontWeight.w400),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ReusableText(
                      text:
                          "Quantity: ${item.quantity} - Total: \$ ${item.totalPrice} ", // Adjust as necessary
                      style: appStyle(12, Colors.black, FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
