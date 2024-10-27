import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodly_user/common/app_style.dart';
import 'package:foodly_user/common/custom_container.dart';
import 'package:foodly_user/common/reusable_text.dart';
import 'package:foodly_user/common/shimmers/foodlist_shimmer.dart';
import 'package:foodly_user/constants/constants.dart';
import 'package:foodly_user/controllers/cart_controller.dart';
import 'package:foodly_user/hooks/fetchCart.dart';
import 'package:foodly_user/models/user_cart.dart';
import 'package:foodly_user/views/auth/widgets/login_redirect.dart';
import 'package:foodly_user/views/cart/widgets/cart_tile.dart';
import 'package:foodly_user/views/orders/orders_cart_page.dart';
import 'package:get/get.dart';
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
                        : Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 10.h,
                                ),
                                width: width,
                                height: 550.h,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Display restaurant name or voucher

                                        CartTile(
                                          item: cartItems.first,
                                          groupedItems: cartItems,
                                        )
                                      ],
                                    );
                                  },
                                ),
                              ),
                              Obx(() {
                                var cartController = Get.put(
                                    CartController()); // Đảm bảo CartController đã được khởi tạo
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 10.h,
                                  ),
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Text(
                                          'Total Price: \$${cartController.total.value.toStringAsFixed(2)}',
                                          style: appStyle(14.sp, Colors.black,
                                              FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(width: 50.w),
                                      // Apply Total Button
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kPrimary,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                          // Set the desired width
                                        ),
                                        onPressed: () {
                                          //selectedProducts
                                          if (cartController
                                              .selectedProducts.isEmpty) {
                                            Get.snackbar(
                                              "Notice choose product",
                                              "Failed, please choose product",
                                              colorText: kLightWhite,
                                              backgroundColor: kRed,
                                              icon: const Icon(Icons.error),
                                            );
                                          } else {
                                            Get.to(
                                                () => CheckoutPage(
                                                      selectedProducts:
                                                          cartController
                                                              .selectedProducts
                                                              .toList(),
                                                      totalPrice: cartController
                                                          .total.value,
                                                    ),
                                                transition: Transition.fade,
                                                duration:
                                                    const Duration(seconds: 1));
                                          }
                                        },
                                        child: const Text(
                                          "Proceed to Checkout",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          );
  }
}
