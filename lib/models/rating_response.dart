import 'dart:convert';

String ratingToJson(Rating data) => json.encode(data.toJson());

class Rating {
  final String ratingType;
  final String product;
  final int rating;
  final String comment;

  Rating({
    required this.ratingType,
    required this.product,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() => {
        "ratingType": ratingType,
        "product": product,
        "rating": rating,
        "comment": comment,
      };
}
