// ignore_for_file: prefer_final_fields

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foodly_user/models/api_error.dart';
import 'package:foodly_user/models/cart_response.dart';
import 'package:foodly_user/models/environment.dart';
import 'package:foodly_user/models/vouchers.dart';
import 'package:foodly_user/views/entrypoint.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';

class CartController extends GetxController {
  final box = GetStorage();

  // Reactive state
  var _address = false.obs;

  // Getter
  bool get address => _address.value;

  // Setter
  set setAddress(bool newValue) {
    _address.value = newValue;
  }

  RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  set setLoading(bool newValue) {
    _isLoading.value = newValue;
  }

  Rx<Voucher?> selectedVoucher = Rx<Voucher?>(null);

  // Method to update the selected voucher
  void updateSelectedVoucher(Voucher? voucher) {
    selectedVoucher.value = voucher;
  }

  void addToCart(String item) async {
    String token = box.read('token');
    String accessToken = jsonDecode(token);

    setLoading = true;
    var url = Uri.parse('${Environment.appBaseUrl}/api/cart');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: item,
      );

      if (response.statusCode == 201) {
        setLoading = false;

        CartResponse data = cartResponseFromJson(response.body);

        box.write("cart", jsonEncode(data.count));

        Get.snackbar("Product added successfully to cart",
            "You can now order multiple items via the cart",
            colorText: kLightWhite,
            backgroundColor: kPrimary,
            icon: const Icon(Icons.add_alert));
      } else {
        var data = apiErrorFromJson(response.body);

        Get.snackbar(data.message, "Failed to add address, please try again",
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(Icons.error));
      }
    } catch (e) {
      setLoading = false;
      Get.snackbar(e.toString(), "Failed to add address, please try again",
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error));
    } finally {
      setLoading = false;
    }
  }

  void removeFromCart(String productId) async {
    bool? confirmDelete = await Get.defaultDialog(
      title: "Confirm Remove",
      middleText: "Are you sure you want to remove this item from your cart?",
      backgroundColor: Colors.white,
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.black,
      onConfirm: () {
        Get.back(result: true); // Returns true if confirmed
      },
      onCancel: () {
        Get.back(result: false); // Returns false if canceled
      },
    );

    // Only proceed if user confirmed
    if (confirmDelete == true) {
      String token = box.read('token');
      String accessToken = jsonDecode(token);

      setLoading = true;
      var url =
          Uri.parse('${Environment.appBaseUrl}/api/cart/delete/$productId');

      try {
        var response = await http.delete(url, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        });

        if (response.statusCode == 200) {
          setLoading = false;
          CartResponse data = cartResponseFromJson(response.body);

          box.write("cart", jsonEncode(data.count));

          Get.snackbar(
            "Product removed",
            "The product was removed from cart successfully",
            colorText: kLightWhite,
            backgroundColor: kPrimary,
            icon: const Icon(Icons.add_alert),
          );
          Get.offAll(() => MainScreen());
        } else {
          var data = apiErrorFromJson(response.body);
          Get.snackbar(
            data.message,
            "Failed to remove the item, please try again",
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(Icons.error),
          );
        }
      } catch (e) {
        setLoading = false;
        Get.snackbar(
          e.toString(),
          "Failed to remove the item, please try again",
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error),
        );
      } finally {
        setLoading = false;
      }
    }
  }

  void removeFromCartCheckout(List<String> productIds) async {
    String? token = box.read('token');
    if (token == null) {
      Get.snackbar("Error", "User token is missing. Please login again.",
          colorText: kLightWhite, backgroundColor: kRed);
      return;
    }
    String accessToken = jsonDecode(token);

    setLoading = true;

    try {
      // Thực hiện xoá từng sản phẩm trong vòng lặp nếu không hỗ trợ xóa hàng loạt
      for (var productId in productIds) {
        var url =
            Uri.parse('${Environment.appBaseUrl}/api/cart/delete/$productId');

        var response = await http.delete(url, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        });

        if (response.statusCode == 200) {
          // Cập nhật số lượng sản phẩm còn lại trong giỏ hàng
          CartResponse data = cartResponseFromJson(response.body);
          box.write("cart", jsonEncode(data.count));
        } else {
          Get.snackbar("Error", "Failed to remove item with ID $productId",
              colorText: kLightWhite, backgroundColor: kRed);
        }
      }

      // Chuyển hướng sau khi tất cả yêu cầu xóa hoàn tất
      Get.offAll(() => MainScreen());
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to remove the items, please try again",
        colorText: kLightWhite,
        backgroundColor: kRed,
        icon: const Icon(Icons.error),
      );
    } finally {
      setLoading = false;
    }
  }

  void updateCountToCart(String cartId, String userId, String productId,
      var quantity, var totalPrice) async {
    String token = box.read('token');
    String accessToken = jsonDecode(token);

    setLoading = true;
    var url =
        Uri.parse('${Environment.appBaseUrl}/api/cart/update-count-to-cart');

    try {
      var response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode({
          "cartId": cartId,
          "userId": userId,
          "productId": productId,
          "quantity": quantity,
          "totalPrice": totalPrice
        }),
      );

      if (response.statusCode == 200) {
        setLoading = false;
      } else {
        Get.snackbar(
          "Error",

          "Failed, please try again", // Thêm "Error" cho rõ ràng
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error),
        );
      }
    } catch (e) {
      setLoading = false;
      Get.snackbar(e.toString(), "Failed, please try again",
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error));
    } finally {
      setLoading = false;
    }
  }

  void decrementProductQuantity(String userId, String productId) async {
    String token = box.read('token');
    String accessToken = jsonDecode(token);

    setLoading = true;
    var url = Uri.parse('${Environment.appBaseUrl}/api/cart/decrement');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode({
          "userId": userId,
          "productId": productId,
        }),
      );

      if (response.statusCode == 200) {
        setLoading = false;
      } else {
        var data = apiErrorFromJson(response.body);
        Get.snackbar(
          "Error",
          data.message, // Thêm "Error" cho rõ ràng
          // Thêm "Error" cho rõ ràng
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error),
        );
      }
    } catch (e) {
      setLoading = false;
      Get.snackbar(e.toString(), "Failed, please try again",
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error));
    } finally {
      setLoading = false;
    }
  }

  void incrementProductQuantity(String userId, String productId) async {
    String token = box.read('token');
    String accessToken = jsonDecode(token);

    setLoading = true;
    var url = Uri.parse('${Environment.appBaseUrl}/api/cart/increment');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode({
          "userId": userId,
          "productId": productId,
        }),
      );

      if (response.statusCode == 200) {
        setLoading = false;
      } else {
        var data = apiErrorFromJson(response.body);
        Get.snackbar(
          "Error",
          data.message, // Thêm "Error" cho rõ ràng
          // Thêm "Error" cho rõ ràng
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error),
        );
      }
    } catch (e) {
      setLoading = false;
      Get.snackbar(e.toString(), "Failed, please try again",
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error));
    } finally {
      setLoading = false;
    }
  }

  // Future<List<Food>> getFoodByIdUseCart(String foodId) async {
  //   String token = box.read('token');
  //   String accessToken = jsonDecode(token);

  //   setLoading = true;
  //   var url =
  //       Uri.parse('${Environment.appBaseUrl}/api/foods/cart-get-food/$foodId');

  //   try {
  //     var response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $accessToken'
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       setLoading = false;
  //     } else {
  //       var data = apiErrorFromJson(response.body);
  //       Get.snackbar(
  //         "Error",
  //         data.message, // Thêm "Error" cho rõ ràng
  //         // Thêm "Error" cho rõ ràng
  //         colorText: kLightWhite,
  //         backgroundColor: kRed,
  //         icon: const Icon(Icons.error),
  //       );
  //     }
  //   } catch (e) {
  //     setLoading = false;
  //     Get.snackbar(e.toString(), "Failed, please try again",
  //         colorText: kLightWhite,
  //         backgroundColor: kRed,
  //         icon: const Icon(Icons.error));
  //   } finally {
  //     setLoading = false;
  //   }
  // }
}
