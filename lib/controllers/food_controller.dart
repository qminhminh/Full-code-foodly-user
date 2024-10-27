// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:foodly_user/models/environment.dart';
import 'package:foodly_user/models/foods.dart';
import 'package:foodly_user/models/obs_additives.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class FoodController extends GetxController {
  var additivesList = <ObsAdditive>[].obs;
  final RxDouble _totalPrice = 0.0.obs;
  bool initialCheckedValue = false;
  List<String> ads = [];
  var reviews = [].obs;

  var currentPage = 0.obs;

  void updatePage(int index) {
    currentPage.value = index;
  }

  void loadAdditives(List<Additive> addittives) {
    additivesList.clear();
    for (var additiveInfo in addittives) {
      var additive = ObsAdditive(
        id: additiveInfo.id,
        title: additiveInfo.title,
        price: additiveInfo.price,
        checked: initialCheckedValue,
      );
      if (addittives.length == additivesList.length) {
      } else {
        additivesList.add(additive);
      }
    }
  }

  double getTotalPrice() {
    double totalPrice = 0.0;
    for (var additive in additivesList) {
      if (additive.isChecked.value) {
        totalPrice += double.tryParse(additive.price) ?? 0.0;
      }
    }
    setAdditveTotal = totalPrice;
    return totalPrice;
  }

  List<String> getList() {
    List<String> ads = [];
    for (var additive in additivesList) {
      if (additive.isChecked.value && !ads.contains(additive.title)) {
        ads.add(additive.title);
      } else if (!additive.isChecked.value && ads.contains(additive.title)) {
        ads.remove(additive.title);
      }
    }

    return ads;
  }

  double get additiveTotal => _totalPrice.value;

  // Setter to set the value
  set setAdditveTotal(double newValue) {
    _totalPrice.value = newValue;
  }

  Future<void> getAllReviews(String productId) async {
    try {
      final response = await http.get(Uri.parse(
          '${Environment.appBaseUrl}/api/rating/get-all-review/$productId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          reviews.value = data['reviews'];
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
