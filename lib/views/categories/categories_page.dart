import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodly_user/common/app_style.dart';
import 'package:foodly_user/common/back_ground_container.dart';
import 'package:foodly_user/common/reusable_text.dart';
import 'package:foodly_user/common/shimmers/foodlist_shimmer.dart';
import 'package:foodly_user/constants/constants.dart';
import 'package:foodly_user/hooks/fetchFoodByCategory.dart';
import 'package:foodly_user/models/categories.dart';
import 'package:foodly_user/models/foods.dart';
import 'package:foodly_user/views/food/food_page.dart';
import 'package:foodly_user/views/home/widgets/food_tile.dart';
import 'package:get/get.dart';

class CategoriesPage extends HookWidget {
  const CategoriesPage({super.key, required this.category});

  final Categories category;

  @override
  Widget build(BuildContext context) {
    final hookResult = useFetchFoodByCategory(category.id, "41007428");
    final foods = hookResult.data;
    final isLoading = hookResult.isLoading;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: kOffWhite,
        title: ReusableText(
            text: category.title, style: appStyle(12, kGray, FontWeight.w600)),
      ),
      body: BackGroundContainer(
          child: isLoading
              ? const FoodsListShimmer()
              : Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
                )),
    );
  }
}
