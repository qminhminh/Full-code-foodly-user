// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodly_user/views/home/widgets/food_widget.dart';
import 'package:foodly_user/common/shimmers/nearby_shimmer.dart';
import 'package:foodly_user/hooks/fetchFoods.dart';
import 'package:foodly_user/models/foods.dart';
import 'package:foodly_user/views/food/food_page.dart';
import 'package:get/get.dart';

class FoodList extends HookWidget {
  const FoodList({super.key});

  @override
  Widget build(BuildContext context) {
    final hookResult = useFetchFood();
    final foods = hookResult.data;
    final isLoading = hookResult.isLoading;
    final error = hookResult.error;
    final refetch = hookResult.refetch;
    return isLoading
        ? const NearbyShimmer()
        : error != null
            ? Container()
            : Container(
                padding: const EdgeInsets.only(left: 12, top: 10),
                height: 180.h,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      Food food = foods[index];
                      return FoodWidget(
                          onTap: () {
                            Get.to(
                                () => FoodPage(
                                      food: food,
                                    ),
                                transition: Transition.fade,
                                duration: const Duration(seconds: 1));
                          },
                          image: food.imageUrl[0],
                          title: food.title,
                          price: food.price.toStringAsFixed(2),
                          time: food.time);
                    }),
              );
  }
}
