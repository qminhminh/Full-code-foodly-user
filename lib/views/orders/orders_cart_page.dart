// ignore_for_file: unused_local_variable, prefer_final_fields

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodly_user/common/app_style.dart';
import 'package:foodly_user/common/back_ground_container.dart';
import 'package:foodly_user/common/reusable_text.dart';
import 'package:foodly_user/constants/constants.dart';
import 'package:foodly_user/controllers/address_controller.dart';
import 'package:foodly_user/controllers/cart_controller.dart';
import 'package:foodly_user/controllers/order_controller.dart';
import 'package:foodly_user/hooks/fetchDefaultAddress.dart';
import 'package:foodly_user/models/order_item.dart';
import 'package:foodly_user/models/user_cart.dart';
import 'package:foodly_user/views/home/widgets/custom_btn.dart';
import 'package:foodly_user/views/orders/payment.dart';
import 'package:foodly_user/views/orders/widgets/order_cart_title.dart';
import 'package:foodly_user/views/restaurant/restaurants_page.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class CheckoutPage extends HookWidget {
  CheckoutPage({
    super.key,
    required this.selectedProducts,
    required this.userCart,
  });

  final List<UserCart> selectedProducts;
  final UserCart userCart;

  TextEditingController _phone = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final addressController = Get.put(AddressController());
    final orderController = Get.put(OrderController());
    final controller = Get.put(CartController());
    final hookResult = useFetchDefault(context, false);

    double totalPrice =
        selectedProducts.fold(0, (sum, item) => sum + item.totalPrice);
    double deliveryFee = 2.0; // Giả định phí giao hàng là 2.0
    double grandTotal = totalPrice + deliveryFee;

    String restaurantName = selectedProducts.isNotEmpty
        ? selectedProducts.first.productId.restaurant.title
        : 'Restaurant Name';

    return Obx(
      () => orderController.paymentUrl.contains("https")
          ? const PaymentWebView()
          : Scaffold(
              backgroundColor: kOffWhite,
              appBar: AppBar(
                backgroundColor: kOffWhite,
                elevation: 0,
                centerTitle: true,
                leading: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(CupertinoIcons.back)),
                title: Center(
                  child: Text(
                    "Checkout Products",
                    style: appStyle(14, kDark, FontWeight.w500),
                  ),
                ),
              ),
              body: BackGroundContainer(
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1.w),
                      child: ReusableText(
                        text: restaurantName,
                        style: appStyle(18, kDark, FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: selectedProducts.length,
                        itemBuilder: (context, index) {
                          return OrderCartTile(
                            item: selectedProducts[index],
                          );
                        },
                      ),
                    ),
                    Container(
                      width: width,
                      padding: EdgeInsets.all(12.w),
                      margin: EdgeInsets.fromLTRB(8.w, 8.w, 8.w, 0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r)),
                      child: Column(
                        children: [
                          RowText(
                              first: "Total Price",
                              second: "\$ ${totalPrice.toStringAsFixed(2)}"),
                          RowText(
                              first: "Delivery Fee",
                              second: "\$ ${deliveryFee.toStringAsFixed(2)}"),
                          RowText(
                              first: "Grand Total",
                              second: "\$ ${grandTotal.toStringAsFixed(2)}"),
                          SizedBox(height: 10.h),
                          GestureDetector(
                            onTap: () {
                              // Add logic to select or add a phone number
                            },
                            child: RowText(
                              first: "Phone",
                              second: _phone.text.isEmpty
                                  ? "Tap to add a phone number"
                                  : _phone.text,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          CustomButton(
                            onTap: () {
                              if (addressController.defaultAddress == null) {
                                Get.snackbar("Error",
                                    "Please add a default address before proceeding.");
                                return;
                              }

                              // Tạo danh sách các OrderItem từ selectedProducts
                              List<OrderItem> orderItems =
                                  selectedProducts.map((item) {
                                return OrderItem(
                                  foodId: item.productId.id, // ID của sản phẩm
                                  additives: item
                                      .additives, // Các thành phần phụ (additives)
                                  quantity:
                                      item.quantity.toString(), // Số lượng
                                  price:
                                      item.totalPrice.toStringAsFixed(2), // Giá
                                  instructions: item.instructions, // Hướng dẫn
                                );
                              }).toList();

                              // Tạo đối tượng Order
                              Order order = Order(
                                userId:
                                    addressController.defaultAddress!.userId,
                                orderItems: orderItems, // Danh sách OrderItem
                                orderTotal: totalPrice
                                    .toStringAsFixed(2), // Tổng tiền đơn hàng
                                restaurantAddress: selectedProducts
                                    .first
                                    .productId
                                    .restaurant
                                    .coords
                                    .address, // Địa chỉ nhà hàng
                                restaurantCoords: [
                                  selectedProducts.first.productId.restaurant
                                      .coords.latitude,
                                  selectedProducts.first.productId.restaurant
                                      .coords.longitude
                                ],
                                recipientCoords: [
                                  addressController.defaultAddress!.latitude,
                                  addressController.defaultAddress!.longitude
                                ],
                                deliveryFee: deliveryFee
                                    .toStringAsFixed(2), // Phí giao hàng
                                grandTotal:
                                    grandTotal.toStringAsFixed(2), // Tổng cộng
                                deliveryAddress: addressController
                                    .defaultAddress!.id, // ID địa chỉ giao hàng
                                paymentMethod:
                                    "STRIPE", // Phương thức thanh toán
                                restaurantId: selectedProducts.first.productId
                                    .restaurant.id, // ID nhà hàng
                              );

                              String orderData = orderToJson(order);
                              orderController.order = order;
                              orderController.createOrder(orderData, order);

                              // // Xóa các sản phẩm đã thanh toán nếu thanh toán thành công

                              // for (var product in selectedProducts) {
                              //   controller.removeFromCartCheckout(
                              //       product.productId.id);
                              // }
                            },
                            radius: 9,
                            color: kPrimary,
                            btnWidth: width * 0.95,
                            btnHieght: 34.h,
                            text: "PROCEED TO PAYMENT",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
