// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:foodly_user/common/app_style.dart';
import 'package:foodly_user/common/reusable_text.dart';
import 'package:foodly_user/constants/constants.dart';
import 'package:foodly_user/controllers/cart_controller.dart';
import 'package:foodly_user/controllers/counter_controller.dart';
import 'package:foodly_user/hooks/fetchVouchers.dart';
import 'package:foodly_user/models/user_cart.dart';
import 'package:foodly_user/models/vouchers.dart';
import 'package:get/get.dart';

class CartTile extends HookWidget {
  const CartTile({super.key, required this.item, required this.groupedItems});

  final UserCart item;
  final List<UserCart> groupedItems;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());
    final CounterController counterController = Get.put(CounterController());
    Voucher? selectedVoucher;

    // State to manage the selected products and total price
    final selectedProducts = useState<List<UserCart>>([]);
    final totalPrice = useState<double>(0.0);

    void updateTotalPrice() {
      double sum = 0.0;
      for (var product in selectedProducts.value) {
        double discount = (selectedVoucher?.discount ?? 0.0).toDouble();
        double productTotal =
            product.totalPrice * counterController.count.toDouble();
        sum += (productTotal - (productTotal * (discount / 100)));
      }
      totalPrice.value = sum;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display Restaurant Name for the group
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Restaurant: ${item.productId.restaurant.title}',
            style: appStyle(18.sp, Colors.black, FontWeight.bold),
          ),
        ),
        // Grouped product items
        ...groupedItems.map((product) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        child: Image.network(
                          product.productId.imageUrl[0],
                          height: 35.h,
                          width: 35.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Product Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReusableText(
                              text: product.productId.title,
                              style: appStyle(
                                12.sp,
                                Colors.black,
                                FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            ReusableText(
                              text:
                                  "Delivery time: ${product.productId.restaurant.time}",
                              style:
                                  appStyle(10.sp, Colors.grey, FontWeight.w400),
                            ),
                            SizedBox(height: 5.h),
                            // Additives
                            Row(
                              children: product.additives.map((additive) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  child: ReusableText(
                                    text: additive,
                                    style: appStyle(
                                      12.sp,
                                      Colors.black,
                                      FontWeight.w400,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      // Quantity adjustment buttons
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  counterController.decrement();
                                  updateTotalPrice();
                                },
                                child: const Icon(
                                  AntDesign.minussquareo,
                                  color: kPrimary,
                                ),
                              ),
                              SizedBox(
                                width: 6.w,
                              ),
                              Obx(
                                () => Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: ReusableText(
                                    text: "${counterController.count}",
                                    style: appStyle(16, kDark, FontWeight.w500),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 6.w,
                              ),
                              GestureDetector(
                                onTap: () {
                                  counterController.increment();
                                  updateTotalPrice();
                                },
                                child: const Icon(
                                  AntDesign.plussquareo,
                                  color: kPrimary,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.removeFromCart(product.id);
                            },
                            child: const Icon(
                              Icons.delete,
                              size: 24,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Obx(
                            () => Text(
                              "\$${(product.totalPrice * counterController.count.toDouble()).toStringAsFixed(2)}",
                              style: appStyle(
                                  16.sp, Colors.black, FontWeight.bold),
                            ),
                          ),
                          Checkbox(
                            value: selectedProducts.value.contains(product),
                            onChanged: (bool? value) {
                              if (value == true) {
                                selectedProducts.value.add(product);
                              } else {
                                selectedProducts.value.remove(product);
                              }
                              updateTotalPrice(); // Update total price when selection changes
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        // Voucher Selection Button
        GestureDetector(
          onTap: () async {
            final result = await _showVoucherSelectionSheet(context, item);
            if (result != null && result is Voucher) {
              selectedVoucher = result;
              updateTotalPrice(); // Update total price when voucher is selected
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selectedVoucher != null ? Colors.orange : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              selectedVoucher != null
                  ? "Voucher: ${selectedVoucher.title} - ${selectedVoucher.discount}%"
                  : "Apply Voucher",
              style: appStyle(14.sp, Colors.white, FontWeight.w500),
            ),
          ),
        ),
        SizedBox(height: 16.h), // Add some space below the voucher button
        // Total Price Display
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Total Price: \$${totalPrice.value.toStringAsFixed(2)}',
            style: appStyle(18.sp, Colors.black, FontWeight.bold),
          ),
        ),
        // Apply Total Button
        ElevatedButton(
          onPressed: () {
            // Handle checkout or further action
            // This could involve navigating to a summary page, etc.
          },
          child: const Text("Proceed to Checkout"),
        ),
      ],
    );
  }

  Future<dynamic> _showVoucherSelectionSheet(
      BuildContext context, UserCart product) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return VoucherList(product.productId.restaurant.id);
      },
    );
  }
}

class VoucherList extends HookWidget {
  const VoucherList(this.restaurantId, {super.key});
  final String restaurantId;

  @override
  Widget build(BuildContext context) {
    final vouchers = useFetchVoucher(restaurantId).data ?? [];
    final selectedVoucher = useState<Voucher?>(null);

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select a Voucher",
            style: appStyle(20.sp, Colors.black, FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: vouchers.length,
              itemBuilder: (context, index) {
                Voucher voucher = vouchers[index];
                return CheckboxListTile(
                  title: Text(voucher.title),
                  subtitle: Text('Discount: ${voucher.discount}%'),
                  value: selectedVoucher.value == voucher,
                  onChanged: (bool? value) {
                    if (value == true) {
                      selectedVoucher.value = voucher;
                    }
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, selectedVoucher.value);
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }
}
