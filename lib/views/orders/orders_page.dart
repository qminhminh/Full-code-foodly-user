// ignore_for_file: unused_local_variable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodly_user/common/app_style.dart';
import 'package:foodly_user/common/back_ground_container.dart';
import 'package:foodly_user/common/divida.dart';
import 'package:foodly_user/common/reusable_text.dart';
import 'package:foodly_user/constants/constants.dart';
import 'package:foodly_user/controllers/address_controller.dart';
import 'package:foodly_user/controllers/order_controller.dart';
import 'package:foodly_user/hooks/fetchDefaultAddress.dart';
import 'package:foodly_user/models/distance_time.dart';
import 'package:foodly_user/models/foods.dart';
import 'package:foodly_user/models/order_item.dart';
import 'package:foodly_user/models/restaurants.dart';
import 'package:foodly_user/services/distance.dart';
import 'package:foodly_user/views/home/widgets/custom_btn.dart';
import 'package:foodly_user/views/orders/payment.dart';
import 'package:foodly_user/views/orders/widgets/order_tile.dart';
import 'package:foodly_user/views/profile/shipping_address.dart';
import 'package:foodly_user/views/restaurant/restaurants_page.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class OrderPage extends HookWidget {
  OrderPage(
      {super.key,
      required this.item,
      required this.restaurant,
      required this.food});

  final OrderItem item;
  final Restaurants restaurant;
  final Food food;

  TextEditingController _phone = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());
    final orderController = Get.put(OrderController());
    final hookResult = useFetchDefault(context, false);

    DistanceTime distanceTime = Distance().calculateDistanceTimePrice(
        controller.defaultAddress!.latitude,
        controller.defaultAddress!.longitude,
        restaurant.coords.latitude,
        restaurant.coords.longitude,
        10,
        2.00);

    double totalTime = 25 + distanceTime.time;
    double grandPrice = double.parse(item.price) + distanceTime.price;

    return Obx(() => orderController.paymentUrl.contains("https")
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
                  "Order Details",
                  style: appStyle(14, kDark, FontWeight.w500),
                ),
              ),
            ),
            body: BackGroundContainer(
              child: Column(
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
                  OrderTile(food: food),
                  Container(
                    width: width,
                    height: hieght / 2.8,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r)),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      margin: EdgeInsets.fromLTRB(8.w, 8.w, 8.w, 0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r)),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 5.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ReusableText(
                                  text: restaurant.title,
                                  style: appStyle(20, kGray, FontWeight.bold)),
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: kTertiary,
                                backgroundImage:
                                    NetworkImage(restaurant.imageUrl),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          RowText(
                              first: "Business Hours", second: restaurant.time),
                          SizedBox(
                            height: 5.h,
                          ),
                          const Divida(),
                          RowText(
                              first: "Distance To Restaurant",
                              second:
                                  "${distanceTime.distance.toStringAsFixed(3)} km"),
                          SizedBox(
                            height: 5.h,
                          ),
                          RowText(
                              first: controller.defaultAddress == null
                                  ? "Price To Current Location"
                                  : "Price To Default Address",
                              second:
                                  "\$ ${distanceTime.price.toStringAsFixed(2)}"),
                          SizedBox(
                            height: 5.h,
                          ),
                          RowText(
                              first: "Estimated Delivery Time",
                              second: "${totalTime.toStringAsFixed(0)} mins"),
                          SizedBox(
                            height: 5.h,
                          ),
                          RowText(
                              first: "Order Total", second: "\$ ${item.price}"),
                          SizedBox(
                            height: 5.h,
                          ),
                          RowText(
                              first: "Order Grand Total",
                              second: "\$ ${grandPrice.toStringAsFixed(2)}"),
                          SizedBox(
                            height: 10.h,
                          ),
                          const Divida(),
                          SizedBox(
                            height: 5.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: width * 0.3,
                                child: ReusableText(
                                    text: "Recipient",
                                    style:
                                        appStyle(10, kGray, FontWeight.w500)),
                              ),
                              SizedBox(
                                width: width * 0.585,
                                child: Text(
                                    controller.userAddress ??
                                        "Provide an address to proceed ordering",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    style:
                                        appStyle(10, kGray, FontWeight.w400)),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: RowText(
                                first: "Phone ",
                                second: _phone.text.isEmpty
                                    ? "Tap to add a phone number before ordering"
                                    : _phone.text),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  controller.defaultAddress == null
                      ? CustomButton(
                          onTap: () {
                            Get.to(() => const AddAddress());
                          },
                          radius: 9,
                          color: kPrimary,
                          btnWidth: width * 0.95,
                          btnHieght: 34.h,
                          text: "Add  Default Address",
                        )
                      : orderController.isLoading
                          ? const CircularProgressIndicator.adaptive(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(kPrimary),
                            )
                          : CustomButton(
                              onTap: () {
                                if (distanceTime.distance > 10.0) {
                                  Get.snackbar(
                                      colorText: kRed,
                                      backgroundColor: kPrimary,
                                      "Distance Alert",
                                      "You are too far from the restaurant, please order from a restaurant closer to you ");
                                  return;
                                } else {
                                  Order order = Order(
                                      userId: controller.defaultAddress!.userId,
                                      orderItems: [item],
                                      orderTotal: item.price,
                                      restaurantAddress:
                                          restaurant.coords.address,
                                      restaurantCoords: [
                                        restaurant.coords.latitude,
                                        restaurant.coords.longitude
                                      ],
                                      recipientCoords: [
                                        controller.defaultAddress!.latitude,
                                        controller.defaultAddress!.longitude
                                      ],
                                      deliveryFee:
                                          distanceTime.price.toStringAsFixed(2),
                                      grandTotal: grandPrice.toStringAsFixed(0),
                                      deliveryAddress:
                                          controller.defaultAddress!.id,
                                      paymentMethod: "STRIPE",
                                      restaurantId: restaurant.id);

                                  String orderData = orderToJson(order);

                                  orderController.order = order;

                                  orderController.createOrder(orderData, order);
                                }
                              },
                              radius: 9,
                              color: kPrimary,
                              btnWidth: width * 0.95,
                              btnHieght: 34.h,
                              text: "P R O C E E D T O P A Y M E N T",
                            ),
                ],
              ),
            )));
  }
}
