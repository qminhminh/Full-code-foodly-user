// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:foodly_user/common/app_style.dart';
import 'package:foodly_user/common/reusable_text.dart';
import 'package:foodly_user/common/shimmers/voucher_shimmer.dart';
import 'package:foodly_user/constants/constants.dart';
import 'package:foodly_user/controllers/cart_controller.dart';
import 'package:foodly_user/controllers/couant_cart_controller.dart';
import 'package:foodly_user/hooks/fetchVouchers.dart';
import 'package:foodly_user/models/user_cart.dart';
import 'package:foodly_user/models/vouchers.dart';
import 'package:foodly_user/views/food/widgets/empty_page.dart';
import 'package:get/get.dart';

class CartTile extends HookWidget {
  const CartTile({super.key, required this.item, required this.groupedItems});

  final UserCart item;
  final List<UserCart> groupedItems;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());
    final counterController = Get.put(CounterCartController());
    final cartController = Get.put(CartController());

    Voucher? selectedVoucher;

    // State to manage the selected products and total price
    final selectedProducts = useState<List<UserCart>>([]);
    final totalPrice = useState<double>(0.0);

    void updateTotalPrice() {
      double sum = 0.0;

      for (var product in selectedProducts.value) {
        // Get the individual product quantity from the CounterController
        int quantity = counterController.getCount(product.productId.id);

        // Calculate the total price for this product
        double productTotal =
            product.productId.price * quantity; // Use the product's price

        // Apply any selected voucher discount
        double discount = (selectedVoucher?.discount ?? 0.0).toDouble();
        double discountAmount = productTotal * (discount / 100);

        // Add the discounted price to the total sum
        sum += (productTotal - discountAmount);
      }

      totalPrice.value = sum; // Update the total price
      cartController.total(sum);
    }

    return Container(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display Restaurant Name for the group
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Restaurant: ${item.productId.restaurant.title} >',
                  style: appStyle(18.sp, Colors.black, FontWeight.bold),
                ),
              ),
            ],
          ),
          // Grouped product items
          ...groupedItems.map((product) {
            if (!counterController.counts.containsKey(product.productId.id)) {
              counterController.initializeCount(
                  product.productId.id, product.quantity);
            }
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
                        Row(
                          children: [
                            Checkbox(
                              value: selectedProducts.value.contains(product),
                              onChanged: (bool? value) {
                                if (value == true) {
                                  selectedProducts.value.add(product);
                                  cartController.selectedProducts.add(product);
                                } else {
                                  selectedProducts.value.remove(product);
                                  cartController.selectedProducts
                                      .remove(product);
                                }
                                updateTotalPrice(); // Update total price when selection changes
                              },
                            ),
                            const SizedBox(width: 4),
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                              child: Image.network(
                                product.productId.imageUrl[0],
                                height: 75.h,
                                width: 75.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                        // Product Image

                        const SizedBox(width: 10),
                        // Product Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReusableText(
                                text: product.productId.title,
                                style: appStyle(
                                  15.sp,
                                  Colors.black,
                                  FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              ReusableText(
                                text:
                                    "Delivery time: ${product.productId.restaurant.time}",
                                style: appStyle(
                                    10.sp, Colors.grey, FontWeight.w400),
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
                                      color: kSecondaryLight,
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
                              SizedBox(height: 20.h),
                              Row(
                                children: [
                                  Obx(
                                    () => Text(
                                      "\$${(product.productId.price * counterController.getCount(product.productId.id)).toStringAsFixed(2)}",
                                      style: appStyle(
                                          16.sp, Colors.black, FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ), // Add spacing between price and counter
                                  GestureDetector(
                                    onTap: () {
                                      if (counterController
                                              .getCount(product.productId.id) <=
                                          1) {
                                        controller.removeFromCart(product.id);
                                      } else {
                                        counterController
                                            .decrement(product.productId.id);
                                        updateTotalPrice();
                                        controller.updateCountToCart(
                                          item.id,
                                          item.userId,
                                          item.productId.id,
                                          counterController
                                              .getCount(product.productId.id),
                                          (product.productId.price *
                                              counterController.getCount(
                                                  product.productId.id)),
                                        );
                                      }
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
                                        text:
                                            "${counterController.getCount(product.productId.id)}",
                                        style: appStyle(
                                            16, kDark, FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 6.w,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      counterController
                                          .increment(product.productId.id);
                                      updateTotalPrice();
                                      controller.updateCountToCart(
                                        item.id,
                                        item.userId,
                                        item.productId.id,
                                        counterController
                                            .getCount(product.productId.id),
                                        (product.productId.price *
                                            counterController.getCount(
                                                product.productId.id)),
                                      );
                                    },
                                    child: const Icon(
                                      AntDesign.plussquareo,
                                      color: kPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          // Voucher Selection Button
          const Divider(),
          Obx(
            () => GestureDetector(
              onTap: () async {
                final result = await _showVoucherSelectionSheet(context, item);
                if (result != null && result is Voucher) {
                  selectedVoucher = result;
                  cartController.updateSelectedVoucher(result);

                  updateTotalPrice(); // Update total price when voucher is selected
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: selectedVoucher != null ? Colors.white : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/vouvher.svg',
                      width: 40.w,
                      height: 40.h,
                    ),
                    const SizedBox(width: 15),
                    Text(
                      cartController.selectedVoucher.value != null
                          ? "Voucher:${cartController.selectedVoucher.value!.title} - ${cartController.selectedVoucher.value!.discount}% >"
                          : "Apply Voucher >",
                      style: appStyle(16.sp, Colors.black, FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Add some space below the voucher button
          // Total Price Display
          const Divider(),
        ],
      ),
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
  const VoucherList(this.restaurantid, {super.key});
  final String restaurantid;

  @override
  Widget build(BuildContext context) {
    final hookResult = useFetchVoucher(restaurantid);
    final vouchers = hookResult.data;
    final isLoading = hookResult.isLoading;
    final selectedVoucher = useState<Voucher?>(null);

    if (isLoading) {
      return const VouchersListShimmer();
    } else if (vouchers!.isEmpty) {
      return const EmptyPage();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      height: 400.h,
      child: Column(
        children: [
          Text(
            "Select a Voucher",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: kPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: ListView.builder(
              itemCount: vouchers.length,
              itemBuilder: (context, index) {
                Voucher voucher = vouchers[index];
                bool isSelectable = voucher.addVoucherSwitch;

                return Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8), // Khoảng cách giữa các items
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelectable
                        ? kPrimary
                        : Colors.grey[300], // Màu cam nhạt hoặc xám nhạt
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      voucher.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Discount: ${voucher.discount.toString()}%'),
                    trailing: Radio<Voucher>(
                      value: voucher,
                      groupValue: selectedVoucher.value,
                      onChanged: isSelectable
                          ? (Voucher? value) {
                              selectedVoucher.value = value;
                            }
                          : null, // Không cho phép chọn nếu không thể
                      activeColor: kPrimary,
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context, selectedVoucher.value);
            },
            child: const Text(
              "Confirm",
              style: TextStyle(
                color: kWhite,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }
}
