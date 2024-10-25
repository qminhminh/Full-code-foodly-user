import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodly_user/common/app_style.dart';
import 'package:foodly_user/common/custom_container.dart';
import 'package:foodly_user/common/reusable_text.dart';
import 'package:foodly_user/common/shimmers/foodlist_shimmer.dart';
import 'package:foodly_user/constants/constants.dart';
import 'package:foodly_user/hooks/fetchCart.dart';
import 'package:foodly_user/models/user_cart.dart';
import 'package:foodly_user/views/auth/widgets/login_redirect.dart';
import 'package:foodly_user/views/cart/widgets/cart_tile.dart';
import 'package:get_storage/get_storage.dart';

class CartPage extends HookWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    String? token = box.read('token');

    final hookResult = useFetchCart();
    final items = hookResult.data;
    final isLoading = hookResult.isLoading;

    // Group items by restaurant ID
    Map<String, List<UserCart>> groupedItems = {};
    if (items != null) {
      for (var item in items) {
        String restaurantId = item.productId.restaurant.id;
        if (!groupedItems.containsKey(restaurantId)) {
          groupedItems[restaurantId] = [];
        }
        groupedItems[restaurantId]!.add(item);
      }
    }

    return token == null
        ? const LoginRedirection()
        : Scaffold(
            backgroundColor: kPrimary,
            appBar: AppBar(
              backgroundColor: kLightWhite,
              elevation: 0.3,
              title: Center(
                child: ReusableText(
                  text: "Cart",
                  style: appStyle(16, kDark, FontWeight.bold),
                ),
              ),
            ),
            body: SafeArea(
              child: CustomContainer(
                containerContent: Column(
                  children: [
                    isLoading
                        ? const FoodsListShimmer()
                        : Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            width: width,
                            height: hieght,
                            color: kLightWhite,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: groupedItems.length,
                              itemBuilder: (context, i) {
                                String restaurantId =
                                    groupedItems.keys.elementAt(i);
                                List<UserCart> cartItems =
                                    groupedItems[restaurantId]!;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Display restaurant name or voucher

                                    ...cartItems.map((cart) {
                                      return CartTile(
                                        item: cart,
                                        groupedItems: cartItems,
                                      );
                                    }).toList(),
                                  ],
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
  }
}
