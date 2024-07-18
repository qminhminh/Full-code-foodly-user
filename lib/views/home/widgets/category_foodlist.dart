import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodly_user/common/shimmers/foodlist_shimmer.dart';
import 'package:foodly_user/constants/constants.dart';
import 'package:foodly_user/controllers/catergory_controller.dart';
import 'package:foodly_user/hooks/fetchCategory.dart';
import 'package:foodly_user/models/foods.dart';
import 'package:foodly_user/views/food/food_page.dart';
import 'package:foodly_user/views/home/widgets/food_tile.dart';
import 'package:get/get.dart';

class CategoryFoodList extends HookWidget {
  const CategoryFoodList({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.put(CategoryController());
    final hookResult =
        useFetchCategory(categoryController.categoryValue, "41007428");
    final foods = hookResult.data ?? [];
    final isLoading = hookResult.isLoading;

    return isLoading
        ? const FoodsListShimmer()
        : Container(
            padding: EdgeInsets.only(left: 12.w, top: 10.h, right: 12.w),
            height: hieght,
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  Food food = foods[index];
                  return CategoryFoodTile(
                    food: food,
                    onTap: () {
                      Get.to(
                          () => FoodPage(
                                food: food,
                              ),
                          transition: Transition.fade,
                          duration: const Duration(seconds: 1));
                    },
                  );
                }),
          );
  }
}
